import 'package:flutter/material.dart';
import '../../model/store_category.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final StoreCategory selected;
  final ValueChanged<StoreCategory> onSelected;

  static const _icons = [
    Icons.checkroom_rounded,
    Icons.ice_skating_rounded,
    Icons.shopping_bag_rounded,
    Icons.devices_rounded,
    Icons.watch_rounded,
    Icons.diamond_outlined,
    Icons.soup_kitchen_rounded,
    Icons.smart_toy_rounded,
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      runSpacing: 20,
      children: List.generate(8, (index) {
        final category = StoreCategory.values[index + 1];
        final active = selected == category;
        return SizedBox(
          width: constraints.maxWidth / 4,
          child: Semantics(
            button: true,
            selected: active,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => onSelected(category),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? const Color(0xFF202020)
                          : const Color(0xFFEDEDED),
                    ),
                    child: Icon(
                      _icons[index],
                      size: 27,
                      color: active ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final StoreCategory selected;
  final ValueChanged<StoreCategory> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: StoreCategory.values
          .map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                showCheckmark: false,
                onSelected: (_) => onSelected(category),
                labelStyle: TextStyle(
                  color: selected == category
                      ? Colors.white
                      : const Color(0xFF202020),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                selectedColor: const Color(0xFF202020),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(
                  side: BorderSide(color: Color(0xFF202020), width: 1.7),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}
