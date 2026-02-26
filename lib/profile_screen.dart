import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['name'] as String? ?? 'Student';
          final role = data?['role'] as String? ?? 'student';
          final semester = data?['semester'] as int?;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(
                    role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: role == 'admin'
                        ? Colors.red[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: role == 'admin'
                          ? Colors.red[200]!
                          : Colors.blue[200]!,
                    ),
                  ),
                  child: Text(
                    role == 'admin' ? 'Admin' : 'Student',
                    style: TextStyle(
                      color: role == 'admin' ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Semester badge (students only)
                if (role == 'student' && semester != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      'Semester $semester',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 12),
                // Profile details list
                _ProfileTile(
                    icon: Icons.email_outlined, label: 'Email',
                    value: user?.email ?? ''),
                if (role == 'student' && semester != null)
                  _ProfileTile(
                      icon: Icons.school_outlined, label: 'Semester',
                      value: 'Semester $semester'),
                _ProfileTile(
                    icon: Icons.badge_outlined, label: 'Role',
                    value: role == 'admin' ? 'Administrator' : 'Student'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      contentPadding: EdgeInsets.zero,
    );
  }
}

