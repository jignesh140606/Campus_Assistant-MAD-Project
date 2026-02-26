import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'admin_main_screen.dart';
import 'pending_approval_screen.dart';
import 'profile_setup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Assistant',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const LoginScreen();
          }
          // Logged in → check role
          return _RoleRouter(uid: snapshot.data!.uid);
        },
      ),
      routes: {
        '/home': (context) => const MainScreen(),
        '/admin': (context) => const AdminMainScreen(),
        '/login': (context) => const LoginScreen(),
        '/pending': (context) => const PendingApprovalScreen(),
      },
    );
  }
}

/// Watches the user's Firestore profile in real-time and routes accordingly.
class _RoleRouter extends StatelessWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No Firestore profile yet (account created before this feature was
        // added, or directly from Firebase console). Show setup screen.
        if (snapshot.data == null || !snapshot.data!.exists) {
          return const ProfileSetupScreen();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'] as String? ?? 'student';
        // Both students AND admins must be approved before accessing the app.
        // status absent on legacy accounts → treat as approved.
        final status = data['status'] as String?;

        if (status == 'pending') {
          return const PendingApprovalScreen();
        }

        if (role == 'admin') {
          return const AdminMainScreen();
        }
        return const MainScreen();
      },
    );
  }
}

