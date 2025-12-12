import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/product.dart';

enum PurchasedFilter { all, today, thisMonth, thisYear, specificDay }

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _productsToBuy = [];
  List<Product> _purchasedProducts = [];
  PurchasedFilter _currentFilter = PurchasedFilter.all;
  DateTime? _selectedDayFilter;

  List<Product> get productsToBuy => _productsToBuy;
  List<Product> get purchasedProducts => _filteredPurchasedProducts;
  PurchasedFilter get currentFilter => _currentFilter;
  DateTime? get selectedDayFilter => _selectedDayFilter;

  ProductProvider() {
    loadProducts();
  }

  List<Product> get _filteredPurchasedProducts {
    final now = DateTime.now();

    switch (_currentFilter) {
      case PurchasedFilter.today:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.isAfter(startOfDay) &&
              product.purchasedAt!.isBefore(endOfDay);
        }).toList();

      case PurchasedFilter.thisMonth:
        return _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.year == now.year &&
              product.purchasedAt!.month == now.month;
        }).toList();

      case PurchasedFilter.thisYear:
        return _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.year == now.year;
        }).toList();

      case PurchasedFilter.specificDay:
        final date = _selectedDayFilter ?? now;
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        return _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.isAfter(startOfDay) &&
              product.purchasedAt!.isBefore(endOfDay);
        }).toList();

      case PurchasedFilter.all:
        return _purchasedProducts;
    }
  }

  Future<void> loadProducts() async {
    _productsToBuy = await _dbHelper.getProductsToBuy();
    _purchasedProducts = await _dbHelper.getPurchasedProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.createProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
    await loadProducts();
  }

  Future<void> purchaseProduct(
    Product product,
    double price,
    String? store,
  ) async {
    final updatedProduct = product.copyWith(
      isPurchased: true,
      price: price,
      store: store,
      purchasedAt: DateTime.now(),
    );
    await _dbHelper.updateProduct(updatedProduct);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    await loadProducts();
  }

  void setFilter(PurchasedFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setFilterDay(DateTime day) {
    _selectedDayFilter = day;
    _currentFilter = PurchasedFilter.specificDay;
    notifyListeners();
  }

  Future<String> exportToJson() async {
    final products = await _dbHelper.getAllProducts();
    final data =
        products.map((p) {
          final map = p.toMap();
          map.remove('id');
          return map;
        }).toList();
    return jsonEncode(data);
  }

  Future<int> importFromJsonString(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    final List list =
        decoded is Map<String, dynamic>
            ? List.from(decoded['products'] ?? [])
            : List.from(decoded as List);

    int count = 0;
    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      final product = Product(
        id: null,
        name: map['name'] as String,
        quantity: map['quantity'] as int,
        category: ProductCategoryExtension.fromString(
          map['category'] as String,
        ),
        price: (map['price'] as num?)?.toDouble(),
        store: map['store'] as String?,
        isPurchased:
            map['isPurchased'] is int
                ? (map['isPurchased'] == 1)
                : (map['isPurchased'] as bool? ?? false),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        purchasedAt:
            map['purchasedAt'] != null
                ? DateTime.fromMillisecondsSinceEpoch(map['purchasedAt'] as int)
                : null,
      );
      await _dbHelper.createProduct(product);
      count++;
    }

    await loadProducts();
    return count;
  }

  // Report data grouped by category for a specific month
  Map<ProductCategory, Map<String, dynamic>> getMonthlyReport(
    int year,
    int month,
  ) {
    final monthProducts =
        _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.year == year &&
              product.purchasedAt!.month == month;
        }).toList();

    final Map<ProductCategory, Map<String, dynamic>> report = {};

    for (var product in monthProducts) {
      if (!report.containsKey(product.category)) {
        report[product.category] = {
          'totalSpent': 0.0,
          'quantity': 0,
          'items': <Product>[],
        };
      }

      report[product.category]!['totalSpent'] += product.price ?? 0.0;
      report[product.category]!['quantity'] += product.quantity;
      (report[product.category]!['items'] as List<Product>).add(product);
    }

    return report;
  }

  // Get total spent in a specific month
  double getTotalSpentInMonth(int year, int month) {
    final report = getMonthlyReport(year, month);
    double total = 0.0;
    report.forEach((_, data) {
      total += data['totalSpent'] as double;
    });
    return total;
  }

  // Report data grouped by category for a specific day
  Map<ProductCategory, Map<String, dynamic>> getDailyReport(
    int year,
    int month,
    int day,
  ) {
    final startOfDay = DateTime(year, month, day);
    final endOfDay = DateTime(year, month, day, 23, 59, 59);

    final dayProducts =
        _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.isAfter(startOfDay) &&
              product.purchasedAt!.isBefore(endOfDay);
        }).toList();

    final Map<ProductCategory, Map<String, dynamic>> report = {};

    for (var product in dayProducts) {
      if (!report.containsKey(product.category)) {
        report[product.category] = {
          'totalSpent': 0.0,
          'quantity': 0,
          'items': <Product>[],
        };
      }

      report[product.category]!['totalSpent'] += product.price ?? 0.0;
      report[product.category]!['quantity'] += product.quantity;
      (report[product.category]!['items'] as List<Product>).add(product);
    }

    return report;
  }

  // Get total spent on a specific day
  double getTotalSpentOnDay(int year, int month, int day) {
    final report = getDailyReport(year, month, day);
    double total = 0.0;
    report.forEach((_, data) {
      total += data['totalSpent'] as double;
    });
    return total;
  }

  // Get spending evolution for the last N months
  List<Map<String, dynamic>> getSpendingEvolution(int numberOfMonths) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> evolution = [];

    for (int i = numberOfMonths - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final total = getTotalSpentInMonth(date.year, date.month);

      evolution.add({
        'year': date.year,
        'month': date.month,
        'total': total,
        'date': date,
      });
    }

    return evolution;
  }

  // Salary methods
  Future<void> setSalary(int year, int month, double amount) async {
    await _dbHelper.setSalary(year, month, amount);
    notifyListeners();
  }

  Future<double?> getSalary(int year, int month) async {
    return await _dbHelper.getSalary(year, month);
  }

  Future<Map<String, double>> getAllSalaries() async {
    return await _dbHelper.getAllSalaries();
  }

  // Get spending distribution for pie chart (including remaining salary)
  // Returns a map with category enum as key for proper localization in UI
  Future<Map<dynamic, double>> getSpendingDistribution(
    int year,
    int month,
  ) async {
    final report = getMonthlyReport(year, month);
    final salary = await getSalary(year, month);
    final Map<dynamic, double> distribution = {};

    double totalSpent = 0.0;

    // Add each category spending (using enum as key)
    report.forEach((category, data) {
      final amount = data['totalSpent'] as double;
      distribution[category] = amount;
      totalSpent += amount;
    });

    // Add remaining salary if salary is set
    if (salary != null && salary > 0) {
      final remaining = salary - totalSpent;
      if (remaining > 0) {
        distribution['remaining'] = remaining; // String key for remaining
      }
    }

    return distribution;
  }

  // Get products purchased in the previous month
  List<Product> getPreviousMonthProducts() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);

    return _purchasedProducts.where((product) {
      if (product.purchasedAt == null) return false;
      return product.purchasedAt!.year == previousMonth.year &&
          product.purchasedAt!.month == previousMonth.month;
    }).toList();
  }

  // Add multiple products from previous month
  Future<void> addProductsFromPreviousMonth(List<Product> products) async {
    for (final product in products) {
      final newProduct = Product(
        name: product.name,
        quantity: product.quantity,
        category: product.category,
        isPurchased: false,
        createdAt: DateTime.now(),
      );
      await _dbHelper.createProduct(newProduct);
    }
    await loadProducts();
  }

  // Store analytics methods

  // Get spending by store for a specific month
  Map<String, Map<String, dynamic>> getStoreReport(int year, int month) {
    final monthProducts =
        _purchasedProducts.where((product) {
          if (product.purchasedAt == null) return false;
          return product.purchasedAt!.year == year &&
              product.purchasedAt!.month == month;
        }).toList();

    final Map<String, Map<String, dynamic>> report = {};

    for (var product in monthProducts) {
      final storeName = product.store ?? 'Sem loja informada';

      if (!report.containsKey(storeName)) {
        report[storeName] = {
          'totalSpent': 0.0,
          'itemCount': 0,
          'items': <Product>[],
        };
      }

      report[storeName]!['totalSpent'] += product.price ?? 0.0;
      report[storeName]!['itemCount'] += 1;
      (report[storeName]!['items'] as List<Product>).add(product);
    }

    return report;
  }

  // Get top stores by spending for a specific month
  List<MapEntry<String, double>> getTopStores(
    int year,
    int month, {
    int limit = 5,
  }) {
    final storeReport = getStoreReport(year, month);
    final storeSpending = <String, double>{};

    storeReport.forEach((store, data) {
      storeSpending[store] = data['totalSpent'] as double;
    });

    final sortedStores =
        storeSpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedStores.take(limit).toList();
  }

  // Get average spending per store for a specific month
  Map<String, double> getAverageSpendingPerStore(int year, int month) {
    final storeReport = getStoreReport(year, month);
    final averages = <String, double>{};

    storeReport.forEach((store, data) {
      final total = data['totalSpent'] as double;
      final count = data['itemCount'] as int;
      averages[store] = count > 0 ? total / count : 0.0;
    });

    return averages;
  }

  // Get all unique stores from purchased products
  List<String> getAllStores() {
    final stores = <String>{};
    for (var product in _purchasedProducts) {
      if (product.store != null && product.store!.isNotEmpty) {
        stores.add(product.store!);
      }
    }
    return stores.toList()..sort();
  }

  // Category Limits methods
  Future<void> setCategoryLimit(
    int year,
    int month,
    String category,
    double limitAmount,
  ) async {
    await _dbHelper.setCategoryLimit(year, month, category, limitAmount);
    notifyListeners();
  }

  Future<double?> getCategoryLimit(int year, int month, String category) async {
    return await _dbHelper.getCategoryLimit(year, month, category);
  }

  Future<Map<String, double>> getCategoryLimits(int year, int month) async {
    return await _dbHelper.getCategoryLimits(year, month);
  }

  Future<void> deleteCategoryLimit(int year, int month, String category) async {
    await _dbHelper.deleteCategoryLimit(year, month, category);
    notifyListeners();
  }

  // Get category spending status with limit
  Map<String, dynamic> getCategorySpendingStatus(
    int year,
    int month,
    ProductCategory category,
  ) {
    final report = getMonthlyReport(year, month);
    final spending = report[category]?['totalSpent'] as double? ?? 0.0;

    return {
      'category': category,
      'spending': spending,
      'limit': null, // Will be filled by UI with async call
      'percentage': 0.0,
      'status': 'ok', // ok, warning, exceeded
    };
  }

  // Favorite products methods
  Future<void> toggleFavorite(int productId) async {
    // Busca o produto em ambas as listas
    Product? product;
    try {
      product = _productsToBuy.firstWhere((p) => p.id == productId);
    } catch (e) {
      product = _purchasedProducts.firstWhere((p) => p.id == productId);
    }

    final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
    await _dbHelper.updateProduct(updatedProduct);
    await loadProducts();
  }

  List<Product> get favoriteProducts {
    // Retorna produtos favoritos que foram comprados (histórico)
    return _purchasedProducts.where((p) => p.isFavorite).toList();
  }

  Future<List<Map<String, dynamic>>> getMostPurchasedProducts({
    int limit = 10,
  }) async {
    // Busca todos os produtos comprados do banco
    final allProducts = await _dbHelper.getAllProducts();
    final purchasedProducts = allProducts.where((p) => p.isPurchased).toList();

    // Agrupa produtos por nome e conta quantas vezes foram comprados
    final Map<String, Map<String, dynamic>> productCount = {};

    for (var product in purchasedProducts) {
      final key = product.name.toLowerCase();
      if (productCount.containsKey(key)) {
        productCount[key]!['count'] = (productCount[key]!['count'] as int) + 1;
      } else {
        productCount[key] = {
          'name': product.name,
          'category': product.category,
          'count': 1,
          'lastPrice': product.price,
          'lastStore': product.store,
        };
      }
    }

    // Ordena por contagem e retorna os top N
    final sorted =
        productCount.values.toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return sorted.take(limit).toList();
  }
}
