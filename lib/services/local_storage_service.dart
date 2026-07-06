import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/finished_product_inventory.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/models/product.dart';

/// Handles all local persistence via SharedPreferences.
class LocalStorageService {
  static const String _themeKey = 'theme_mode';
  static const String _farmersKey = 'farmers';
  static const String _deliveriesKey = 'deliveries';
  static const String _productsKey = 'products';
  static const String _inventoryKey = 'inventory';
  static const String _paymentsKey = 'payments';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> loadThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, mode);
  }

  Future<List<FarmerSupplier>> loadFarmers() async {
    return _loadList(_farmersKey, FarmerSupplier.fromJson);
  }

  Future<List<Delivery>> loadDeliveries() async {
    return _loadList(_deliveriesKey, Delivery.fromJson);
  }

  Future<List<Product>> loadProducts() async {
    return _loadList(_productsKey, Product.fromJson);
  }

  Future<List<FinishedProductInventory>> loadInventory() async {
    return _loadList(_inventoryKey, FinishedProductInventory.fromJson);
  }

  Future<List<Payment>> loadPayments() async {
    return _loadList(_paymentsKey, Payment.fromJson);
  }

  Future<void> saveFarmers(List<FarmerSupplier> farmers) async {
    await _saveList(_farmersKey, farmers.map((e) => e.toJson()).toList());
  }

  Future<void> saveDeliveries(List<Delivery> deliveries) async {
    await _saveList(_deliveriesKey, deliveries.map((e) => e.toJson()).toList());
  }

  Future<void> saveProducts(List<Product> products) async {
    await _saveList(_productsKey, products.map((e) => e.toJson()).toList());
  }

  Future<void> saveInventory(List<FinishedProductInventory> inventory) async {
    await _saveList(_inventoryKey, inventory.map((e) => e.toJson()).toList());
  }

  Future<void> savePayments(List<Payment> payments) async {
    await _saveList(_paymentsKey, payments.map((e) => e.toJson()).toList());
  }

  Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return decoded;
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(items));
  }
}
