import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trlafco_app/firebase_options.dart';
import 'package:trlafco_app/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TrlafcoAppRoot());
}
