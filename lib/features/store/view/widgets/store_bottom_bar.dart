import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoreBottomBar extends StatelessWidget {
  const StoreBottomBar({
    super.key,
    required this.cartCount,
    required this.onHome,
    required this.onCart,
    required this.onPlaceholder,
  });
  final int cartCount;
  final VoidCallback onHome;
  final VoidCallback onCart;
  final ValueChanged<String> onPlaceholder;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (CupertinoIcons.bag, 'Cart'),
      (CupertinoIcons.cart, 'Orders'),
      (Icons.account_balance_wallet_outlined, 'Wallet'),
      (CupertinoIcons.person, 'Profile'),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F3F3))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: InkWell(
                          onTap: () => switch (item.$2) {
                            'Home' => onHome(),
                            'Cart' => onCart(),
                            _ => onPlaceholder(item.$2),
                          },
                          child: Semantics(
                            button: true,
                            selected: item.$2 == 'Home',
                            label: item.$2 == 'Cart'
                                ? 'Cart, $cartCount items'
                                : item.$2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Badge(
                                  isLabelVisible:
                                      item.$2 == 'Cart' && cartCount > 0,
                                  backgroundColor: Colors.black,
                                  label: Text('$cartCount'),
                                  child: Icon(
                                    item.$1,
                                    size: 23,
                                    color: item.$2 == 'Home'
                                        ? Colors.black
                                        : const Color(0xFFBDBDBD),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.$2,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: item.$2 == 'Home'
                                        ? Colors.black
                                        : const Color(0xFFBDBDBD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
