# Flutter + GetX + Clean Architecture — Code Patterns Reference

This file contains production-ready patterns. Read the section relevant to what you're building.

## Table of Contents
1. [Entity Pattern](#entity-pattern)
2. [Model Pattern (with JSON serialization)](#model-pattern)
3. [Failure & Exception Handling](#failure--exception-handling)
4. [Repository Pattern (Abstract + Impl)](#repository-pattern)
5. [Use Case Pattern](#use-case-pattern)
6. [Data Source Pattern](#data-source-pattern)
7. [API Client Setup (Dio)](#api-client-setup)
8. [GetX Controller Patterns](#getx-controller-patterns)
9. [Page & Widget Patterns](#page--widget-patterns)
10. [Routing & Navigation](#routing--navigation)
11. [Theme & Design System Setup](#theme--design-system-setup)
12. [Form Validation Pattern](#form-validation-pattern)
13. [Pagination Pattern](#pagination-pattern)

---

## Entity Pattern

Entities are pure Dart. No Flutter imports, no serialization logic.

```dart
// domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, createdAt];
}
```

---

## Model Pattern

Models extend entities, adding serialization. Keep entities clean.

```dart
// data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
    );
  }
}
```

---

## Failure & Exception Handling

Define domain-level failures and data-level exceptions separately.

```dart
// core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

```dart
// core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'No internet connection'});
}
```

---

## Repository Pattern

Abstract in domain, implementation in data.

```dart
// domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
```

```dart
// data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) return Right(cachedUser);
      final remoteUser = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on CacheException {
      try {
        final remoteUser = await remoteDataSource.getCurrentUser();
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }
  }
}
```

---

## Use Case Pattern

Each use case does one thing. Uses `call()` so it can be invoked like a function.

```dart
// core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

```dart
// domain/usecases/login_user.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
```

---

## Data Source Pattern

```dart
// data/datasources/auth_remote_data_source.dart
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.currentUser);
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch user: $e');
    }
  }
}
```

---

## API Client Setup

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout
            Get.offAllNamed('/login');
          }
          handler.next(error);
        },
      ),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
```

---

## GetX Controller Patterns

### Basic controller with loading/error/success states

```dart
class ProductController extends GetxController {
  final GetProducts _getProducts;
  ProductController({required GetProducts getProducts}) : _getProducts = getProducts;

  final products = <ProductEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _getProducts(const NoParams());
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => products.assignAll(data),
    );
    isLoading.value = false;
  }

  Future<void> refresh() => fetchProducts();
}
```

### Controller with workers (reactive listeners)

```dart
class SearchController extends GetxController {
  final SearchProducts _searchProducts;
  SearchController({required SearchProducts searchProducts})
      : _searchProducts = searchProducts;

  final query = ''.obs;
  final results = <ProductEntity>[].obs;
  final isSearching = false.obs;

  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    _debounceWorker = debounce(
      query,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  Future<void> _performSearch() async {
    if (query.value.isEmpty) {
      results.clear();
      return;
    }
    isSearching.value = true;
    final result = await _searchProducts(SearchParams(query: query.value));
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => results.assignAll(data),
    );
    isSearching.value = false;
  }
}
```

---

## Page & Widget Patterns

### Page with loading/error/empty/content states

```dart
class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingSkeleton();
        }
        if (controller.errorMessage.isNotEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchProducts,
          );
        }
        if (controller.products.isEmpty) {
          return const _EmptyView();
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) => ProductCard(
              product: controller.products[index],
            ),
          ),
        );
      }),
    );
  }
}
```

### Reusable widget (decoupled from controller)

```dart
class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 80, height: 80,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Routing & Navigation

```dart
// routes/app_routes.dart
abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const productDetail = '/product/:id';
  static const profile = '/profile';
}
```

```dart
// routes/app_pages.dart
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductDetailBinding(),
    ),
  ];
}
```

```dart
// core/middleware/auth_middleware.dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
```

---

## Theme & Design System Setup

```dart
// core/theme/app_colors.dart
abstract class AppColors {
  // Primary
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF1D4ED8);

  // Neutral
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}
```

```dart
// core/theme/app_theme.dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
```

---

## Form Validation Pattern

```dart
// core/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
```

---

## Pagination Pattern

```dart
mixin PaginationMixin<T> on GetxController {
  final items = <T>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _currentPage = 1;
  final int _pageSize = 20;

  Future<List<T>> fetchPage(int page, int pageSize);

  Future<void> loadInitial() async {
    _currentPage = 1;
    isLoading.value = true;
    hasMore.value = true;
    try {
      final data = await fetchPage(_currentPage, _pageSize);
      items.assignAll(data);
      hasMore.value = data.length >= _pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      _currentPage++;
      final data = await fetchPage(_currentPage, _pageSize);
      items.addAll(data);
      hasMore.value = data.length >= _pageSize;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
```
