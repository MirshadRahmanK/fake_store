import '../model/product.dart';
import '../model/store_category.dart';

enum StoreStatus { initial, loading, ready, failure }

enum ProductSort {
  popular('Most popular'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low');

  const ProductSort(this.label);
  final String label;
}

class StoreState {
  const StoreState({
    this.status = StoreStatus.initial,
    this.products = const [],
    this.query = '',
    this.category = StoreCategory.all,
    this.sort = ProductSort.popular,
    this.favorites = const {},
    this.onlyFavorites = false,
    this.cart = const {},
    this.error,
  });

  final Map<int, int> cart;
  int get cartCount =>
      cart.values.fold(0, (total, quantity) => total + quantity);

  final StoreStatus status;
  final List<Product> products;
  final String query;
  final StoreCategory category;
  final ProductSort sort;
  final Set<int> favorites;
  final bool onlyFavorites;
  final String? error;

  List<Product> get visibleProducts {
    final search = query.trim().toLowerCase();
    final result = products
        .where(
          (product) =>
              category.includes(product) &&
              (search.isEmpty ||
                  product.title.toLowerCase().contains(search)) &&
              (!onlyFavorites || favorites.contains(product.id)),
        )
        .toList();
    result.sort(
      (a, b) => switch (sort) {
        ProductSort.popular => b.rating.compareTo(a.rating),
        ProductSort.priceLow => a.price.compareTo(b.price),
        ProductSort.priceHigh => b.price.compareTo(a.price),
      },
    );
    return result;
  }

  StoreState copyWith({
    StoreStatus? status,
    List<Product>? products,
    String? query,
    StoreCategory? category,
    ProductSort? sort,
    Set<int>? favorites,
    bool? onlyFavorites,
    Map<int, int>? cart,
    String? error,
    bool clearError = false,
  }) => StoreState(
    status: status ?? this.status,
    products: products == null ? this.products : List.unmodifiable(products),
    query: query ?? this.query,
    category: category ?? this.category,
    sort: sort ?? this.sort,
    favorites: favorites == null ? this.favorites : Set.unmodifiable(favorites),
    onlyFavorites: onlyFavorites ?? this.onlyFavorites,
    cart: cart == null ? this.cart : Map.unmodifiable(cart),
    error: clearError ? null : error ?? this.error,
  );
}
