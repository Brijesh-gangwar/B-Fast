
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../secrets.dart'; // Replace with your actual secrets file

class ProductProvider extends ChangeNotifier {
  /// Main HomeScreen product list
  final List<Product> _homeProducts = [];

  /// Category-specific product lists
  final Map<String, List<Product>> _categoryProducts = {};

  /// Pagination cursors
  String? _homeCursor;
  final Map<String, String?> _categoryCursors = {};

  /// Done flags
  bool _homeDone = false;
  final Map<String, bool> _categoryDone = {};

  /// Loading flag (global)
  bool _isLoading = false;

  /// Per-category loading to avoid cross-category blocking
  final Map<String, bool> _categoryLoading = {};

  /// Currently selected filters
  String? _selectedCategory;
  List<String>? _selectedTags;

  // ======= Getters =======
  List<Product> get homeProducts => List.unmodifiable(_homeProducts);
  List<Product> getCategoryProducts(String category) =>
      List.unmodifiable(_categoryProducts[category] ?? []);

  bool get isLoading => _isLoading;

  bool get isDone => _selectedCategory != null
      ? (_categoryDone[_selectedCategory!] ?? false)
      : _homeDone;

  String? get selectedCategory => _selectedCategory;
  List<String>? get selectedTags => _selectedTags;

  // ======= Filters =======
  void setFilters({String? category, List<String>? tags}) {
    _selectedCategory =
    (category != null && category.isNotEmpty) ? category : null;
    _selectedTags = tags;
    notifyListeners();
  }

  // ======= HomeScreen Methods =======

  /// Fetch initial home products (or subsequent pages)
  Future<void> fetchHomeProducts({int limit = 20}) async {
    if (_isLoading || _homeDone) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await fetchProducts(
        cursor: _homeCursor,
        limit: limit,
        category: null,
      );

      _homeProducts.addAll(result['products']);
      _homeCursor = result['continueCursor'];
      _homeDone = result['isDone'];
    } catch (e) {
      debugPrint("❌ Error fetching home products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch next page of home products (for infinite scroll)
  Future<void> fetchMoreHomeProducts({int limit = 20}) async {
    if (_isLoading || _homeDone) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await fetchProducts(
        cursor: _homeCursor,
        limit: limit,
        category: null,
      );

      _homeProducts.addAll(result['products']);
      _homeCursor = result['continueCursor'];
      _homeDone = result['isDone'];
    } catch (e) {
      debugPrint("❌ Error fetching more home products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshHomeProducts({int limit = 20}) async {
    _homeProducts.clear();
    _homeCursor = null;
    _homeDone = false;
    notifyListeners();

    while (!_homeDone) {
      await fetchHomeProducts(limit: limit);
    }
  }

  // ======= Category Methods (updated) =======

  Future<void> fetchCategoryProducts(String category, {int limit = 20}) async {
    // Avoid concurrent loads for the same category
    if (_categoryLoading[category] == true) return;

    // If category already completed and has data, no need to fetch more
    if ((_categoryDone[category] ?? false) &&
        (_categoryProducts[category]?.isNotEmpty ?? false)) {
      return;
    }

    _categoryLoading[category] = true;
    _isLoading = true;
    notifyListeners();

    try {
      // Ensure maps are initialized for this category
      _categoryProducts.putIfAbsent(category, () => <Product>[]);
      _categoryCursors.putIfAbsent(category, () => null);
      _categoryDone.putIfAbsent(category, () => false);

      final cursor = _categoryCursors[category];

      final result = await fetchProducts(
        cursor: cursor,
        limit: limit,
        category: category,
        tags: _selectedTags, // use current UI-selected tags
      );

      final list = _categoryProducts[category]!;
      list.addAll(result['products'] as List<Product>);
      _categoryProducts[category] = list;

      _categoryCursors[category] = result['continueCursor'] as String?;
      _categoryDone[category] = (result['isDone'] as bool?) ?? false;
    } catch (e) {
      debugPrint("❌ Error fetching category products ($category): $e");
    }

    _categoryLoading[category] = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCategoryProducts(String category, {int limit = 20}) async {
    // Reset only this category's pagination and data
    _categoryProducts[category] = <Product>[];
    _categoryCursors[category] = null;
    _categoryDone[category] = false;

    notifyListeners();

    // Fetch first page again with current filters
    await fetchCategoryProducts(category, limit: limit);
  }

  // ======= API Method =======
  Future<Map<String, dynamic>> fetchProducts({
    String? cursor,
    int limit = 20,
    String? category,
    List<String>? tags,
  }) async {
    Uri uri;

    if (category != null && category.isNotEmpty) {
      // Category-specific endpoint
      final queryParams = {
        'category': category,
        'tags': (tags != null && tags.isNotEmpty) ? tags.join(',') : '',
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
      };
      uri = Uri.parse('$baseurl/products/getByCategory')
          .replace(queryParameters: queryParams);
    } else {
      // Home products endpoint
      final queryParams = {
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
      };
      uri = Uri.parse('$baseurl/products/getAll')
          .replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> pageData = data['page'] ?? [];

      return {
        'products': pageData.map((json) => Product.fromJson(json)).toList(),
        'continueCursor': data['continueCursor'],
        'isDone': data['isDone'] ?? false,
      };
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
