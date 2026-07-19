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
  static const String _sessionRoleKey = 'session_role';
  static const String _sessionUsernameKey = 'session_username';

  static const String _devAutofillKey = 'dev_autofill';
  static const String _managerPwdKey = 'dev_pwd_manager';
  static const String _logisticsPwdKey = 'dev_pwd_logistics';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // ─── Dev Autofill Trigger ────────────────────────────────────────────────

  Future<bool> loadDevAutofill() async {
    final prefs = await _prefs;
    return prefs.getBool(_devAutofillKey) ?? false;
  }

  Future<void> saveDevAutofill(bool show) async {
    final prefs = await _prefs;
    await prefs.setBool(_devAutofillKey, show);
  }

  Future<String> loadManagerPassword() async {
    final prefs = await _prefs;
    return prefs.getString(_managerPwdKey) ?? 'manager123';
  }

  Future<void> saveManagerPassword(String pwd) async {
    final prefs = await _prefs;
    await prefs.setString(_managerPwdKey, pwd);
  }

  Future<String> loadLogisticsPassword() async {
    final prefs = await _prefs;
    return prefs.getString(_logisticsPwdKey) ?? 'logistics123';
  }

  Future<void> saveLogisticsPassword(String pwd) async {
    final prefs = await _prefs;
    await prefs.setString(_logisticsPwdKey, pwd);
  }

  // ─── Theme ───────────────────────────────────────────────────────────────

  Future<String?> loadThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, mode);
  }

  // ─── Session ─────────────────────────────────────────────────────────────

  /// Persists the authenticated role and username so the session survives restarts.
  Future<void> saveSession(String role, String username) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionRoleKey, role);
    await prefs.setString(_sessionUsernameKey, username);
  }

  /// Returns the saved (role, username) pair, or (null, null) if no session is stored.
  Future<(String?, String?)> loadSession() async {
    final prefs = await _prefs;
    final role = prefs.getString(_sessionRoleKey);
    final username = prefs.getString(_sessionUsernameKey);
    return (role, username);
  }

  /// Removes the stored session (called on logout).
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionRoleKey);
    await prefs.remove(_sessionUsernameKey);
  }

  // ─── Domain data ─────────────────────────────────────────────────────────

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

  // ─── Private helpers ─────────────────────────────────────────────────────

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
