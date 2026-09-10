import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/product.dart';
import '../presenter/store_event.dart';
import '../presenter/store_presenter.dart';
import '../presenter/store_state.dart';
import 'widgets/product_image.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => BlocBuilder<StorePresenter, StoreState>(
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Semantics(
              label: 'Cart, ${state.cartCount} items',
              child: Badge(
                isLabelVisible: state.cartCount > 0,
                backgroundColor: Colors.black,
                label: Text('${state.cartCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                height: 310,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ProductImage(url: product.image, label: product.title),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: state.favorites.contains(product.id)
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: () => context.read<StorePresenter>().add(
                      FavoriteToggled(product.id),
                    ),
                    icon: Icon(
                      state.favorites.contains(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.category,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 21),
                  const SizedBox(width: 6),
                  Text(
                    '${product.rating.toStringAsFixed(1)}  •  ${product.reviewCount} reviews',
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                product.description,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                ),
                onPressed: () {
                  context.read<StorePresenter>().add(
                    ProductAddedToCart(product.id),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Added to your cart')),
                    );
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
