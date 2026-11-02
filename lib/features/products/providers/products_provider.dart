import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/product_entity.dart';
import '../../auth/providers/auth_provider.dart';

class ProductsState {
  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.isOffline = false,
    this.currentPage = 0,
  });

  final List<ProductEntity> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool isOffline;
  final int currentPage;

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error = _sentinel,
    bool? isOffline,
    int? currentPage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error == _sentinel ? this.error : error as String?,
      isOffline: isOffline ?? this.isOffline,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() =>
      'ProductsState(products: ${products.length}, isLoading: $isLoading, '
      'hasMore: $hasMore, isOffline: $isOffline, page: $currentPage)';
}

const Object _sentinel = Object();

class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier(this._ref) : super(const ProductsState());

  final Ref _ref;

  Future<void> loadProducts() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null, isOffline: false);

    try {
      final repo = _ref.read(productRepositoryProvider);
      final products = await repo.getProducts(
        limit: AppConstants.pageSize,
        skip: 0,
      );

      final hasMore = products.length >= AppConstants.pageSize;

      state = state.copyWith(
        products: products,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
        isOffline: false,
        error: null,
      );
    } on NetworkException catch (_) {
      await _fallbackToCache();
    } catch (e) {
      await _fallbackToCache(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isOffline) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = _ref.read(productRepositoryProvider);
      final skip = state.currentPage * AppConstants.pageSize;
      final newProducts = await repo.getProducts(
        limit: AppConstants.pageSize,
        skip: skip,
      );

      final hasMore = newProducts.length >= AppConstants.pageSize;
      final merged = [...state.products, ...newProducts];

      state = state.copyWith(
        products: merged,
        isLoadingMore: false,
        hasMore: hasMore,
        currentPage: state.currentPage + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }

  Future<void> refresh() async {
    state = const ProductsState();
    await loadProducts();
  }

  Future<void> _fallbackToCache({String? errorMessage}) async {
    try {
      final repo = _ref.read(productRepositoryProvider);
      final cached = await repo.getCachedProducts();

      if (cached.isNotEmpty) {
        state = state.copyWith(
          products: cached,
          isLoading: false,
          hasMore: false,
          isOffline: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
          isOffline: true,
          error: errorMessage ?? 'No internet connection and no cached data.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasMore: false,
        isOffline: true,
        error: errorMessage ?? e.toString(),
      );
    }
  }
}

class SearchNotifier extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  SearchNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<String>(debouncedSearchProvider, (_, query) {
      if (query.trim().isEmpty) {
        state = const AsyncValue.data([]);
      } else {
        search(query.trim());
      }
    });
  }

  final Ref _ref;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(productRepositoryProvider);
      final results = await repo.searchProducts(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final notifier = ProductsNotifier(ref);
  notifier.loadProducts();
  return notifier;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<ProductEntity>>>(
        (ref) {
  return SearchNotifier(ref);
});

final productDetailProvider =
    FutureProvider.family<ProductEntity, int>((ref, id) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProduct(id);
});

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
});
