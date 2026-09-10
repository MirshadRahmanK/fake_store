import 'product.dart';

enum StoreCategory {
  all('All'),
  clothes('Clothes'),
  shoes('Shoes'),
  bags('Bags'),
  electronics('Electronics'),
  watch('Watch'),
  jewelry('Jewelry'),
  kitchen('Kitchen'),
  toys('Toys');

  const StoreCategory(this.label);
  final String label;

  bool includes(Product product) {
    final title = product.title.toLowerCase();
    return switch (this) {
      all => true,
      clothes =>
        product.category == "men's clothing" ||
            product.category == "women's clothing",
      electronics => product.category == 'electronics',
      jewelry => product.category == 'jewelery',
      bags => RegExp(r'\b(bag|backpack|handbag|purse)\b').hasMatch(title),
      shoes => RegExp(
        r'\b(shoe|shoes|sneaker|sneakers|boot|boots)\b',
      ).hasMatch(title),
      watch => RegExp(r'\b(watch|watches)\b').hasMatch(title),
      kitchen => RegExp(r'\b(kitchen|pan|cookware|kettle)\b').hasMatch(title),
      toys => RegExp(r'\b(toy|toys|doll|puzzle)\b').hasMatch(title),
    };
  }
}
