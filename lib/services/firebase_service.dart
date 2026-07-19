import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      // If user does not exist (or email enumeration protection is active, which
      // returns 'invalid-credential'), attempt to auto-register them.
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
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
        } on FirebaseAuthException catch (signUpError) {
          // If sign up fails because the email is already in use, it means
          // the account already exists and they entered the wrong password.
          if (signUpError.code == 'email-already-in-use') {
            throw e; // Throw original invalid-credential exception
          }
          rethrow;
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final creds = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(creds);
      await user.updatePassword(newPassword);
    } else {
      throw Exception('No authenticated user found');
    }
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

  Future<void> saveUserRole({
    required String uid,
    required String username,
    required String role,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'role': role,
      'email': email,
    });
  }

  // ─── Firestore Streams ────────────────────────────────────────────────────
  Stream<List<FarmerSupplier>> get farmersStream {
    return _firestore.collection('farmers').snapshots().map((snapshot) {
      final list = <FarmerSupplier>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(FarmerSupplier.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing farmer document ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  Stream<List<Delivery>> get deliveriesStream {
    return _firestore.collection('deliveries').snapshots().map((snapshot) {
      final list = <Delivery>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Delivery.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing delivery document ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  Stream<List<Product>> get productsStream {
    return _firestore.collection('products').snapshots().map((snapshot) {
      final list = <Product>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Product.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing product document ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  Stream<List<FinishedProductInventory>> get inventoryStream {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      final list = <FinishedProductInventory>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(FinishedProductInventory.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing inventory document ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  Stream<List<Payment>> get paymentsStream {
    return _firestore.collection('payments').snapshots().map((snapshot) {
      final list = <Payment>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Payment.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing payment document ${doc.id}: $e');
        }
      }
      return list;
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
