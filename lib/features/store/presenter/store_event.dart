import 'dart:async';
import '../model/store_category.dart';
import 'store_state.dart';

sealed class StoreEvent {
  const StoreEvent();
}

class ProductsRequested extends StoreEvent {
  const ProductsRequested({this.completion});
  final Completer<void>? completion;
}

class SearchChanged extends StoreEvent {
  const SearchChanged(this.query);
  final String query;
}

class CategorySelected extends StoreEvent {
  const CategorySelected(this.category);
  final StoreCategory category;
}

class SortChanged extends StoreEvent {
  const SortChanged(this.sort);
  final ProductSort sort;
}

class FavoriteToggled extends StoreEvent {
  const FavoriteToggled(this.productId);
  final int productId;
}

class FavoritesFilterToggled extends StoreEvent {
  const FavoritesFilterToggled();
}

class FiltersCleared extends StoreEvent {
  const FiltersCleared();
}

class ProductAddedToCart extends StoreEvent {
  const ProductAddedToCart(this.productId);
  final int productId;
}
