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
import 'package:trlafco_app/state/app_state.dart';

import 'package:trlafco_app/models/user_role.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

AppState _makeState({List<FarmerSupplier>? farmers, List<Delivery>? deliveries}) {
  final state = AppState(storage: LocalStorageService());
  if (farmers != null) state.farmers = farmers;
  if (deliveries != null) state.deliveries = deliveries;
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
      weightKg: 103,
      classification: null,
      status: 'pending',
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // Initialize mock SharedPreferences for all tests.
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // ── Login form ──────────────────────────────────────────────────────────

  testWidgets('Login form validates empty fields', (tester) async {
    final appState = AppState(storage: LocalStorageService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Select the 'Credentials' tab first
    await tester.tap(find.text('Credentials'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Wrong credentials show inline auth error', (tester) async {
    final appState = AppState(storage: LocalStorageService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Select the 'Credentials' tab first
    await tester.tap(find.text('Credentials'));
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

  testWidgets('Quick Login tab allows logging in by tapping a role card', (tester) async {
    final appState = AppState(storage: LocalStorageService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 'Quick Login' button is present
    final loginButtonFinder = find.byKey(const Key('quick_login_button'));
    expect(loginButtonFinder, findsOneWidget);

    // Tap the 'Manager' role card.
    await tester.tap(find.text('Manager'));
    await tester.pumpAndSettle();

    // Tap the 'Sign In' quick login button.
    await tester.tap(loginButtonFinder);
    await tester.pump(); // start loading

    // Wait for the 900ms simulated delay.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify it logged in as manager
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
    expect(find.text('Weight is required'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delivery_farmer_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Farmer').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('delivery_volume_field')), '-1');
    await tester.enterText(
        find.byKey(const Key('delivery_weight_field')), 'abc');
    await tester.tap(find.byKey(const Key('save_delivery_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid volume'), findsOneWidget);
    expect(find.text('Enter a valid weight'), findsOneWidget);
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

  test('markPaymentPaid updates payment status', () async {
    final state = AppState(storage: LocalStorageService());
    // Inject a payment directly.
    state.payments = [
      Payment(
        id: 'PAY-T1',
        farmerSupplierId: 'FS-T1',
        periodLabel: 'Jul 1–15, 2026',
        periodStart: DateTime(2026, 7, 1),
        totalVolumeLiters: 500,
        totalAmount: 22500,
        status: 'pending',
      ),
    ];

    expect(state.payments.first.status, 'pending');
    await state.markPaymentPaid('PAY-T1');
    expect(state.payments.first.status, 'paid');
  });

  test('thisMonthPayoutTotal filters by current month only', () {
    final state = AppState(storage: LocalStorageService());
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
    final state = AppState(storage: LocalStorageService());
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
