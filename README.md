<div align="center">

# 🍶 TRLAFCO Supply Mobile

**A Flutter-based logistics and cooperative management application for TRLAFCO dairy operations.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Academic-green?style=for-the-badge)](LICENSE)

**[📱 Download Latest APK](https://github.com/woppuyu/trlafco_app/releases)** · **[View Releases](https://github.com/woppuyu/trlafco_app/releases)**

</div>

---

## 📌 Project Overview

**TRLAFCO Supply Mobile** is a role-based mobile application built with Flutter and backed by Firebase, developed to digitize and streamline the raw milk supply chain operations of **The Rosario Livestock and Agriculture Farming Cooperative (TRLAFCO)** — an agricultural cooperative established in 2012 in Rosario, Batangas, with approximately **115 registered members**, of which **79 actively deliver raw milk**.

This project was inspired by a capstone research on **Analytics-Driven Supply Chain and Inventory Management**, and addresses critical inefficiencies in the cooperative's manual record-keeping process — where milk deliveries, quality classifications, farmer-supplier profiles, and payout computations were tracked through paper logs and disconnected spreadsheets with no integrated source of truth.

The application consolidates all cooperative records into a **single, real-time cloud-synced system**, accessible by two primary roles:

| Role | Access Level |
| :--- | :--- |
| **Cooperative Manager** | Full access: classification oversight, inventory monitoring, payout management, and analytics |
| **Logistics Officer** | Operational access: delivery logging, farmer-supplier registration, and supply staging |

---

## ✨ Features

### Logistics Officer
- 📋 **Delivery Logging** — Record daily raw milk deliveries with farmer name, volume (liters), and date.
- 🧑‍🌾 **Farmer-Supplier Directory** — Register, update, and manage farmer-supplier profiles.
- 📊 **Logistics Dashboard** — See today's collection statistics and quick-access shortcuts.

### Cooperative Manager
- 🔬 **Quality Classification** — Classify pending deliveries as Class A, Class B, or Rejected.
- 🏦 **Payments Records** — Monitor and release bi-monthly payouts per farmer (computed at ₱45.00/L).
- 🥛 **Raw Milk Inventory** — Real-time Class A and Class B volume tracking updated on every classification.
- 📈 **Analytics & Insights** — Visualize raw milk intake trends, farmer volumes, and payout summaries through interactive charts.
- 👤 **Farmers Directory** — Review all registered cooperative members and their status.

### General
- 🌙 **Dark / Light Mode** — Toggle between modes from the settings screen.
- 🔒 **Role-Based Authentication** — Firebase Auth-powered secure login routing users to their designated interface.
- ☁️ **Real-Time Sync** — Cloud Firestore streams keep all data current across sessions and devices.

---

## 🗃️ Database Collections (Cloud Firestore)

| Collection | Description |
| :--- | :--- |
| `users` | Stores Firebase Auth UID, role, username, and email per account |
| `farmers` | Cooperative member profiles (name, barangay, contact, status) |
| `deliveries` | Milk delivery records (volume, farmer ID, classification, status) |
| `payments` | Bi-monthly payout records per farmer (volume, amount, period, status) |
| `inventory` | Aggregated raw milk stock (`class_a`, `class_b` documents) |

---

## 🛠️ Technology Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart, Material Design 3) |
| **Backend & Database** | [Firebase Authentication](https://firebase.google.com/products/auth) + [Cloud Firestore](https://firebase.google.com/products/firestore) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) |
| **Charts & Analytics** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **Fonts** | [Google Fonts — Inter](https://fonts.google.com/specimen/Inter) |
| **Local Persistence** | [Shared Preferences](https://pub.dev/packages/shared_preferences) |
| **Internationalization** | [intl](https://pub.dev/packages/intl) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.x`
- [Dart SDK](https://dart.dev/get-dart) `^3.12.x`
- A configured [Firebase Project](https://console.firebase.google.com/) with Firestore and Authentication enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/woppuyu/trlafco_app.git
   cd trlafco_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Run `flutterfire configure` and link your Firebase project.
   - Replace `lib/firebase_options.dart` with your generated configuration file.

4. **Seed the database (optional):**
   ```bash
   cd scripts
   node seed.js
   ```

5. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📱 Download & Install

Pre-built release APKs are available from the GitHub Releases page:

**[👉 Download Latest APKs Here](https://github.com/woppuyu/trlafco_app/releases)**

| Architecture | Target Device |
| :--- | :--- |
| `app-arm64-v8a-release.apk` | Most modern Android phones (Recommended) |
| `app-armeabi-v7a-release.apk` | Older 32-bit Android devices |
| `app-x86_64-release.apk` | Android emulators |

> **Note:** Enable *Install from Unknown Sources* in your device settings before installing.

---

## 🧱 Project Structure

```
lib/
├── app/
│   ├── app.dart           # App root widget
│   ├── router.dart        # GoRouter route declarations
│   └── theme.dart         # Material 3 light & dark theme tokens
├── features/
│   ├── auth/              # Login screen and authentication forms
│   ├── logistics/         # Logistics role screens (dashboard, deliveries, farmers, settings)
│   └── manager/           # Manager role screens (dashboard, classify, records, analytics, settings)
├── models/                # Dart data model classes
├── services/
│   ├── firebase_service.dart      # Cloud Firestore streams and CRUD
│   └── local_storage_service.dart # SharedPreferences persistence
├── state/
│   └── app_state.dart     # Central ChangeNotifier state controller
└── main.dart              # Firebase initialization + app entry point
scripts/
└── seed.js                # Node.js Firestore database seeder
test/
└── widget_test.dart       # Unit and widget test suite
```

---

## 🧪 Testing

Run the full automated test suite (20 test cases):

```bash
flutter test
```

Run static code analysis:

```bash
flutter analyze
```

---

## 👥 Contributors

This is a collaborative group project developed as part of the course requirements for:

> **IT-331 — Application Development and Emerging Technologies**
> Batangas State University TNEU — Alangilan

---

## 📄 License

This project was developed for **academic purposes** as part of a capstone and course requirement. All rights reserved by the contributors.
