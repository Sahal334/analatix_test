import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/qr_parser.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  PermissionStatus? _permissionStatus;
  bool _hasScanned = false;
  bool _isTorchOn = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only check current status when returning to the app (e.g. from Settings).
    // Do NOT call .request() here, or dismissing the OS dialog will cause a loop.
    if (state == AppLifecycleState.resumed && !_isRequestingPermission) {
      _refreshPermissionStatus();
    }
  }

  /// Checks current status without triggering a new OS permission dialog.
  Future<void> _refreshPermissionStatus() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _setupController();
    }
    if (mounted && status != _permissionStatus) {
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  /// Checks status and requests permission if not yet granted.
  Future<void> _checkAndRequestPermission() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;

    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        _setupController();
        if (mounted) {
          setState(() {
            _permissionStatus = PermissionStatus.granted;
          });
        }
        return;
      }

      // If not permanently denied, request the permission
      if (!status.isPermanentlyDenied && !status.isRestricted) {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          _setupController();
        }
        if (mounted) {
          setState(() {
            _permissionStatus = result;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _permissionStatus = status;
          });
        }
      }
    } finally {
      _isRequestingPermission = false;
    }
  }

  void _setupController() {
    _controller ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _handleCode(String rawCode) {
    if (_hasScanned) return;

    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return;

    // Allow entering just the product ID number directly (e.g. 3, 15, 9999)
    final directId = int.tryParse(trimmed);
    if (directId != null && directId > 0) {
      _hasScanned = true;
      context.pushReplacement('/products/$directId');
      return;
    }

    final result = parseQrCode(trimmed);
    final l10n = AppLocalizations.of(context)!;

    switch (result) {
      case QrResultProduct(:final id):
        _hasScanned = true;
        context.pushReplacement('/products/$id');
      case QrResultNotAProduct():
        _showFeedback(l10n.invalidQrCode);
      case QrResultInvalidFormat():
        _showFeedback(l10n.invalidCode);
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.typeCodeInstead),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'e.g. 3 or catalogue://product/3',
            labelText: l10n.enterProductCode,
          ),
          onSubmitted: (value) {
            Navigator.of(dialogContext).pop();
            _handleCode(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = textController.text;
              Navigator.of(dialogContext).pop();
              _handleCode(value);
            },
            child: Text(l10n.open),
          ),
        ],
      ),
    ).whenComplete(textController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_permissionStatus == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(l10n.scannerTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (!_permissionStatus!.isGranted) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(l10n.scannerTitle),
        ),
        body: _buildPermissionDeniedView(context, l10n, theme),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.scannerTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? Colors.amber : Colors.white,
            ),
            onPressed: () async {
              if (_controller != null) {
                await _controller!.toggleTorch();
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleCode(barcode.rawValue!);
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              return _buildPermissionDeniedView(context, l10n, theme);
            },
          ),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(200),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.pointCamera,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black87,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _showManualInputDialog,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: Text(l10n.typeCodeInstead),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(50),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(
      BuildContext context,
      AppLocalizations l10n,
      ThemeData theme,
      ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 56,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.cameraPermissionDenied,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.cameraPermissionMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                if (_permissionStatus?.isPermanentlyDenied ?? true) {
                  await openAppSettings();
                } else {
                  await _checkAndRequestPermission();
                }
              },
              icon: const Icon(Icons.settings_outlined),
              label: Text(l10n.openSettings),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showManualInputDialog,
              icon: const Icon(Icons.keyboard_rounded),
              label: Text(l10n.typeCodeInstead),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}