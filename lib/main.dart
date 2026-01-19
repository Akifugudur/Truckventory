import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:truckventory/screens/add_transaction.dart';
import 'package:truckventory/screens/home_screen.dart';
import 'package:truckventory/screens/sales_history.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; // 👈 add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TruckventoryApp());
}

class TruckventoryApp extends StatelessWidget {
  const TruckventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truckventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const LoginScreen(), // 👈 this is the change
    );
  }
}