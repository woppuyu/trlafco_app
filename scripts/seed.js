const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../service-account.json');

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const farmers = [
  { id: 'FS-001', name: 'Rogelio Dela Cruz', barangay: 'San Isidro', contactNumber: '09178214401', status: 'active' },
  { id: 'FS-002', name: 'Maricel Ventura', barangay: 'Santa Lucia', contactNumber: '09181152760', status: 'active' },
  { id: 'FS-003', name: 'Joel Manaloto', barangay: 'Poblacion East', contactNumber: '09274451902', status: 'inactive' },
  { id: 'FS-004', name: 'Lourdes Castillo', barangay: 'Mabini', contactNumber: '09360083142', status: 'active' },
  { id: 'FS-005', name: 'Henry Quimpo', barangay: 'Malaya', contactNumber: '09192007751', status: 'active' },
  { id: 'FS-006', name: 'Kristine Ramos', barangay: 'San Vicente', contactNumber: '09655000099', status: 'active' },
  { id: 'FS-007', name: 'Edgar Pineda', barangay: 'San Jose', contactNumber: '09218812234', status: 'active' },
  { id: 'FS-008', name: 'Jocelyn Agravante', barangay: 'Baybay', contactNumber: '09168893450', status: 'active' }
];

const now = new Date();
const subtractDays = (days) => {
  const d = new Date(now);
  d.setDate(d.getDate() - days);
  return d;
};

const deliveries = [
  { id: 'DL-001', farmerSupplierId: 'FS-001', date: subtractDays(0), volumeLiters: 240, classification: 'Class A', status: 'classified' },
  { id: 'DL-002', farmerSupplierId: 'FS-002', date: subtractDays(0), volumeLiters: 190, classification: null, status: 'pending' },
  { id: 'DL-003', farmerSupplierId: 'FS-004', date: subtractDays(1), volumeLiters: 215, classification: 'Class B', status: 'classified' },
  { id: 'DL-004', farmerSupplierId: 'FS-006', date: subtractDays(1), volumeLiters: 180, classification: 'Rejected', status: 'classified' },
  { id: 'DL-005', farmerSupplierId: 'FS-007', date: subtractDays(2), volumeLiters: 260, classification: 'Class A', status: 'classified' },
  { id: 'DL-006', farmerSupplierId: 'FS-005', date: subtractDays(2), volumeLiters: 205, classification: null, status: 'pending' },
  { id: 'DL-007', farmerSupplierId: 'FS-008', date: subtractDays(3), volumeLiters: 172, classification: 'Class B', status: 'classified' },
  { id: 'DL-008', farmerSupplierId: 'FS-001', date: subtractDays(3), volumeLiters: 229, classification: 'Class A', status: 'classified' },
  { id: 'DL-009', farmerSupplierId: 'FS-004', date: subtractDays(4), volumeLiters: 199, classification: null, status: 'pending' },
  { id: 'DL-010', farmerSupplierId: 'FS-002', date: subtractDays(4), volumeLiters: 188, classification: 'Class B', status: 'classified' },
  { id: 'DL-011', farmerSupplierId: 'FS-007', date: subtractDays(5), volumeLiters: 250, classification: 'Class A', status: 'classified' },
  { id: 'DL-012', farmerSupplierId: 'FS-006', date: subtractDays(5), volumeLiters: 166, classification: null, status: 'pending' },
  { id: 'DL-013', farmerSupplierId: 'FS-005', date: subtractDays(6), volumeLiters: 221, classification: 'Class B', status: 'classified' },
  { id: 'DL-014', farmerSupplierId: 'FS-008', date: subtractDays(6), volumeLiters: 210, classification: 'Class A', status: 'classified' },
  { id: 'DL-015', farmerSupplierId: 'FS-003', date: subtractDays(7), volumeLiters: 134, classification: 'Rejected', status: 'classified' },
  { id: 'DL-016', farmerSupplierId: 'FS-002', date: subtractDays(8), volumeLiters: 175, classification: null, status: 'pending' },
  { id: 'DL-017', farmerSupplierId: 'FS-001', date: subtractDays(9), volumeLiters: 244, classification: 'Class A', status: 'classified' },
  { id: 'DL-018', farmerSupplierId: 'FS-004', date: subtractDays(10), volumeLiters: 208, classification: 'Class B', status: 'classified' }
];

const products = [
  { id: 'PR-001', name: 'Fresh Milk 1L', category: 'Dairy', requiresMilk: true, sellingPrice: 95 },
  { id: 'PR-002', name: 'Chocolate Milk 330ml', category: 'Dairy', requiresMilk: true, sellingPrice: 38 },
  { id: 'PR-003', name: 'Yogurt Drink', category: 'Dairy', requiresMilk: true, sellingPrice: 45 },
  { id: 'PR-004', name: 'Kesong Puti', category: 'Dairy', requiresMilk: true, sellingPrice: 120 },
  { id: 'PR-005', name: 'Eco Tote Bag', category: 'Non-Dairy', requiresMilk: false, sellingPrice: 150 },
  { id: 'PR-006', name: 'Insulated Bottle', category: 'Non-Dairy', requiresMilk: false, sellingPrice: 220 }
];

const inventory = [
  { productId: 'PR-001', currentStock: 140, reservedStock: 20 },
  { productId: 'PR-002', currentStock: 320, reservedStock: 40 },
  { productId: 'PR-003', currentStock: 215, reservedStock: 33 },
  { productId: 'PR-004', currentStock: 88, reservedStock: 11 },
  { productId: 'PR-005', currentStock: 57, reservedStock: 6 },
  { productId: 'PR-006', currentStock: 43, reservedStock: 5 }
];

const payments = [
  { id: 'PAY-007', farmerSupplierId: 'FS-001', periodLabel: 'Jul 1–15, 2026', periodStart: new Date(2026, 6, 1), totalVolumeLiters: 713, totalAmount: 32085, status: 'pending' },
  { id: 'PAY-008', farmerSupplierId: 'FS-002', periodLabel: 'Jul 1–15, 2026', periodStart: new Date(2026, 6, 1), totalVolumeLiters: 553, totalAmount: 24885, status: 'pending' },
  { id: 'PAY-009', farmerSupplierId: 'FS-004', periodLabel: 'Jul 1–15, 2026', periodStart: new Date(2026, 6, 1), totalVolumeLiters: 622, totalAmount: 27990, status: 'pending' },
  { id: 'PAY-010', farmerSupplierId: 'FS-007', periodLabel: 'Jul 1–15, 2026', periodStart: new Date(2026, 6, 1), totalVolumeLiters: 510, totalAmount: 22950, status: 'paid' },
  { id: 'PAY-001', farmerSupplierId: 'FS-001', periodLabel: 'May 1–15, 2026', periodStart: new Date(2026, 4, 1), totalVolumeLiters: 1330, totalAmount: 59850, status: 'paid' },
  { id: 'PAY-002', farmerSupplierId: 'FS-002', periodLabel: 'May 1–15, 2026', periodStart: new Date(2026, 4, 1), totalVolumeLiters: 1165, totalAmount: 51945, status: 'paid' },
  { id: 'PAY-003', farmerSupplierId: 'FS-004', periodLabel: 'May 1–15, 2026', periodStart: new Date(2026, 4, 1), totalVolumeLiters: 1208, totalAmount: 54510, status: 'paid' },
  { id: 'PAY-004', farmerSupplierId: 'FS-005', periodLabel: 'May 16–31, 2026', periodStart: new Date(2026, 4, 16), totalVolumeLiters: 980, totalAmount: 44100, status: 'paid' },
  { id: 'PAY-005', farmerSupplierId: 'FS-006', periodLabel: 'May 16–31, 2026', periodStart: new Date(2026, 4, 16), totalVolumeLiters: 905, totalAmount: 40725, status: 'paid' },
  { id: 'PAY-006', farmerSupplierId: 'FS-007', periodLabel: 'May 16–31, 2026', periodStart: new Date(2026, 4, 16), totalVolumeLiters: 1124, totalAmount: 50580, status: 'paid' }
];

async function seed() {
  console.log('Seeding farmers...');
  for (const doc of farmers) {
    await db.collection('farmers').doc(doc.id).set(doc);
  }

  console.log('Seeding deliveries...');
  for (const doc of deliveries) {
    await db.collection('deliveries').doc(doc.id).set(doc);
  }

  console.log('Seeding products...');
  for (const doc of products) {
    await db.collection('products').doc(doc.id).set(doc);
  }

  console.log('Seeding inventory...');
  for (const doc of inventory) {
    await db.collection('inventory').doc(doc.productId).set(doc);
  }

  console.log('Seeding payments...');
  for (const doc of payments) {
    await db.collection('payments').doc(doc.id).set(doc);
  }

  console.log('Database seeded successfully!');
  process.exit(0);
}

seed().catch(err => {
  console.error('Error seeding database:', err);
  process.exit(1);
});
