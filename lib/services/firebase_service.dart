import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/finished_product_inventory.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/models/product.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Helper to convert a plain username to a Firebase Auth email
  String _emailFromUsername(String username) {
    if (username.contains('@')) return username.trim();
    return '${username.trim().toLowerCase()}@trlafco.com';
  }

  Future<UserCredential?> login({
    required String username,
    required String password,
  }) async {
    final email = _emailFromUsername(username);
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // If user does not exist, auto-register them to simplify initial setup
      if (e.code == 'user-not-found') {
        try {
          final creds = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Set role document in firestore
          final role = username.trim().toLowerCase() == 'manager' ? 'manager' : 'logistics';
          await _firestore.collection('users').doc(creds.user!.uid).set({
            'username': username.trim().toLowerCase(),
            'role': role,
            'email': email,
          });
          return creds;
        } catch (_) {
          // Re-throw original or generic auth exception
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // ─── Firestore Streams ────────────────────────────────────────────────────

  Stream<List<FarmerSupplier>> get farmersStream {
    return _firestore.collection('farmers').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FarmerSupplier.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<Delivery>> get deliveriesStream {
    return _firestore.collection('deliveries').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Delivery.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<Product>> get productsStream {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<FinishedProductInventory>> get inventoryStream {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FinishedProductInventory.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<Payment>> get paymentsStream {
    return _firestore.collection('payments').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data()))
          .toList();
    });
  }

  // ─── Firestore CRUD ───────────────────────────────────────────────────────

  // Farmer CRUD
  Future<void> saveFarmer(FarmerSupplier farmer) async {
    await _firestore.collection('farmers').doc(farmer.id).set(farmer.toJson());
  }

  Future<void> deleteFarmer(String id) async {
    await _firestore.collection('farmers').doc(id).delete();
  }

  // Delivery CRUD
  Future<void> saveDelivery(Delivery delivery) async {
    await _firestore.collection('deliveries').doc(delivery.id).set(delivery.toJson());
  }

  Future<void> deleteDelivery(String id) async {
    await _firestore.collection('deliveries').doc(id).delete();
  }

  // Product CRUD
  Future<void> saveProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }
  // Inventory CRUD
  Future<void> saveInventoryItem(FinishedProductInventory item) async {
    await _firestore.collection('inventory').doc(item.productId).set(item.toJson());
  }

  // Payment CRUD
  Future<void> savePayment(Payment payment) async {
    await _firestore.collection('payments').doc(payment.id).set(payment.toJson());
  }

  Future<void> deletePayment(String id) async {
    await _firestore.collection('payments').doc(id).delete();
  }

  // Batch seeding helper
  Future<void> seedDatabase({
    required List<FarmerSupplier> farmers,
    required List<Delivery> deliveries,
    required List<Product> products,
    required List<FinishedProductInventory> inventory,
    required List<Payment> payments,
  }) async {
    final batch = _firestore.batch();

    for (final f in farmers) {
      batch.set(_firestore.collection('farmers').doc(f.id), f.toJson());
    }
    for (final d in deliveries) {
      batch.set(_firestore.collection('deliveries').doc(d.id), d.toJson());
    }
    for (final p in products) {
      batch.set(_firestore.collection('products').doc(p.id), p.toJson());
    }
    for (final i in inventory) {
      batch.set(_firestore.collection('inventory').doc(i.productId), i.toJson());
    }
    for (final pm in payments) {
      batch.set(_firestore.collection('payments').doc(pm.id), pm.toJson());
    }

    await batch.commit();
  }
}
