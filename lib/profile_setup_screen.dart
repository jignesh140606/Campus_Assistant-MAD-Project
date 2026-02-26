import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Shown to users who have a Firebase Auth account but no Firestore profile yet
/// (e.g. accounts created before the profile feature was added).
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _adminCodeCtrl = TextEditingController();
  String _role = 'student';
  int _semester = 1;
  bool _isLoading = false;
  String? _error;

  // Change this code to whatever you want your admin secret to be
  static const _adminSecret = 'ADMIN2024';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Icon(Icons.manage_accounts,
                  size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Name
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Role
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 16),

              // Semester (students)
              if (_role == 'student') ...[
                DropdownButtonFormField<int>(
                  value: _semester,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    6,
                    (i) => DropdownMenuItem(
                        value: i + 1, child: Text('Semester ${i + 1}')),
                  ),
                  onChanged: (v) => setState(() => _semester = v!),
                ),
                const SizedBox(height: 16),
              ],

              // Admin secret code
              if (_role == 'admin') ...[
                TextField(
                  controller: _adminCodeCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Admin Secret Code',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    hintText: 'Enter the admin secret code',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save & Continue',
                        style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async =>
                    await FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    if (_role == 'admin') {
      if (_adminCodeCtrl.text.trim() != _adminSecret) {
        setState(() => _error = 'Invalid admin code');
        return;
      }
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final doc = <String, dynamic>{
        'name': name,
        'email': user.email ?? '',
        'role': _role,
        'status': 'approved', // setup screen only for existing accounts
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (_role == 'student') doc['semester'] = _semester;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(doc);

      // The StreamBuilder in main.dart will re-build and route correctly
    } catch (e) {
      setState(() {
        _error = 'Failed to save profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _adminCodeCtrl.dispose();
    super.dispose();
  }
}
