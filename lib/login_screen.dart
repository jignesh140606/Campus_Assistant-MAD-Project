import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  String? errorMessage; // ✅ added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 10),

            // ✅ ERROR MESSAGE UI (added)
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                setState(() {
                  errorMessage = null; // reset
                });

                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email.text.trim(),
                    password: password.text.trim(),
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    if (e.code == 'user-not-found') {
                      errorMessage = 'No user found with this email';
                    } else if (e.code == 'wrong-password') {
                      errorMessage = 'Incorrect password';
                    } else if (e.code == 'invalid-email') {
                      errorMessage = 'Invalid email format';
                    } else {
                      errorMessage = e.message;
                    }
                  });
                }
              },
              child: const Text('Login'),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text('New user? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
