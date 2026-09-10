import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fake_store/core/network/api_client.dart';
import 'package:fake_store/core/network/api_exception.dart';
import 'package:fake_store/features/store/model/product.dart';
import 'package:fake_store/features/store/model/product_repository.dart';
import 'package:fake_store/features/store/model/store_category.dart';
import 'package:fake_store/features/store/presenter/store_event.dart';
import 'package:fake_store/features/store/presenter/store_presenter.dart';
import 'package:fake_store/features/store/presenter/store_state.dart';

const shirt = Product(id: 1, title: 'Cotton Shirt', price: 20,
  category: "men's clothing", image: 'https://example.com/shirt.png',
  rating: 4.5, reviewCount: 12, description: 'A comfortable cotton shirt.');
const ring = Product(id: 2, title: 'Silver Ring', price: 45,
  category: 'jewelery', image: 'https://example.com/ring.png',
  rating: 4.8, reviewCount: 8, description: 'A simple silver ring.');

class TestRepository implements ProductRepository {
  TestRepository(this.load);
  final Future<List<Product>> Function() load;
  @override
  Future<List<Product>> getProducts() => load();
}

Future<void> send(StorePresenter presenter, StoreEvent event) async {
  final next = presenter.stream.first;
  presenter.add(event);
  await next;
}

void main() {
  group('API and repository', () {
    test('requests products, decodes fields and logs request/response', () async {
      final logs = <String>[];
      final api = ApiClient(logger: logs.add, client: MockClient((request) async {
        expect(request.url.toString(), 'https://fakestoreapi.com/products');
        expect(request.headers['Accept'], 'application/json');
        return http.Response(jsonEncode([{
          'id': 1, 'title': 'Cotton Shirt', 'price': 20,
          'description': 'A comfortable cotton shirt.', 'category': "men's clothing",
          'image': 'https://example.com/shirt.png', 'rating': {'rate': 4.5, 'count': 12},
        }]), 200, headers: {'set-cookie': 'private-cookie'});
      }));
      addTearDown(api.close);
      final products = await StoreProductRepository(api).getProducts();
      expect(products.single.description, shirt.description);
      expect(products.single.price, 20.0);
      expect(logs.join(), contains('REQUEST GET'));
      expect(logs.join(), contains('Status: 200'));
      expect(logs.join(), contains('Body:'));
      expect(logs.join(), isNot(contains('private-cookie')));
    });

    for (final status in [403, 429, 500]) {
      test('handles HTTP $status', () async {
        final api = ApiClient(client: MockClient((_) async => http.Response('error', status)));
        addTearDown(api.close);
        await expectLater(api.get('products'), throwsA(isA<ApiException>()));
      });
    }

    for (final body in ['not-json', '{}', '[{"id": 1}]']) {
      test('handles invalid response $body', () async {
        final api = ApiClient(client: MockClient((_) async => http.Response(body, 200)));
        addTearDown(api.close);
        await expectLater(StoreProductRepository(api).getProducts(), throwsA(isA<ApiException>()));
      });
    }

    test('handles connection failure', () async {
      final api = ApiClient(client: MockClient((_) async => throw http.ClientException('offline')));
      addTearDown(api.close);
      await expectLater(api.get('products'), throwsA(isA<ApiException>()
        .having((error) => error.message, 'message', contains('internet'))));
    });

    test('handles a timeout', () async {
      final api = ApiClient(timeout: const Duration(milliseconds: 1),
        client: MockClient((_) => Completer<http.Response>().future));
      addTearDown(api.close);
      await expectLater(api.get('products'), throwsA(isA<ApiException>()
        .having((error) => error.message, 'message', contains('too long'))));
    });
  });

  group('MVP presenter', () {
    test('loads, filters by title/category and sorts without more API calls', () async {
      var requests = 0;
      final presenter = StorePresenter(TestRepository(() async {
        requests++;
        return [shirt, ring];
      }));
      addTearDown(presenter.close);
      await presenter.refresh();
      expect(presenter.state.visibleProducts.first, ring);
      await send(presenter, const SearchChanged(' COTTON '));
      expect(presenter.state.visibleProducts, [shirt]);
      await send(presenter, const FiltersCleared());
      await send(presenter, const CategorySelected(StoreCategory.jewelry));
      expect(presenter.state.visibleProducts, [ring]);
      await send(presenter, const CategorySelected(StoreCategory.clothes));
      expect(presenter.state.visibleProducts, [shirt]);
      await send(presenter, const FiltersCleared());
      await send(presenter, const SortChanged(ProductSort.priceLow));
      expect(presenter.state.visibleProducts, [shirt, ring]);
      expect(requests, 1);
    });

    test('favorites and cart quantities survive filtering and refresh', () async {
      final presenter = StorePresenter(TestRepository(() async => [shirt, ring]));
      addTearDown(presenter.close);
      await presenter.refresh();
      await send(presenter, const FavoriteToggled(1));
      await send(presenter, const FavoritesFilterToggled());
      expect(presenter.state.visibleProducts, [shirt]);
      await send(presenter, const ProductAddedToCart(1));
      await send(presenter, const ProductAddedToCart(1));
      await send(presenter, const ProductAddedToCart(2));
      await presenter.refresh();
      expect(presenter.state.cart, {1: 2, 2: 1});
      expect(presenter.state.cartCount, 3);
      expect(presenter.state.favorites, {1});
      await send(presenter, const FavoriteToggled(1));
      expect(presenter.state.visibleProducts, isEmpty);
    });

    test('error survives search, retry recovers, failed refresh retains products', () async {
      var fail = true;
      final presenter = StorePresenter(TestRepository(() async {
        if (fail) throw const ApiException('Offline');
        return [shirt];
      }));
      addTearDown(presenter.close);
      await presenter.refresh();
      expect(presenter.state.status, StoreStatus.failure);
      await send(presenter, const SearchChanged('shirt'));
      expect(presenter.state.error, 'Offline');
      fail = false;
      await presenter.refresh();
      expect(presenter.state.status, StoreStatus.ready);
      expect(presenter.state.error, isNull);
      fail = true;
      await presenter.refresh();
      expect(presenter.state.products, [shirt]);
      expect(presenter.state.error, 'Offline');
    });

    test('empty API results are a successful empty state', () async {
      final presenter = StorePresenter(TestRepository(() async => []));
      addTearDown(presenter.close);
      await presenter.refresh();
      expect(presenter.state.status, StoreStatus.ready);
      expect(presenter.state.visibleProducts, isEmpty);
    });
  });
}
