import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'features/store/model/product_repository.dart';
import 'features/store/presenter/store_event.dart';
import 'features/store/presenter/store_presenter.dart';
import 'features/store/view/store_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const FakeStoreApp());
}

class FakeStoreApp extends StatelessWidget {
  const FakeStoreApp({super.key, this.repository});
  final ProductRepository? repository;

  @override
  Widget build(BuildContext context) => RepositoryProvider<ApiClient>(
    create: (_) => ApiClient(),
    dispose: (api) => api.close(),
    child: Builder(
      builder: (context) => BlocProvider(
        create: (_) => StorePresenter(repository ?? StoreProductRepository(context.read<ApiClient>()),)..add(const ProductsRequested()),
        child: MaterialApp(
          title: 'Fake Store',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Urbanist',
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF171717),primary: const Color(0xFF171717),surface: Colors.white,),
            textTheme: const TextTheme(titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
            snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating,),
          ),
          home: const StorePage(),
        ),
      ),
    ),
  );
}
