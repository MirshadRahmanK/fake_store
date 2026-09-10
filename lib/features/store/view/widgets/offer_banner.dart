import 'package:flutter/material.dart';

class OfferBanner extends StatefulWidget {
  const OfferBanner({super.key});

  @override
  State<OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<OfferBanner> {
  int _page = 0;
  static const _offers = [
    (
      '30%',
      'Today’s Special!',
      'Get discount for every\norder, only valid for today',
    ),
    (
      'NEW',
      'Everyday essentials',
      'Discover something new\nfor your everyday style',
    ),
    (
      'EDIT',
      'Made for your style',
      'A little inspiration for\nyour next favorite find',
    ),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180 + (MediaQuery.textScalerOf(context).scale(16) - 16) * 4,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _offers.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/offer.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  color: Colors.grey,
                  colorBlendMode: BlendMode.saturation,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE6E6E6),
                        Color(0xFFE6E6E6),
                        Color(0x00E6E6E6),
                      ],
                      stops: [0, .42, .87],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 22, 18, 26),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _offers[index].$1,
                        style: const TextStyle(
                          fontSize: 39,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        _offers[index].$2,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _offers[index].$3,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 11,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _offers.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  width: _page == index ? 17 : 4,
                  decoration: BoxDecoration(
                    color: _page == index
                        ? const Color(0xFF202020)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
