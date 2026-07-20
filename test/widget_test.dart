import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trlafco_app/features/auth/login_screen.dart';
import 'package:trlafco_app/features/logistics/classification/classification_screen.dart';
import 'package:trlafco_app/features/logistics/deliveries/deliveries_screen.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_form_sheet.dart';
import 'package:trlafco_app/features/shared/widgets/farmer_form_sheet.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/services/local_storage_service.dart';
import 'package:trlafco_app/services/firebase_service.dart';
import 'package:trlafco_app/state/app_state.dart';
import 'package:trlafco_app/models/user_role.dart';

// ─── Firebase Mocks ────────────────────────────────────────────────────────

class FakedUser implements fb.User {
  FakedUser({this.email = 'mock-user@trlafco.com'});

  @override
  final String? email;

  @override
  String get uid => 'mock-uid';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakedUserCredential implements fb.UserCredential {
  @override
  fb.User? get user => FakedUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockFirebaseService implements FirebaseService {
  final List<FarmerSupplier> _farmers = [];
  final List<Delivery> _deliveries = [];
  final List<Payment> _payments = [];

  late final StreamController<fb.User?> _authController;
  late final StreamController<List<FarmerSupplier>> _farmersController;
  late final StreamController<List<Delivery>> _deliveriesController;
  late final StreamController<List<Payment>> _paymentsController;

  MockFirebaseService() {
    _authController = StreamController<fb.User?>.broadcast(sync: true);
    _farmersController = StreamController<List<FarmerSupplier>>.broadcast(
      sync: true,
      onListen: () => _farmersController.add(List.from(_farmers)),
    );
    _deliveriesController = StreamController<List<Delivery>>.broadcast(
      sync: true,
      onListen: () => _deliveriesController.add(List.from(_deliveries)),
    );
    _paymentsController = StreamController<List<Payment>>.broadcast(
      sync: true,
      onListen: () => _paymentsController.add(List.from(_payments)),
    );
  }

  @override
  fb.User? get currentUser => null;

  @override
  Stream<fb.User?> get authStateChanges => _authController.stream;

  @override
  Stream<List<FarmerSupplier>> get farmersStream => _farmersController.stream;
  @override
  Stream<List<Delivery>> get deliveriesStream => _deliveriesController.stream;
  @override
  Stream<List<Payment>> get paymentsStream => _paymentsController.stream;

  @override
  Future<fb.UserCredential?> login({required String username, required String password}) async {
    if ((username == 'manager' && password == 'manager123') ||
        (username == 'logistics' && password == 'logistics123')) {
      _authController.add(FakedUser(email: '$username@trlafco.com'));
      return FakedUserCredential();
    }
    throw fb.FirebaseAuthException(code: 'wrong-password', message: 'Invalid credentials');
  }

  @override
  Future<void> logout() async {
    _authController.add(null);
  }

  @override
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    // Mock update password
  }

  @override
  Future<String?> getUserRole(String uid) async {
    return uid == 'mock-uid' ? 'manager' : 'logistics';
  }

  @override
  Future<void> saveUserRole({
    required String uid,
    required String username,
    required String role,
    required String email,
  }) async {
    // No-op for tests
  }

  @override
  Future<void> saveFarmer(FarmerSupplier farmer) async {
    final idx = _farmers.indexWhere((f) => f.id == farmer.id);
    if (idx != -1) {
      _farmers[idx] = farmer;
    } else {
      _farmers.add(farmer);
    }
    _farmersController.add(List.from(_farmers));
  }

  @override
  Future<void> deleteFarmer(String id) async {
    _farmers.removeWhere((f) => f.id == id);
    _farmersController.add(List.from(_farmers));
  }

  @override
  Future<void> saveDelivery(Delivery delivery) async {
    final idx = _deliveries.indexWhere((d) => d.id == delivery.id);
    if (idx != -1) {
      _deliveries[idx] = delivery;
    } else {
      _deliveries.add(delivery);
    }
    _deliveriesController.add(List.from(_deliveries));
  }

  @override
  Future<void> deleteDelivery(String id) async {
    _deliveries.removeWhere((d) => d.id == id);
    _deliveriesController.add(List.from(_deliveries));
  }

  @override
  @override
  Future<void> savePayment(Payment payment) async {
    final idx = _payments.indexWhere((p) => p.id == payment.id);
    if (idx != -1) {
      _payments[idx] = payment;
    } else {
      _payments.add(payment);
    }
    _paymentsController.add(List.from(_payments));
  }

  @override
  Future<void> deletePayment(String id) async {
    _payments.removeWhere((p) => p.id == id);
    _paymentsController.add(List.from(_payments));
  }

  @override
  Future<void> saveRawMilkInventoryStock(String docId, String name, double volume) async {}

  @override
  Future<void> seedDatabase({
    required List<FarmerSupplier> farmers,
    required List<Delivery> deliveries,
    required List<Payment> payments,
  }) async {
    _farmers.addAll(farmers);
    _deliveries.addAll(deliveries);
    _payments.addAll(payments);

    _farmersController.add(List.from(_farmers));
    _deliveriesController.add(List.from(_deliveries));
    _paymentsController.add(List.from(_payments));
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

AppState _makeState({List<FarmerSupplier>? farmers, List<Delivery>? deliveries}) {
  final mockFb = MockFirebaseService();
  if (farmers != null) mockFb._farmers.addAll(farmers);
  if (deliveries != null) mockFb._deliveries.addAll(deliveries);
  final state = AppState(
    storage: LocalStorageService(),
    firebase: mockFb,
  );
  state.initialize();
  return state;
}

FarmerSupplier _testFarmer({String id = 'FS-T1', String name = 'Test Farmer'}) =>
    FarmerSupplier(
      id: id,
      name: name,
      barangay: 'Test Barangay',
      contactNumber: '09170000000',
      status: 'active',
    );

Delivery _pendingDelivery({String id = 'DL-T1'}) => Delivery(
      id: id,
      farmerSupplierId: 'FS-T1',
      date: DateTime.now(),
      volumeLiters: 100,
      classification: null,
      status: 'pending',
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // Initialize mock SharedPreferences for all tests.
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // ── Login form ──────────────────────────────────────────────────────────

  testWidgets('Login form validates empty fields', (tester) async {
    final appState = AppState(
      storage: LocalStorageService(),
      firebase: MockFirebaseService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Wrong credentials show inline auth error', (tester) async {
    final appState = AppState(
      storage: LocalStorageService(),
      firebase: MockFirebaseService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('username_field')), 'wrong');
    await tester.enterText(find.byKey(const Key('password_field')), 'wrong');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump(); // start loading

    // Wait for the 900ms simulated delay.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth_error_text')), findsOneWidget);
    expect(
      find.text('Invalid username or password. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('Tapping the logo 5 times reveals dev autofill buttons and allows login', (tester) async {
    final appState = AppState(
      storage: LocalStorageService(),
      firebase: MockFirebaseService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify autofill buttons are NOT visible initially
    expect(find.byKey(const Key('autofill_manager_btn')), findsNothing);

    // Tap the logo gesture detector 5 times
    final logoFinder = find.byKey(const Key('logo_gesture'));
    expect(logoFinder, findsOneWidget);
    for (int i = 0; i < 5; i++) {
      await tester.tap(logoFinder);
    }
    await tester.pumpAndSettle();

    // Verify autofill buttons are now visible
    expect(find.byKey(const Key('autofill_manager_btn')), findsOneWidget);

    // Tap 'Manager' autofill
    await tester.tap(find.byKey(const Key('autofill_manager_btn')));
    await tester.pumpAndSettle();

    // Verify fields populated
    expect(find.text('manager'), findsOneWidget);
    expect(find.text('manager123'), findsOneWidget);

    // Tap login button
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    // Wait for simulated delay
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify logged in as manager
    expect(appState.currentRole, UserRole.manager);
  });

  // ── Delivery form ────────────────────────────────────────────────────────

  testWidgets('Delivery form validates required and numeric fields',
      (tester) async {
    final appState = _makeState(farmers: [_testFarmer()]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: Scaffold(body: DeliveryFormSheet(appState: appState)),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('save_delivery_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please choose a farmer-supplier'), findsOneWidget);
    expect(find.text('Volume is required'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delivery_farmer_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Farmer').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('delivery_volume_field')), '-1');
    await tester.tap(find.byKey(const Key('save_delivery_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid volume'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('delivery_volume_field')), '10000');
    await tester.tap(find.byKey(const Key('save_delivery_button')));
    await tester.pumpAndSettle();

    expect(find.text('Volume cannot exceed 9999 L'), findsOneWidget);
  });

  // ── Farmer form ──────────────────────────────────────────────────────────

  testWidgets('Farmer form validates empty fields', (tester) async {
    final appState = _makeState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: Scaffold(body: FarmerFormSheet(appState: appState)),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('save_farmer_button')));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Barangay is required'), findsOneWidget);
    expect(find.text('Contact number is required'), findsOneWidget);
  });

  testWidgets('Farmer form validates contact number format', (tester) async {
    final appState = _makeState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: Scaffold(body: FarmerFormSheet(appState: appState)),
        ),
      ),
    );

    // Enter invalid phone
    await tester.enterText(find.byType(TextFormField).at(2), '12345');
    await tester.tap(find.byKey(const Key('save_farmer_button')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a PH mobile number (e.g. 0917-XXX-XXXX)'), findsNothing); // should be the error text:
    expect(find.text('Enter a valid PH mobile number (e.g. 0917-XXX-XXXX)'), findsOneWidget);

    // Enter valid phone
    await tester.enterText(find.byType(TextFormField).at(2), '0917-821-4401');
    await tester.tap(find.byKey(const Key('save_farmer_button')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid PH mobile number (e.g. 0917-XXX-XXXX)'), findsNothing);
  });

  // ── AppState business logic ──────────────────────────────────────────────

  test('classifyDelivery removes item from pendingDeliveries', () async {
    final state = _makeState(deliveries: [_pendingDelivery()]);

    expect(state.pendingDeliveries, hasLength(1));

    await state.classifyDelivery(
      deliveryId: 'DL-T1',
      classification: 'Class A',
    );

    expect(state.pendingDeliveries, isEmpty);
    expect(state.deliveries.first.classification, 'Class A');
    expect(state.deliveries.first.status, 'classified');
  });

  test('classifyDelivery creates a pending payment record for Class A/B deliveries', () async {
    final state = _makeState(deliveries: [_pendingDelivery()]);

    expect(state.payments, isEmpty);

    await state.classifyDelivery(
      deliveryId: 'DL-T1',
      classification: 'Class A',
    );

    expect(state.payments, hasLength(1));
    final payment = state.payments.first;
    expect(payment.totalVolumeLiters, 100.0);
    expect(payment.totalAmount, 4500.0);
    expect(payment.status, 'pending');
  });

  test('classifyDelivery removes payment record if reclassified to Rejected', () async {
    final state = _makeState(deliveries: [_pendingDelivery()]);

    await state.classifyDelivery(
      deliveryId: 'DL-T1',
      classification: 'Class A',
    );
    expect(state.payments, hasLength(1));

    await state.classifyDelivery(
      deliveryId: 'DL-T1',
      classification: 'Rejected',
    );
    expect(state.payments, isEmpty);
  });

  test('classifyDelivery aggregates multiple deliveries for the same farmer and half-month', () async {
    final now = DateTime.now();
    final d1 = Delivery(
      id: 'DL-T1',
      farmerSupplierId: 'FS-T1',
      date: DateTime(now.year, now.month, 5),
      volumeLiters: 100,
      classification: null,
      status: 'pending',
    );
    final d2 = Delivery(
      id: 'DL-T2',
      farmerSupplierId: 'FS-T1',
      date: DateTime(now.year, now.month, 10),
      volumeLiters: 150,
      classification: null,
      status: 'pending',
    );
    final state = _makeState(deliveries: [d1, d2]);

    await state.classifyDelivery(deliveryId: 'DL-T1', classification: 'Class A');
    expect(state.payments.first.totalVolumeLiters, 100.0);
    expect(state.payments.first.totalAmount, 4500.0);

    await state.classifyDelivery(deliveryId: 'DL-T2', classification: 'Class B');
    expect(state.payments, hasLength(1));
    expect(state.payments.first.totalVolumeLiters, 250.0);
    expect(state.payments.first.totalAmount, 11250.0);
  });

  test('classifyDelivery rolls over to the next period if the current period is already paid', () async {
    final now = DateTime.now();
    final delivery = Delivery(
      id: 'DL-T1',
      farmerSupplierId: 'FS-T1',
      date: DateTime(now.year, now.month, 5),
      volumeLiters: 100,
      classification: null,
      status: 'pending',
    );
    final isFirstHalf = 5 <= 15;
    final periodStart = DateTime(now.year, now.month, isFirstHalf ? 1 : 16);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final periodEndDay = isFirstHalf ? 15 : lastDay;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthAbbr = months[now.month - 1];
    final periodLabel = '$monthAbbr ${isFirstHalf ? 1 : 16}–$periodEndDay, ${now.year}';

    final existingPaidPayment = Payment(
      id: 'PAY-PAID-1',
      farmerSupplierId: 'FS-T1',
      periodLabel: periodLabel,
      periodStart: periodStart,
      totalVolumeLiters: 50.0,
      totalAmount: 2250.0,
      status: 'paid',
    );

    final state = _makeState(deliveries: [delivery]);
    await state.firebaseService.savePayment(existingPaidPayment);

    await state.classifyDelivery(
      deliveryId: 'DL-T1',
      classification: 'Class A',
    );

    final paidPayment = state.payments.firstWhere((p) => p.id == 'PAY-PAID-1');
    expect(paidPayment.status, 'paid');
    expect(paidPayment.totalVolumeLiters, 50.0);

    expect(state.payments, hasLength(2));
    final rolledPayment = state.payments.firstWhere((p) => p.id != 'PAY-PAID-1');
    expect(rolledPayment.status, 'pending');
    expect(rolledPayment.totalVolumeLiters, 100.0);
    expect(rolledPayment.totalAmount, 4500.0);

    final expectedNextStart = isFirstHalf
        ? DateTime(now.year, now.month, 16)
        : (now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1));
    expect(rolledPayment.periodStart, expectedNextStart);
  });

  test('markPaymentPaid updates payment status', () async {
    final state = _makeState();
    final payment = Payment(
      id: 'PAY-T1',
      farmerSupplierId: 'FS-T1',
      periodLabel: 'Jul 1–15, 2026',
      periodStart: DateTime(2026, 7, 1),
      totalVolumeLiters: 500,
      totalAmount: 22500,
      status: 'pending',
    );
    await state.firebaseService.savePayment(payment);

    expect(state.payments.first.status, 'pending');
    await state.markPaymentPaid('PAY-T1');
    expect(state.payments.first.status, 'paid');
  });

  test('thisMonthPayoutTotal filters by current month only', () {
    final state = AppState(
      storage: LocalStorageService(),
      firebase: MockFirebaseService(),
    );
    final now = DateTime.now();

    state.payments = [
      Payment(
        id: 'PAY-A',
        farmerSupplierId: 'FS-T1',
        periodLabel: 'Current month',
        periodStart: DateTime(now.year, now.month, 1),
        totalVolumeLiters: 100,
        totalAmount: 5000,
        status: 'pending',
      ),
      Payment(
        id: 'PAY-B',
        farmerSupplierId: 'FS-T2',
        periodLabel: 'Last year',
        periodStart: DateTime(now.year - 1, now.month, 1),
        totalVolumeLiters: 100,
        totalAmount: 9999,
        status: 'paid',
      ),
    ];

    // Only the current-month payment should be counted.
    expect(state.thisMonthPayoutTotal, 5000.0);
  });

  test('toggleTheme changes themeMode', () async {
    final state = AppState(
      storage: LocalStorageService(),
      firebase: MockFirebaseService(),
    );
    expect(state.themeMode, ThemeMode.light);
    await state.toggleTheme();
    expect(state.themeMode, ThemeMode.dark);
    await state.toggleTheme();
    expect(state.themeMode, ThemeMode.light);
  });

  test('updateDelivery replaces existing delivery by id', () async {
    final original = _pendingDelivery();
    final state = _makeState(deliveries: [original]);

    final updated = original.copyWith(volumeLiters: 999);
    await state.updateDelivery(updated);

    expect(state.deliveries, hasLength(1));
    expect(state.deliveries.first.volumeLiters, 999);
  });

  test('deleteDelivery removes delivery by id', () async {
    final state = _makeState(deliveries: [_pendingDelivery()]);
    expect(state.deliveries, hasLength(1));
    await state.deleteDelivery('DL-T1');
    expect(state.deliveries, isEmpty);
  });

  test('updateFarmerSupplier replaces existing farmer by id', () async {
    final original = _testFarmer();
    final state = _makeState(farmers: [original]);

    final updated = FarmerSupplier(
      id: original.id,
      name: 'Updated Name',
      barangay: original.barangay,
      contactNumber: original.contactNumber,
      status: original.status,
    );
    await state.updateFarmerSupplier(updated);

    expect(state.farmers.first.name, 'Updated Name');
  });

  test('deleteFarmerSupplier removes farmer by id', () async {
    final state = _makeState(farmers: [_testFarmer()]);
    expect(state.farmers, hasLength(1));
    await state.deleteFarmerSupplier('FS-T1');
    expect(state.farmers, isEmpty);
  });

  // ── Swipe classify dialog ────────────────────────────────────────────────

  testWidgets('Swipe on pending delivery shows classify dialog', (tester) async {
    final farmer = _testFarmer();
    final delivery = _pendingDelivery();
    final state = _makeState(farmers: [farmer], deliveries: [delivery]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: DeliveriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Swipe the tile from right to left to trigger classify gesture.
    await tester.drag(
      find.byKey(Key(delivery.id)),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    // Dialog should appear asking for confirmation.
    expect(find.text('Classify as Class B?'), findsOneWidget);
  });

  testWidgets('Classification screen shows AnimatedList with pending items',
      (tester) async {
    final farmer = _testFarmer();
    final delivery = _pendingDelivery();
    final state = _makeState(farmers: [farmer], deliveries: [delivery]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ClassificationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The farmer's name should appear in the list.
    expect(find.text(farmer.name), findsOneWidget);

    // Tap the tile to open the classification bottom sheet.
    await tester.tap(find.text(farmer.name));
    await tester.pumpAndSettle();

    // The classification buttons inside the bottom sheet should be present.
    expect(find.text('Class A'), findsOneWidget);
    expect(find.text('Class B'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });
}
