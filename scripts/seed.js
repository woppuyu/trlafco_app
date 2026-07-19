const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../service-account.json');

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

// 1. Farmers definition (consistent IDs)
const farmers = [
  { id: 'FS-1784421928720001', name: 'Rogelio Dela Cruz', barangay: 'San Isidro', contactNumber: '09178214401', status: 'active' },
  { id: 'FS-1784421928720002', name: 'Maricel Ventura', barangay: 'Santa Lucia', contactNumber: '09181152760', status: 'active' },
  { id: 'FS-1784421928720003', name: 'Joel Manaloto', barangay: 'Poblacion East', contactNumber: '09274451902', status: 'inactive' },
  { id: 'FS-1784421928720004', name: 'Lourdes Castillo', barangay: 'Mabini', contactNumber: '09360083142', status: 'active' },
  { id: 'FS-1784421928720005', name: 'Henry Quimpo', barangay: 'Malaya', contactNumber: '09192007751', status: 'active' },
  { id: 'FS-1784421928720006', name: 'Kristine Ramos', barangay: 'San Vicente', contactNumber: '09655000099', status: 'active' },
  { id: 'FS-1784421928720007', name: 'Edgar Pineda', barangay: 'San Jose', contactNumber: '09218812234', status: 'active' },
  { id: 'FS-1784421928720008', name: 'Jocelyn Agravante', barangay: 'Baybay', contactNumber: '09168893450', status: 'active' }
];

// 2. Programmatically generate deliveries from Jan 1, 2026 to July 19, 2026 (>= 50 records)
const deliveries = [];
const startDate = new Date(2026, 0, 1); // Jan 1, 2026
const endDate = new Date(2026, 6, 19);   // Jul 19, 2026

let currentDate = new Date(startDate);
let deliveryCounter = 1;
while (currentDate <= endDate) {
  // Add a delivery on every odd-numbered calendar day to create a realistic sequence
  if (currentDate.getDate() % 2 !== 0) {
    const farmerIndex = deliveryCounter % farmers.length;
    const farmer = farmers[farmerIndex];
    
    // Inactive farmers don't deliver
    if (farmer.status === 'active') {
      const vol = 120 + (deliveryCounter * 13) % 181; // Deterministic volume: 120 to 300 Liters
      
      // Determine classification (approx 80% Class A, 15% Class B, 5% Rejected)
      let classification = 'Class A';
      if (deliveryCounter % 20 === 0) {
        classification = 'Rejected';
      } else if (deliveryCounter % 6 === 0) {
        classification = 'Class B';
      }
      
      // Deliveries after July 15, 2026 are pending classification
      const isPending = currentDate > new Date(2026, 6, 15);
      
      const isRejected = classification === 'Rejected';
      const periodStart = (!isPending && !isRejected) 
        ? new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() <= 15 ? 1 : 16)
        : null;

      deliveries.push({
        id: `DL-178407365347${String(deliveryCounter).padStart(4, '0')}`,
        farmerSupplierId: farmer.id,
        date: new Date(currentDate),
        volumeLiters: vol,
        classification: isPending ? null : classification,
        status: isPending ? 'pending' : 'classified',
        paymentPeriodStart: periodStart
      });
    }
    deliveryCounter++;
  }
  currentDate.setDate(currentDate.getDate() + 1);
}
// 3. Products & Inventory definitions
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

// 4. Programmatically aggregate payments based on the generated deliveries
const payments = [];
const paymentPeriods = {};

for (const d of deliveries) {
  if (d.status === 'classified' && d.paymentPeriodStart) {
    const date = new Date(d.paymentPeriodStart);
    const isFirstHalf = date.getDate() <= 15;
    const year = date.getFullYear();
    const month = date.getMonth();
    
    const lastDay = new Date(year, month + 1, 0).getDate();
    const periodEndDay = isFirstHalf ? 15 : lastDay;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthAbbr = months[month];
    const periodLabel = `${monthAbbr} ${isFirstHalf ? 1 : 16}–${periodEndDay}, ${year}`;
    
    const key = `${d.farmerSupplierId}_${periodLabel}`;
    if (!paymentPeriods[key]) {
      paymentPeriods[key] = {
        farmerSupplierId: d.farmerSupplierId,
        periodLabel: periodLabel,
        periodStart: date,
        totalVolumeLiters: 0
      };
    }
    paymentPeriods[key].totalVolumeLiters += d.volumeLiters;
  }
}

let paymentCounter = 1;
for (const key in paymentPeriods) {
  const p = paymentPeriods[key];
  const totalAmount = p.totalVolumeLiters * 45.0; // 45.0 PHP per Liter rate
  
  // Status: Historical periods (January to June) are paid. July periods are pending.
  const isJuly = p.periodStart.getMonth() === 6; // July index is 6
  const status = isJuly ? 'pending' : 'paid';
  
  payments.push({
    id: `PAY-178407365347${String(paymentCounter).padStart(4, '0')}`,
    farmerSupplierId: p.farmerSupplierId,
    periodLabel: p.periodLabel,
    periodStart: p.periodStart,
    totalVolumeLiters: parseFloat(p.totalVolumeLiters.toFixed(1)),
    totalAmount: parseFloat(totalAmount.toFixed(2)),
    status: status
  });
  paymentCounter++;
}

async function clearDatabase() {
  console.log('Clearing existing collections...');
  const collections = ['farmers', 'deliveries', 'products', 'inventory', 'payments'];
  for (const collection of collections) {
    const snapshot = await db.collection(collection).get();
    if (snapshot.size > 0) {
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
    }
  }
  console.log('Collections cleared!');
}

async function seed() {
  await clearDatabase();

  console.log('Seeding farmers...');
  for (const doc of farmers) {
    await db.collection('farmers').doc(doc.id).set(doc);
  }

  console.log(`Seeding ${deliveries.length} deliveries...`);
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

  console.log(`Seeding ${payments.length} payment records...`);
  for (const doc of payments) {
    await db.collection('payments').doc(doc.id).set(doc);
  }

  console.log('Database seeded successfully with dynamic data!');
  process.exit(0);
}

seed().catch(err => {
  console.error('Error seeding database:', err);
  process.exit(1);
});
