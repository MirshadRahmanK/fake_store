import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, required this.label});
  final String url;
  final String label;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.contain,
    semanticLabel: label,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
    errorBuilder: (_, error, stack) => const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 36,
      ),
    ),
  );
}
