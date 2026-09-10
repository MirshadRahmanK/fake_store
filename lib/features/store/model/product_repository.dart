import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts();
}

class StoreProductRepository implements ProductRepository {
  StoreProductRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> getProducts() async {
    final data = await _api.get('products');
    try {
      if (data is! List) throw const FormatException('Expected product list');
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Expected product object');
            }
            return Product.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException {
      throw const ApiException(
        'Some product information could not be read. Please try again.',
      );
    }
  }
}
