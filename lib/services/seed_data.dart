import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/finished_product_inventory.dart';
import 'package:trlafco_app/models/payment.dart';
import 'package:trlafco_app/models/product.dart';

class SeedData {
  static List<FarmerSupplier> farmers() {
    return [
      FarmerSupplier(
        id: 'FS-001',
        name: 'Rogelio Dela Cruz',
        barangay: 'San Isidro',
        contactNumber: '09178214401',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-002',
        name: 'Maricel Ventura',
        barangay: 'Santa Lucia',
        contactNumber: '09181152760',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-003',
        name: 'Joel Manaloto',
        barangay: 'Poblacion East',
        contactNumber: '09274451902',
        status: 'inactive',
      ),
      FarmerSupplier(
        id: 'FS-004',
        name: 'Lourdes Castillo',
        barangay: 'Mabini',
        contactNumber: '09360083142',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-005',
        name: 'Henry Quimpo',
        barangay: 'Malaya',
        contactNumber: '09192007751',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-006',
        name: 'Kristine Ramos',
        barangay: 'San Vicente',
        contactNumber: '09655000099',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-007',
        name: 'Edgar Pineda',
        barangay: 'San Jose',
        contactNumber: '09218812234',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-008',
        name: 'Jocelyn Agravante',
        barangay: 'Baybay',
        contactNumber: '09168893450',
        status: 'active',
      ),
    ];
  }

  static List<Delivery> deliveries() {
    final now = DateTime.now();
    return [
      Delivery(id: 'DL-001', farmerSupplierId: 'FS-001', date: now.subtract(const Duration(days: 0)), volumeLiters: 240, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-002', farmerSupplierId: 'FS-002', date: now.subtract(const Duration(days: 0)), volumeLiters: 190, classification: null, status: 'pending'),
      Delivery(id: 'DL-003', farmerSupplierId: 'FS-004', date: now.subtract(const Duration(days: 1)), volumeLiters: 215, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-004', farmerSupplierId: 'FS-006', date: now.subtract(const Duration(days: 1)), volumeLiters: 180, classification: 'Rejected', status: 'classified'),
      Delivery(id: 'DL-005', farmerSupplierId: 'FS-007', date: now.subtract(const Duration(days: 2)), volumeLiters: 260, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-006', farmerSupplierId: 'FS-005', date: now.subtract(const Duration(days: 2)), volumeLiters: 205, classification: null, status: 'pending'),
      Delivery(id: 'DL-007', farmerSupplierId: 'FS-008', date: now.subtract(const Duration(days: 3)), volumeLiters: 172, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-008', farmerSupplierId: 'FS-001', date: now.subtract(const Duration(days: 3)), volumeLiters: 229, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-009', farmerSupplierId: 'FS-004', date: now.subtract(const Duration(days: 4)), volumeLiters: 199, classification: null, status: 'pending'),
      Delivery(id: 'DL-010', farmerSupplierId: 'FS-002', date: now.subtract(const Duration(days: 4)), volumeLiters: 188, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-011', farmerSupplierId: 'FS-007', date: now.subtract(const Duration(days: 5)), volumeLiters: 250, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-012', farmerSupplierId: 'FS-006', date: now.subtract(const Duration(days: 5)), volumeLiters: 166, classification: null, status: 'pending'),
      Delivery(id: 'DL-013', farmerSupplierId: 'FS-005', date: now.subtract(const Duration(days: 6)), volumeLiters: 221, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-014', farmerSupplierId: 'FS-008', date: now.subtract(const Duration(days: 6)), volumeLiters: 210, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-015', farmerSupplierId: 'FS-003', date: now.subtract(const Duration(days: 7)), volumeLiters: 134, classification: 'Rejected', status: 'classified'),
      Delivery(id: 'DL-016', farmerSupplierId: 'FS-002', date: now.subtract(const Duration(days: 8)), volumeLiters: 175, classification: null, status: 'pending'),
      Delivery(id: 'DL-017', farmerSupplierId: 'FS-001', date: now.subtract(const Duration(days: 9)), volumeLiters: 244, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-018', farmerSupplierId: 'FS-004', date: now.subtract(const Duration(days: 10)), volumeLiters: 208, classification: 'Class B', status: 'classified'),
    ];
  }

  static List<Product> products() {
    return [
      Product(id: 'PR-001', name: 'Fresh Milk 1L', category: 'Dairy', requiresMilk: true, sellingPrice: 95),
      Product(id: 'PR-002', name: 'Chocolate Milk 330ml', category: 'Dairy', requiresMilk: true, sellingPrice: 38),
      Product(id: 'PR-003', name: 'Yogurt Drink', category: 'Dairy', requiresMilk: true, sellingPrice: 45),
      Product(id: 'PR-004', name: 'Kesong Puti', category: 'Dairy', requiresMilk: true, sellingPrice: 120),
      Product(id: 'PR-005', name: 'Eco Tote Bag', category: 'Non-Dairy', requiresMilk: false, sellingPrice: 150),
      Product(id: 'PR-006', name: 'Insulated Bottle', category: 'Non-Dairy', requiresMilk: false, sellingPrice: 220),
    ];
  }

  static List<FinishedProductInventory> inventory() {
    return [
      FinishedProductInventory(productId: 'PR-001', currentStock: 140, reservedStock: 20),
      FinishedProductInventory(productId: 'PR-002', currentStock: 320, reservedStock: 40),
      FinishedProductInventory(productId: 'PR-003', currentStock: 215, reservedStock: 33),
      FinishedProductInventory(productId: 'PR-004', currentStock: 88, reservedStock: 11),
      FinishedProductInventory(productId: 'PR-005', currentStock: 57, reservedStock: 6),
      FinishedProductInventory(productId: 'PR-006', currentStock: 43, reservedStock: 5),
    ];
  }

  static List<Payment> payments() {
    return [
      // July 2026 — current period (pending)
      Payment(id: 'PAY-007', farmerSupplierId: 'FS-001', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 713, totalAmount: 32085, status: 'pending'),
      Payment(id: 'PAY-008', farmerSupplierId: 'FS-002', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 553, totalAmount: 24885, status: 'pending'),
      Payment(id: 'PAY-009', farmerSupplierId: 'FS-004', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 622, totalAmount: 27990, status: 'pending'),
      Payment(id: 'PAY-010', farmerSupplierId: 'FS-007', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 510, totalAmount: 22950, status: 'paid'),
      // May 2026 — historical records
      Payment(id: 'PAY-001', farmerSupplierId: 'FS-001', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1330, totalAmount: 59850, status: 'paid'),
      Payment(id: 'PAY-002', farmerSupplierId: 'FS-002', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1165, totalAmount: 51945, status: 'paid'),
      Payment(id: 'PAY-003', farmerSupplierId: 'FS-004', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1208, totalAmount: 54510, status: 'paid'),
      Payment(id: 'PAY-004', farmerSupplierId: 'FS-005', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 980, totalAmount: 44100, status: 'paid'),
      Payment(id: 'PAY-005', farmerSupplierId: 'FS-006', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 905, totalAmount: 40725, status: 'paid'),
      Payment(id: 'PAY-006', farmerSupplierId: 'FS-007', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 1124, totalAmount: 50580, status: 'paid'),
    ];
  }
}
