import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../model/product_repository.dart';
import '../model/store_category.dart';
import 'store_event.dart';
import 'store_state.dart';

class StorePresenter extends Bloc<StoreEvent, StoreState> {
  StorePresenter(this._repository) : super(const StoreState()) {
    on<ProductsRequested>(_loadProducts);
    on<ProductAddedToCart>((event, emit) {
      if (!state.products.any((product) => product.id == event.productId)) {
        return;
      }
      final cart = Map<int, int>.of(state.cart);
      cart.update(
        event.productId,
        (quantity) => quantity + 1,
        ifAbsent: () => 1,
      );
      emit(state.copyWith(cart: cart));
    });
    on<SearchChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<CategorySelected>(
      (event, emit) => emit(state.copyWith(category: event.category)),
    );
    on<SortChanged>((event, emit) => emit(state.copyWith(sort: event.sort)));
    on<FavoriteToggled>((event, emit) {
      final favorites = Set<int>.of(state.favorites);
      if (!favorites.add(event.productId)) favorites.remove(event.productId);
      emit(state.copyWith(favorites: favorites));
    });
    on<FavoritesFilterToggled>(
      (event, emit) =>
          emit(state.copyWith(onlyFavorites: !state.onlyFavorites)),
    );
    on<FiltersCleared>(
      (event, emit) => emit(
        state.copyWith(
          query: '',
          category: StoreCategory.all,
          onlyFavorites: false,
          sort: ProductSort.popular,
        ),
      ),
    );
  }

  final ProductRepository _repository;
  bool _loading = false;

  Future<void> refresh() {
    final completion = Completer<void>();
    add(ProductsRequested(completion: completion));
    return completion.future;
  }

  Future<void> _loadProducts(
    ProductsRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (_loading) {
      event.completion?.complete();
      return;
    }
    _loading = true;
    emit(state.copyWith(status: StoreStatus.loading, clearError: true));
    try {
      final products = await _repository.getProducts();
      if (!emit.isDone) {
        emit(state.copyWith(status: StoreStatus.ready, products: products));
      }
    } on ApiException catch (error) {
      if (!emit.isDone) {
        emit(state.copyWith(status: StoreStatus.failure, error: error.message));
      }
    } catch (error, stack) {
      addError(error, stack);
      if (!emit.isDone) {
        emit(
          state.copyWith(
            status: StoreStatus.failure,
            error: 'Something went wrong loading the store. Please try again.',
          ),
        );
      }
    } finally {
      _loading = false;
      event.completion?.complete();
    }
  }
}
