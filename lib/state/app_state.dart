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
    final old = deliveries.firstWhere((d) => d.id == updated.id);
    
    Delivery resolved = updated;
    if (updated.status == 'classified' && 
        (updated.classification == 'Class A' || updated.classification == 'Class B')) {
      final periodStart = _getPaymentPeriodStart(updated.farmerSupplierId, updated.date);
      resolved = updated.copyWith(paymentPeriodStart: periodStart);
    } else {
      resolved = updated.copyWith(paymentPeriodStart: null);
    }

    deliveries =
        deliveries.map((d) => d.id == resolved.id ? resolved : d).toList();

    final oldPeriodStart = old.paymentPeriodStart ?? old.date;
    _syncPaymentForFarmerAndPeriod(old.farmerSupplierId, oldPeriodStart);

    final newPeriodStart = resolved.paymentPeriodStart ?? resolved.date;
    if (old.farmerSupplierId != resolved.farmerSupplierId || oldPeriodStart != newPeriodStart) {
      _syncPaymentForFarmerAndPeriod(resolved.farmerSupplierId, newPeriodStart);
    }

    await storage.saveDeliveries(deliveries);
    await storage.savePayments(payments);
    notifyListeners();
  }

  Future<void> deleteDelivery(String id) async {
    final old = deliveries.firstWhere((d) => d.id == id);
    deliveries = deliveries.where((d) => d.id != id).toList();

    final oldPeriodStart = old.paymentPeriodStart ?? old.date;
    _syncPaymentForFarmerAndPeriod(old.farmerSupplierId, oldPeriodStart);

    await storage.saveDeliveries(deliveries);
    await storage.savePayments(payments);
    notifyListeners();
  }

  Future<void> classifyDelivery({
    required String deliveryId,
    required String classification,
  }) async {
    DateTime? resolvedPeriodStart;
    deliveries = deliveries.map((delivery) {
      if (delivery.id == deliveryId) {
        if (classification == 'Class A' || classification == 'Class B') {
          resolvedPeriodStart = _getPaymentPeriodStart(delivery.farmerSupplierId, delivery.date);
        } else {
          resolvedPeriodStart = null;
        }
        return delivery.copyWith(
          classification: classification,
          status: 'classified',
          paymentPeriodStart: resolvedPeriodStart,
        );
      }
      return delivery;
    }).toList();

    // Sync payments based on classification
    final delivery = deliveries.firstWhere((d) => d.id == deliveryId);
    final periodStart = delivery.paymentPeriodStart ?? delivery.date;
    _syncPaymentForFarmerAndPeriod(delivery.farmerSupplierId, periodStart);

    await storage.saveDeliveries(deliveries);
    await storage.savePayments(payments);
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

  void _syncPaymentForFarmerAndPeriod(String farmerId, DateTime periodStart) {
    final isFirstHalf = periodStart.day <= 15;
    final lastDay = DateTime(periodStart.year, periodStart.month + 1, 0).day;
    final periodEndDay = isFirstHalf ? 15 : lastDay;
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthAbbr = months[periodStart.month - 1];
    final periodLabel = '$monthAbbr ${isFirstHalf ? 1 : 16}–$periodEndDay, ${periodStart.year}';

    // Find all classified deliveries for this farmer and period
    final periodDeliveries = deliveries.where((d) {
      if (d.farmerSupplierId != farmerId || d.status != 'classified') return false;
      if (d.classification != 'Class A' && d.classification != 'Class B') return false;
      
      final dPeriodStart = d.paymentPeriodStart ??
          DateTime(d.date.year, d.date.month, d.date.day <= 15 ? 1 : 16);
      return dPeriodStart.year == periodStart.year &&
             dPeriodStart.month == periodStart.month &&
             dPeriodStart.day == periodStart.day;
    }).toList();

    final totalVolume = periodDeliveries.fold<double>(0.0, (sum, d) => sum + d.volumeLiters);
    final totalAmount = totalVolume * 45.0;

    final existingIndex = payments.indexWhere((p) =>
        p.farmerSupplierId == farmerId && p.periodLabel == periodLabel);

    if (existingIndex != -1) {
      if (totalVolume == 0) {
        payments.removeAt(existingIndex);
      } else {
        payments[existingIndex] = Payment(
          id: payments[existingIndex].id,
          farmerSupplierId: farmerId,
          periodLabel: periodLabel,
          periodStart: periodStart,
          totalVolumeLiters: totalVolume,
          totalAmount: totalAmount,
          status: payments[existingIndex].status,
        );
      }
    } else if (totalVolume > 0) {
      final now = DateTime.now().microsecondsSinceEpoch;
      final newPayment = Payment(
        id: 'PAY-$now',
        farmerSupplierId: farmerId,
        periodLabel: periodLabel,
        periodStart: periodStart,
        totalVolumeLiters: totalVolume,
        totalAmount: totalAmount,
        status: 'pending',
      );
      payments = [newPayment, ...payments];
    }
  }

  DateTime _getPaymentPeriodStart(String farmerId, DateTime date) {
    var checkDate = date;
    while (true) {
      final isFirstHalf = checkDate.day <= 15;
      final periodStart = DateTime(checkDate.year, checkDate.month, isFirstHalf ? 1 : 16);
      
      final lastDay = DateTime(checkDate.year, checkDate.month + 1, 0).day;
      final periodEndDay = isFirstHalf ? 15 : lastDay;
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthAbbr = months[checkDate.month - 1];
      final periodLabel = '$monthAbbr ${isFirstHalf ? 1 : 16}–$periodEndDay, ${checkDate.year}';
      
      final isPaid = payments.any((p) =>
          p.farmerSupplierId == farmerId &&
          p.periodLabel == periodLabel &&
          p.status == 'paid');
      
      if (!isPaid) {
        return periodStart;
      }
      
      // Roll over to the next half-month
      if (isFirstHalf) {
        checkDate = DateTime(checkDate.year, checkDate.month, 16);
      } else {
        if (checkDate.month == 12) {
          checkDate = DateTime(checkDate.year + 1, 1, 1);
        } else {
          checkDate = DateTime(checkDate.year, checkDate.month + 1, 1);
        }
      }
    }
  }
}
