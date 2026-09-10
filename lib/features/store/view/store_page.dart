import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/product.dart';
import '../presenter/store_event.dart';
import '../presenter/store_presenter.dart';
import '../presenter/store_state.dart';
import 'product_detail_page.dart';
import 'widgets/category_picker.dart';
import 'widgets/offer_banner.dart';
import 'widgets/product_card.dart';
import 'widgets/store_bottom_bar.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  StorePresenter get _presenter => context.read<StorePresenter>();

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _search.clear();
    _presenter.add(const FiltersCleared());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<StorePresenter, StoreState>(
    builder: (context, state) => Scaffold(
      bottomNavigationBar: StoreBottomBar(
        cartCount: state.cartCount,
        onHome: () {
          _clearFilters();
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        onCart: () => _showCartSheet(state),
        onPlaceholder: (label) => switch (label) {
          'Orders' => _showWorkInProgressSheet('My Orders',CupertinoIcons.cart,'Work in Progress',),
          'Wallet' => _showWorkInProgressSheet('Wallet & Payments',Icons.account_balance_wallet_outlined,'Work in Progress',),
          'Profile' => _showWorkInProgressSheet('User Profile',CupertinoIcons.person,'Work in Progress',),
          _ => _showWorkInProgressSheet('Work in Progress',Icons.construction_rounded,'Work in Progress',),
        },
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              onRefresh: _presenter.refresh,
              child: CustomScrollView(
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    sliver: SliverList.list(
                      children: [
                        _header(state),
                        const SizedBox(height: 20),
                        _searchField(state),
                        const SizedBox(height: 18),
                        _sectionTitle('Special Offers',() => _showMessage('Work in Progress'),),
                        const SizedBox(height: 15),
                        const OfferBanner(),
                        const SizedBox(height: 22),
                        CategoryPicker(selected: state.category,onSelected: (category) => _presenter.add(CategorySelected(category)),),
                        const SizedBox(height: 20),
                        _sectionTitle(state.onlyFavorites? 'Your Favorites': 'Most Popular',_clearFilters,),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CategoryTabs(
                      selected: state.category,
                      onSelected: (category) =>_presenter.add(CategorySelected(category)),
                    ),
                  ),
                  if (state.status == StoreStatus.loading &&
                      state.products.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    ),
                  if (state.error != null && state.products.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _message(
                          Icons.wifi_off_rounded,
                          'Couldn’t refresh',
                          state.error!,
                          'Try again',
                          () => _presenter.add(const ProductsRequested()),
                        ),
                      ),
                    ),
                  ..._productSlivers(state),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void _showWorkInProgressSheet(
    String title,
    IconData icon,
    String description,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28)),),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,borderRadius: BorderRadius.circular(2),),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: Color(0xFFF5F5F5),shape: BoxShape.circle,),
              child: Icon(icon, size: 38, color: const Color(0xFF202020)),
            ),
            const SizedBox(height: 18),
            Text(title,style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0),borderRadius: BorderRadius.circular(12),),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded, size: 15, color: Color(0xFFE65100)),
                  SizedBox(width: 6),
                  Text('Work in Progress',style: TextStyle(color: Color(0xFFE65100),fontWeight: FontWeight.w700,fontSize: 12,),),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF202020),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(16),),
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(StoreState state) {
    final cartItems = state.cart.entries.map((entry) {
          final product = state.products.cast<Product?>().firstWhere((p) => p?.id == entry.key,orElse: () => null,);
          return product != null ? (product: product, quantity: entry.value) : null;
        }).whereType<({Product product, int quantity})>().toList();

    final totalPrice = cartItems.fold<double>( 0.0,(total, item) => total + (item.product.price * item.quantity),);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: cartItems.isEmpty ? 0.45 : 0.65,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Shopping Cart (${state.cartCount})',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.construction_rounded, size: 14, color: Color(0xFFE65100)),
                        SizedBox(width: 4),
                        Text(
                          'Work in Progress',
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (cartItems.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.bag, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap "Add to Cart" on products to see them here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(
                              item.product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.product.price.toStringAsFixed(2)}  x${item.quantity}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage('Work in Progress');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF202020),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Checkout (Work in Progress)', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _productSlivers(StoreState state) {
    if (state.products.isEmpty &&
        (state.status == StoreStatus.loading ||
            state.status == StoreStatus.initial)) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(64),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 16),
                  Text('Finding your next favorite…'),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    if (state.status == StoreStatus.failure && state.products.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: _message(
              Icons.cloud_off_rounded,
              'Let’s try that again',
              state.error!,
              'Retry',
              () => _presenter.add(const ProductsRequested()),
            ),
          ),
        ),
      ];
    }
    final products = state.visibleProducts;
    if (products.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: _message(
              Icons.search_off_rounded,
              'No products found',
              state.onlyFavorites
                  ? 'Tap a heart on a product to save it here.'
                  : 'No products match this selection. Try another category or search.',
              'Show all products',
              _clearFilters,
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.crossAxisExtent - 18) / 2;
            final textScale = MediaQuery.textScalerOf(context).scale(18) / 18;
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 24,
                mainAxisExtent: width + 98 * textScale,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  isFavorite: state.favorites.contains(product.id),
                  onFavorite: () => _presenter.add(FavoriteToggled(product.id)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  ),
                );
              }, childCount: products.length),
            );
          },
        ),
      ),
    ];
  }

  Widget _header(StoreState state) => Row(
    children: [
      const CircleAvatar(
        radius: 23,
        backgroundColor: Color(0xFFEAE6E0),
        child: Icon(
          CupertinoIcons.person_fill,
          color: Color(0xFF72665B),
          size: 30,
        ),
      ),
      const SizedBox(width: 13),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning 👋',
              style: TextStyle(color: Color(0xFF757575), fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Andrew Ainsley',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Notifications',
        onPressed: () =>
            _showMessage('You’re all caught up. No notifications.'),
        icon: const Icon(CupertinoIcons.bell, size: 24),
      ),
      IconButton(
        tooltip: 'Wishlist',
        onPressed: () => _showMessage('Wishlist is a visual placeholder in this demo.'),
        icon: const Icon(CupertinoIcons.heart, size: 25),
      ),
    ],
  );

  Widget _searchField(StoreState state) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(15),
    ),
    child: TextField(
      controller: _search,
      onChanged: (query) => _presenter.add(SearchChanged(query)),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Color(0xFFB5B5B5), fontSize: 14),
        prefixIcon: const Icon(
          CupertinoIcons.search,
          color: Color(0xFFB5B5B5),
          size: 21,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        suffixIcon: IconButton(
          tooltip: 'Filter',
          onPressed: () => _showMessage('Filter is a visual placeholder in this demo.'),
          icon: const Icon(
            CupertinoIcons.slider_horizontal_3,
            color: Color(0xFF202020),
            size: 21,
          ),
        ),
      ),
    ),
  );

  Widget _sectionTitle(String title, VoidCallback onSeeAll) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      TextButton(
        onPressed: onSeeAll,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(58, 32),
        ),
        child: const Text(
          'See All',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );

  Widget _message(
    IconData icon,
    String title,
    String detail,
    String action,
    VoidCallback onTap,
  ) => Column(
    children: [
      Icon(icon, size: 42, color: Colors.grey),
      const SizedBox(height: 15),
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(detail, textAlign: TextAlign.center),
      const SizedBox(height: 14),
      FilledButton(onPressed: onTap, child: Text(action)),
    ],
  );
}
