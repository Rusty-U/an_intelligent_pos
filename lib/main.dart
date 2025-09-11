import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Firebase packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ⚠️ Filhaal firebase_options hata diya hai
// import 'firebase_options.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/shop_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/report_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/recipt_setting_screen.dart';
import 'screens/general_screen.dart';
import 'screens/printer_setting_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Simple Firebase init (without firebase_options.dart)
  await Firebase.initializeApp();

  // ✅ Agar desktop pe ho to emulator connect karo
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: Consumer2<ThemeProvider, ShopProvider>(
        builder: (context, themeProvider, shopProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Intelligent POS',

            // ✅ Theme support
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),

            // ✅ Routes
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/sale': (_) => const NewSaleScreen(),
              '/inventory': (_) => const InventoryScreen(),
              '/staff': (_) => const StaffScreen(),
              '/reports': (_) => const ReportDateRangeScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/recipt_settings': (_) => const ReceiptSettingsScreen(),
              '/general_settings': (_) => const GeneralScreen(),
              '/printer_settings': (_) => const PrinterSettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
