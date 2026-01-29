import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'registration_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDCewvr-ogK-zMNPLpEj8pCekCIYQxlxiU",
      authDomain: "campus-assistant-3f1a7.firebaseapp.com",
      projectId: "campus-assistant-3f1a7",
      storageBucket: "campus-assistant-3f1a7.firebasestorage.app",
      messagingSenderId: "202784332047",
      appId: "1:202784332047:web:7d044c1cbec608229a867a",
      measurementId: "G-NSTYSCCKW3",
    ),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔹 START SCREEN LOGIC
      initialRoute: isLoggedIn ? '/dashboard' : '/register',

      routes: {
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) =>  ProfileScreen(),
      },
    );
  }
}
