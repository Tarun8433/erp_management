import 'dart:developer';

import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';

/// A category or caste (sub-category) option from the master APIs.
class CategoryOption {
  final int id;
  final String name;
  const CategoryOption(this.id, this.name);
}

/// Fetches Category (General/OBC/SC/ST) and Caste (sub-category) master lists.
class CategoryService {
  final ApiService _api = ApiService();

  Future<List<CategoryOption>> getCategories() async {
    try {
      final res = await _api.postJson(Endpoints.getCategories(), {'userId': 0});
      return _parse(res, idKey: 'categoryId', nameKey: 'categoryName');
    } catch (e) {
      log('CategoryService.getCategories error: $e');
      return const [];
    }
  }

  Future<List<CategoryOption>> getSubCategories(int categoryId) async {
    try {
      final res = await _api.postJsonWithoutBody(
        Endpoints.getSubCategories(categoryId),
      );
      return _parse(res, idKey: 'id', nameKey: 'subCategoryName');
    } catch (e) {
      log('CategoryService.getSubCategories error: $e');
      return const [];
    }
  }

  List<CategoryOption> _parse(
    dynamic res, {
    required String idKey,
    required String nameKey,
  }) {
    final List<dynamic> list = res is List
        ? res
        : (res is Map<String, dynamic>
            ? (res['result'] ?? res['data'] ?? const [])
            : const []);
    final out = <CategoryOption>[];
    for (final e in list) {
      if (e is Map) {
        final name = (e[nameKey] ?? '').toString();
        if (name.isEmpty) continue;
        final raw = e[idKey];
        final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
        out.add(CategoryOption(id, name));
      }
    }
    return out;
  }
}
