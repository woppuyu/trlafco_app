import 'package:flutter/material.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/finished_product_inventory.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/models/product.dart';
import 'package:trlafco_app/models/user_role.dart';
import 'package:trlafco_app/services/local_storage_service.dart';
import 'package:trlafco_app/services/seed_data.dart';

/// Centralized application state for auth, settings, and business data.
class AppState extends ChangeNotifier {
  AppState({required this.storage});

  final LocalStorageService storage;

  bool isLoading = true;
  ThemeMode themeMode = ThemeMode.light;
  UserRole? currentRole;
  String? currentUsername;
  String? authError;

  List<FarmerSupplier> farmers = [];
  List<Delivery> deliveries = [];
  List<Product> products = [];
  List<FinishedProductInventory> inventory = [];
  List<Payment> payments = [];

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    final savedTheme = await storage.loadThemeMode();
    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
    }

    // Restore persisted session so user stays logged in after restart.
    final (savedRole, savedUsername) = await storage.loadSession();
    if (savedRole == 'manager') {
      currentRole = UserRole.manager;
      currentUsername = savedUsername;
    } else if (savedRole == 'logistics') {
      currentRole = UserRole.logistics;
      currentUsername = savedUsername;
    }

    farmers = await storage.loadFarmers();
    deliveries = await storage.loadDeliveries();
    products = await storage.loadProducts();
    inventory = await storage.loadInventory();
    payments = await storage.loadPayments();

    if (farmers.isEmpty &&
        deliveries.isEmpty &&
        products.isEmpty &&
        inventory.isEmpty &&
        payments.isEmpty) {
      farmers = SeedData.farmers();
      deliveries = SeedData.deliveries();
      products = SeedData.products();
      inventory = SeedData.inventory();
      payments = SeedData.payments();
      await _persistData();
    }

    isLoading = false;
    notifyListeners();
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    authError = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (username == 'manager' && password == 'manager123') {
      currentRole = UserRole.manager;
      currentUsername = username;
      authError = null;
      await storage.saveSession('manager', username);
      notifyListeners();
      return true;
    }

    if (username == 'logistics' && password == 'logistics123') {
      currentRole = UserRole.logistics;
      currentUsername = username;
      authError = null;
      await storage.saveSession('logistics', username);
      notifyListeners();
      return true;
    }

    authError = 'Invalid username or password. Please try again.';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    currentRole = null;
    currentUsername = null;
    authError = null;
    await storage.clearSession();
    notifyListeners();
  }

  // ─── Theme ────────────────────────────────────────────────────────────────

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  // ─── Lookups ──────────────────────────────────────────────────────────────

  FarmerSupplier? farmerById(String id) {
    for (final farmer in farmers) {
      if (farmer.id == id) return farmer;
    }
    return null;
  }

  Delivery? deliveryById(String id) {
    for (final delivery in deliveries) {
      if (delivery.id == id) return delivery;
    }
    return null;
  }

  // ─── Farmer-Supplier CRUD ─────────────────────────────────────────────────

  Future<void> addFarmerSupplier(FarmerSupplier farmer) async {
    farmers = [farmer, ...farmers];
    await storage.saveFarmers(farmers);
    notifyListeners();
  }

  Future<void> updateFarmerSupplier(FarmerSupplier updated) async {
    farmers = farmers.map((f) => f.id == updated.id ? updated : f).toList();
    await storage.saveFarmers(farmers);
    notifyListeners();
  }

  Future<void> deleteFarmerSupplier(String id) async {
    farmers = farmers.where((f) => f.id != id).toList();
    await storage.saveFarmers(farmers);
    notifyListeners();
  }

  // ─── Delivery CRUD ────────────────────────────────────────────────────────

  Future<void> addDelivery(Delivery delivery) async {
    deliveries = [delivery, ...deliveries];
    await storage.saveDeliveries(deliveries);
    notifyListeners();
  }

  Future<void> updateDelivery(Delivery updated) async {
    deliveries =
        deliveries.map((d) => d.id == updated.id ? updated : d).toList();
    await storage.saveDeliveries(deliveries);
    notifyListeners();
  }

  Future<void> deleteDelivery(String id) async {
    deliveries = deliveries.where((d) => d.id != id).toList();
    await storage.saveDeliveries(deliveries);
    notifyListeners();
  }

  Future<void> classifyDelivery({
    required String deliveryId,
    required String classification,
  }) async {
    deliveries = deliveries.map((delivery) {
      if (delivery.id == deliveryId) {
        return delivery.copyWith(
          classification: classification,
          status: 'classified',
        );
      }
      return delivery;
    }).toList();

    await storage.saveDeliveries(deliveries);
    notifyListeners();
  }

  // ─── Payment operations ───────────────────────────────────────────────────

  Future<void> markPaymentPaid(String paymentId) async {
    payments = payments.map((payment) {
      if (payment.id == paymentId) {
        return payment.copyWith(status: 'paid');
      }
      return payment;
    }).toList();

    await storage.savePayments(payments);
    notifyListeners();
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<void> refreshData() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    notifyListeners();
  }

  // ─── Computed metrics ─────────────────────────────────────────────────────

  List<Delivery> get pendingDeliveries {
    return deliveries.where((d) => d.status == 'pending').toList();
  }

  List<Delivery> get classifiedDeliveries {
    return deliveries.where((d) => d.status == 'classified').toList();
  }

  double get totalRawMilkStock {
    return deliveries
        .where((e) =>
            e.classification == 'Class A' || e.classification == 'Class B')
        .fold(0, (sum, e) => sum + e.volumeLiters);
  }

  double get classARawMilkStock {
    return deliveries
        .where((e) => e.classification == 'Class A')
        .fold(0, (sum, e) => sum + e.volumeLiters);
  }

  double get classBRawMilkStock {
    return deliveries
        .where((e) => e.classification == 'Class B')
        .fold(0, (sum, e) => sum + e.volumeLiters);
  }

  /// Total payout amount for the current calendar month only.
  double get thisMonthPayoutTotal {
    final now = DateTime.now();
    return payments
        .where(
          (e) =>
              e.periodStart.year == now.year &&
              e.periodStart.month == now.month,
        )
        .fold(0, (sum, e) => sum + e.totalAmount);
  }

  int get pendingOrdersCount {
    return inventory.fold(0, (sum, e) => sum + e.reservedStock);
  }

  int get todayDeliveriesCount {
    final now = DateTime.now();
    return deliveries
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .length;
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<void> _persistData() async {
    await Future.wait([
      storage.saveFarmers(farmers),
      storage.saveDeliveries(deliveries),
      storage.saveProducts(products),
      storage.saveInventory(inventory),
      storage.savePayments(payments),
    ]);
  }
}
