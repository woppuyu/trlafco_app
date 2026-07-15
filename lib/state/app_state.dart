import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/finished_product_inventory.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/models/product.dart';
import 'package:trlafco_app/models/user_role.dart';
import 'package:trlafco_app/services/local_storage_service.dart';
import 'package:trlafco_app/services/firebase_service.dart';

/// Centralized application state for auth, settings, and business data.
class AppState extends ChangeNotifier {
  AppState({required this.storage, FirebaseService? firebase})
      : firebaseService = firebase ?? FirebaseService();

  final LocalStorageService storage;
  final FirebaseService firebaseService;

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

  final List<StreamSubscription> _subscriptions = [];

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    // Cancel old subscriptions if initialized multiple times
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    // Listen to Firebase Auth state changes
    _subscriptions.add(
      firebaseService.authStateChanges.listen((fb.User? fbUser) async {
        if (fbUser != null) {
          currentUsername = fbUser.email?.split('@').first;
          final role = await firebaseService.getUserRole(fbUser.uid);
          if (role == 'manager') {
            currentRole = UserRole.manager;
          } else if (role == 'logistics') {
            currentRole = UserRole.logistics;
          }
        } else {
          currentRole = null;
          currentUsername = null;
        }
        notifyListeners();
      }),
    );

    // Listen to Firestore real-time streams
    _subscriptions.add(
      firebaseService.farmersStream.listen((list) {
        farmers = list;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      firebaseService.deliveriesStream.listen((list) {
        deliveries = list;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      firebaseService.productsStream.listen((list) {
        products = list;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      firebaseService.inventoryStream.listen((list) {
        inventory = list;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      firebaseService.paymentsStream.listen((list) {
        payments = list;
        notifyListeners();
      }),
    );

    final savedTheme = await storage.loadThemeMode();
    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
    }


    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    authError = null;
    notifyListeners();

    try {
      final creds = await firebaseService.login(username: username, password: password);
      if (creds != null) {
        currentUsername = username.trim().toLowerCase();
        currentRole = currentUsername == 'manager' ? UserRole.manager : UserRole.logistics;
        authError = null;
        notifyListeners();
        return true;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'user-not-found') {
        authError = 'Invalid username or password. Please try again.';
      } else {
        authError = e.message ?? 'Authentication failed. Please try again.';
      }
    } catch (_) {
      authError = 'Invalid username or password. Please try again.';
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    currentRole = null;
    currentUsername = null;
    authError = null;
    await firebaseService.logout();
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
    await firebaseService.saveFarmer(farmer);
  }

  Future<void> updateFarmerSupplier(FarmerSupplier updated) async {
    await firebaseService.saveFarmer(updated);
  }

  Future<void> deleteFarmerSupplier(String id) async {
    await firebaseService.deleteFarmer(id);
  }

  // ─── Delivery CRUD ────────────────────────────────────────────────────────

  Future<void> addDelivery(Delivery delivery) async {
    await firebaseService.saveDelivery(delivery);
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

    await firebaseService.saveDelivery(resolved);

    final oldPeriodStart = old.paymentPeriodStart ?? old.date;
    await _syncPaymentForFarmerAndPeriod(old.farmerSupplierId, oldPeriodStart);

    final newPeriodStart = resolved.paymentPeriodStart ?? resolved.date;
    if (old.farmerSupplierId != resolved.farmerSupplierId || oldPeriodStart != newPeriodStart) {
      await _syncPaymentForFarmerAndPeriod(resolved.farmerSupplierId, newPeriodStart);
    }
  }

  Future<void> deleteDelivery(String id) async {
    final old = deliveries.firstWhere((d) => d.id == id);
    await firebaseService.deleteDelivery(id);

    final oldPeriodStart = old.paymentPeriodStart ?? old.date;
    await _syncPaymentForFarmerAndPeriod(old.farmerSupplierId, oldPeriodStart);
  }

  Future<void> classifyDelivery({
    required String deliveryId,
    required String classification,
  }) async {
    DateTime? resolvedPeriodStart;
    final delivery = deliveries.firstWhere((d) => d.id == deliveryId);

    if (classification == 'Class A' || classification == 'Class B') {
      resolvedPeriodStart = _getPaymentPeriodStart(delivery.farmerSupplierId, delivery.date);
    } else {
      resolvedPeriodStart = null;
    }

    final updated = delivery.copyWith(
      classification: classification,
      status: 'classified',
      paymentPeriodStart: resolvedPeriodStart,
    );

    await firebaseService.saveDelivery(updated);

    final periodStart = updated.paymentPeriodStart ?? updated.date;
    await _syncPaymentForFarmerAndPeriod(updated.farmerSupplierId, periodStart);
  }

  // ─── Payment operations ───────────────────────────────────────────────────

  Future<void> markPaymentPaid(String paymentId) async {
    final payment = payments.firstWhere((p) => p.id == paymentId);
    final updated = payment.copyWith(status: 'paid');
    await firebaseService.savePayment(updated);
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
        .fold(0, (total, e) => total + e.volumeLiters);
  }

  double get classARawMilkStock {
    return deliveries
        .where((e) => e.classification == 'Class A')
        .fold(0, (total, e) => total + e.volumeLiters);
  }

  double get classBRawMilkStock {
    return deliveries
        .where((e) => e.classification == 'Class B')
        .fold(0, (total, e) => total + e.volumeLiters);
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
        .fold(0, (total, e) => total + e.totalAmount);
  }

  int get pendingOrdersCount {
    return inventory.fold(0, (total, e) => total + e.reservedStock);
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

  Future<void> _syncPaymentForFarmerAndPeriod(String farmerId, DateTime periodStart) async {
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

    final totalVolume = periodDeliveries.fold<double>(0.0, (acc, d) => acc + d.volumeLiters);
    final totalAmount = totalVolume * 45.0;

    final existingIndex = payments.indexWhere((p) =>
        p.farmerSupplierId == farmerId && p.periodLabel == periodLabel);

    if (existingIndex != -1) {
      if (totalVolume == 0) {
        final paymentId = payments[existingIndex].id;
        await firebaseService.deletePayment(paymentId);
      } else {
        final updatedPayment = Payment(
          id: payments[existingIndex].id,
          farmerSupplierId: farmerId,
          periodLabel: periodLabel,
          periodStart: periodStart,
          totalVolumeLiters: totalVolume,
          totalAmount: totalAmount,
          status: payments[existingIndex].status,
        );
        await firebaseService.savePayment(updatedPayment);
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
      await firebaseService.savePayment(newPayment);
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
