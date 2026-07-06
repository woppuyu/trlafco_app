import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/features/auth/login_screen.dart';
import 'package:trlafco_app/features/shared/widgets/delivery_form_sheet.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/services/local_storage_service.dart';
import 'package:trlafco_app/state/app_state.dart';

void main() {
  testWidgets('Login form validates empty fields', (tester) async {
    final appState = AppState(storage: LocalStorageService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Delivery form validates required and numeric fields', (tester) async {
    final appState = AppState(storage: LocalStorageService());
    appState.farmers = [
      FarmerSupplier(
        id: 'FS-T1',
        name: 'Test Farmer',
        barangay: 'Test',
        contactNumber: '09170000000',
        status: 'active',
      ),
    ];

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

    await tester.enterText(find.byKey(const Key('delivery_volume_field')), '-1');
    await tester.enterText(find.byKey(const Key('delivery_weight_field')), 'abc');
    await tester.tap(find.byKey(const Key('save_delivery_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid volume'), findsOneWidget);
    expect(find.text('Enter a valid weight'), findsOneWidget);
  });
}
