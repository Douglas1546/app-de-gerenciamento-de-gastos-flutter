import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

enum PurchasedFilter { all, today, thisMonth, thisYear }

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _productsToBuy = [];
  List<Product> _purchasedProducts = [];
  PurchasedFilter _currentFilter = PurchasedFilter.all;

  List<Product> get productsToBuy => _productsToBuy;
  List<Product> get purchasedProducts => _filteredPurchasedProducts;
  PurchasedFilter get currentFilter => _currentFilter;

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

  Future<void> purchaseProduct(Product product, double price) async {
    final updatedProduct = product.copyWith(
      isPurchased: true,
      price: price,
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
}
