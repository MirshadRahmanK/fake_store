# Fake Store — Flutter Product Listing App

A clean, responsive, and robust Flutter application built for the **Flutter Developer UI-to-Code Challenge**. The app fetches live product data from the [Fake Store API](https://fakestoreapi.com/products), faithfully recreates the reference design with high visual fidelity, handles edge cases (loading, error, empty search), and implements state management for shopping cart and favorites.

---

## 📱 Features

- **Home / Product Listing Screen**:
  - **Header**: Greeting, avatar, notification, and wishlist counter.
  - **Live Search Bar**: Filters products in real-time by title as the user types, with sorting options (Most Popular, Price Low to High, Price High to Low).
  - **Special Offers Carousel**: Interactive banner slider matching reference design aesthetics.
  - **Category Grid**: 8 icon categories (Clothes, Shoes, Bags, Electronics, Watch, Jewelry, Kitchen, Toys) wired directly to product categories & keyword matches.
  - **Category Filter Tabs**: Horizontal scrollable chips ("All", "Clothes", "Shoes", "Bags", etc.) for rapid filtering.
  - **2-Column Product Grid**: Cards displaying product image, title, rating, review count badge, price, and interactive favorite heart toggle.
  - **Bottom Navigation Bar**: Persistent navigation with live cart badge indicator.
- **Product Detail Screen**:
  - Full product image preview with proper scaling.
  - Title, rating breakdown, category, and full product description.
  - Sticky bottom action bar displaying price and **Add to Cart** button.
  - Top app bar showing real-time cart badge counter.
- **State Handling**:
  - **Loading**: Custom loading indicator during initial fetch.
  - **Error State**: Friendly error UI with a **Retry** button for network failures.
  - **Empty State**: Clear guidance when search or category filter yields no products.
  - **Pull-to-Refresh**: Refresh product catalogue via standard swipe gesture.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.0.0` or higher

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd fake_store
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

4. **Run test suite**:
   ```bash
   flutter test
   ```

---

## 🛠️ Architecture & Technical Choices

### Folder Structure
The codebase follows **Clean Architecture** principles structured by features and core concerns:

```
lib/
├── core/
│   └── network/
│       ├── api_client.dart          # HTTP client wrapper with logging, headers, and timeouts
│       └── api_exception.dart       # User-friendly custom exception classes
├── features/
│   └── store/
│       ├── model/
│       │   ├── product.dart          # Product data model with strict JSON parsing & validation
│       │   ├── product_repository.dart # Abstract repository interface & implementation
│       │   └── store_category.dart   # Category enum with mapping & filter logic
│       ├── presenter/
│       │   ├── store_event.dart      # BLoC events (fetch, search, filter, sort, favorite, cart)
│       │   ├── store_presenter.dart  # BLoC presenter managing presentation state logic
│       │   └── store_state.dart      # Immutable store state with computed getters
│       └── view/
│           ├── store_page.dart       # Main home product listing screen
│           ├── product_detail_page.dart # Product detail screen
│           └── widgets/             # Decomposed UI components
│               ├── category_picker.dart
│               ├── offer_banner.dart
│               ├── product_card.dart
│               ├── product_image.dart
│               └── store_bottom_bar.dart
└── main.dart                        # Application entry point & BLoC providers
```

### Why BLoC (`flutter_bloc`)?
- **Separation of Concerns**: Business logic and state mutations are strictly isolated from UI widgets.
- **Predictability & Testability**: Unidirectional data flow (Events -> State) makes testing edge cases, filtering, and cart state straightforward.
- **State Granularity**: Computed getters on `StoreState` (e.g. `visibleProducts`, `cartCount`) compute filtered subsets efficiently without unnecessary re-renders.

### Networking & Data Handling
- Utilizes Dart's standard `http` package wrapped inside a dedicated `ApiClient`.
- Includes request/response logging (in debug mode) with authorization/cookie headers stripped for security.
- Comprehensive exception mapping (`TimeoutException`, `ClientException`, `FormatException`, HTTP status code handling) converting raw network errors into clear, actionable UI error messages.

---

## 🧪 Testing

The repository includes a comprehensive test suite covering both unit logic and widget interactions:

- **Unit Tests** (`test/store_test.dart`):
  - API response parsing and error handling (403, 429, 500, invalid JSON, timeouts).
  - BLoC event handling, real-time title search, category filtering, and sorting.
  - Cart item additions and wishlist toggles.
- **Widget Tests** (`test/store_widget_test.dart`):
  - Full UI interaction flow: searching, tapping product card, navigating to detail page, toggling favorites, and adding to cart.
  - Visual state transitions: loading, error + retry action, and empty results.
  - Responsiveness across different screen widths (320px, 430px, 800px).

---

## 📌 API Reference

- **Endpoint**: `GET https://fakestoreapi.com/products`
- **Response**: Array of product objects containing `id`, `title`, `price`, `category`, `description`, `image`, and `rating` (`rate`, `count`).

---

## 💡 Trade-offs & Assumptions

1. **Category Mapping**: The Fake Store API provides four native category strings (`electronics`, `jewelery`, `men's clothing`, `women's clothing`). To match the 8 category icons in the design mockup, keyword regex matching is used for categories like `Bags`, `Shoes`, `Watch`, `Kitchen`, and `Toys`.
2. **Search Logic**: Search filtering happens in-memory over the fetched products list as requested by the specification, avoiding redundant network calls.
# fake_store
