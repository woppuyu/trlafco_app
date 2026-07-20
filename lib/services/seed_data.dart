import 'package:trlafco_app/models/delivery.dart';
import 'package:trlafco_app/models/farmer_supplier.dart';
import 'package:trlafco_app/models/payment.dart';

class SeedData {
  static List<FarmerSupplier> farmers() {
    return [
      FarmerSupplier(
        id: 'FS-1784421928720001',
        name: 'Rogelio Dela Cruz',
        barangay: 'San Isidro',
        contactNumber: '09178214401',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720002',
        name: 'Maricel Ventura',
        barangay: 'Santa Lucia',
        contactNumber: '09181152760',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720003',
        name: 'Joel Manaloto',
        barangay: 'Poblacion East',
        contactNumber: '09274451902',
        status: 'inactive',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720004',
        name: 'Lourdes Castillo',
        barangay: 'Mabini',
        contactNumber: '09360083142',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720005',
        name: 'Henry Quimpo',
        barangay: 'Malaya',
        contactNumber: '09192007751',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720006',
        name: 'Kristine Ramos',
        barangay: 'San Vicente',
        contactNumber: '09655000099',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720007',
        name: 'Edgar Pineda',
        barangay: 'San Jose',
        contactNumber: '09218812234',
        status: 'active',
      ),
      FarmerSupplier(
        id: 'FS-1784421928720008',
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
      // Recent deliveries (within the last 10 days)
      Delivery(id: 'DL-1784073653470001', farmerSupplierId: 'FS-1784421928720001', date: now.subtract(const Duration(hours: 3)), volumeLiters: 125, classification: null, status: 'pending'),
      Delivery(id: 'DL-1784073653470002', farmerSupplierId: 'FS-1784421928720002', date: now.subtract(const Duration(hours: 5)), volumeLiters: 80, classification: null, status: 'pending'),
      Delivery(id: 'DL-1784073653470003', farmerSupplierId: 'FS-1784421928720004', date: now.subtract(const Duration(days: 1)), volumeLiters: 195, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470004', farmerSupplierId: 'FS-1784421928720001', date: now.subtract(const Duration(days: 1)), volumeLiters: 220, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470005', farmerSupplierId: 'FS-1784421928720008', date: now.subtract(const Duration(days: 2)), volumeLiters: 145, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-1784073653470006', farmerSupplierId: 'FS-1784421928720002', date: now.subtract(const Duration(days: 2)), volumeLiters: 98, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470007', farmerSupplierId: 'FS-1784421928720004', date: now.subtract(const Duration(days: 3)), volumeLiters: 210, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-1784073653470008', farmerSupplierId: 'FS-1784421928720003', date: now.subtract(const Duration(days: 3)), volumeLiters: 180, classification: null, status: 'pending'),
      Delivery(id: 'DL-1784073653470009', farmerSupplierId: 'FS-1784421928720001', date: now.subtract(const Duration(days: 4)), volumeLiters: 165, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470010', farmerSupplierId: 'FS-1784421928720002', date: now.subtract(const Duration(days: 4)), volumeLiters: 110, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470011', farmerSupplierId: 'FS-1784421928720004', date: now.subtract(const Duration(days: 5)), volumeLiters: 185, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470012', farmerSupplierId: 'FS-1784421928720001', date: now.subtract(const Duration(days: 5)), volumeLiters: 190, classification: 'Class B', status: 'classified'),
      Delivery(id: 'DL-1784073653470013', farmerSupplierId: 'FS-1784421928720002', date: now.subtract(const Duration(days: 6)), volumeLiters: 120, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470014', farmerSupplierId: 'FS-1784421928720008', date: now.subtract(const Duration(days: 6)), volumeLiters: 210, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470015', farmerSupplierId: 'FS-1784421928720003', date: now.subtract(const Duration(days: 7)), volumeLiters: 134, classification: 'Rejected', status: 'classified'),
      Delivery(id: 'DL-1784073653470016', farmerSupplierId: 'FS-1784421928720002', date: now.subtract(const Duration(days: 8)), volumeLiters: 175, classification: null, status: 'pending'),
      Delivery(id: 'DL-1784073653470017', farmerSupplierId: 'FS-1784421928720001', date: now.subtract(const Duration(days: 9)), volumeLiters: 244, classification: 'Class A', status: 'classified'),
      Delivery(id: 'DL-1784073653470018', farmerSupplierId: 'FS-1784421928720004', date: now.subtract(const Duration(days: 10)), volumeLiters: 208, classification: 'Class B', status: 'classified'),
    ];
  }

  static List<Payment> payments() {
    return [
      // July 2026 — current period (pending)
      Payment(id: 'PAY-1784073653470007', farmerSupplierId: 'FS-1784421928720001', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 713, totalAmount: 32085, status: 'pending'),
      Payment(id: 'PAY-1784073653470008', farmerSupplierId: 'FS-1784421928720002', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 553, totalAmount: 24885, status: 'pending'),
      Payment(id: 'PAY-1784073653470010', farmerSupplierId: 'FS-1784421928720007', periodLabel: 'Jul 1–15, 2026', periodStart: DateTime(2026, 7, 1), totalVolumeLiters: 510, totalAmount: 22950, status: 'paid'),
      // May 2026 — historical records
      Payment(id: 'PAY-1784073653470001', farmerSupplierId: 'FS-1784421928720001', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1330, totalAmount: 59850, status: 'paid'),
      Payment(id: 'PAY-1784073653470002', farmerSupplierId: 'FS-1784421928720002', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1165, totalAmount: 51945, status: 'paid'),
      Payment(id: 'PAY-1784073653470003', farmerSupplierId: 'FS-1784421928720004', periodLabel: 'May 1–15, 2026', periodStart: DateTime(2026, 5, 1), totalVolumeLiters: 1208, totalAmount: 54510, status: 'paid'),
      Payment(id: 'PAY-1784073653470004', farmerSupplierId: 'FS-1784421928720005', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 980, totalAmount: 44100, status: 'paid'),
      Payment(id: 'PAY-1784073653470005', farmerSupplierId: 'FS-1784421928720006', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 905, totalAmount: 40725, status: 'paid'),
      Payment(id: 'PAY-1784073653470006', farmerSupplierId: 'FS-1784421928720007', periodLabel: 'May 16–31, 2026', periodStart: DateTime(2026, 5, 16), totalVolumeLiters: 1124, totalAmount: 50580, status: 'paid'),
    ];
  }
}
