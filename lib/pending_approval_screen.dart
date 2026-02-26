import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Shown to students whose account is still pending admin approval.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          // Listen in real-time so the screen auto-advances when approved
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data =
                snapshot.data?.data() as Map<String, dynamic>?;
            final role = data?['role'] as String? ?? 'student';
            final isAdmin = role == 'admin';

          /// When status changes to 'approved', the StreamBuilder in
          /// main.dart (_RoleRouter) automatically re-routes to the right screen.
          /// No manual navigation needed here.

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated waiting icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (ctx, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Icon(
                        isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.hourglass_top_rounded,
                        size: 90,
                        color: isAdmin ? Colors.indigo[400] : Colors.orange[400],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      isAdmin
                          ? 'Admin Approval Pending'
                          : 'Awaiting Admin Approval',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAdmin
                          ? 'Your admin account has been registered.\n'
                            'An existing admin must approve your request before you can access the admin panel.'
                          : 'Your account has been registered successfully.\n'
                            'Please wait for the admin to approve your account before you can access the app.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Show user's details
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow(Icons.person_outline, 'Name',
                                data?['name'] ?? ''),
                            const Divider(height: 20),
                            _infoRow(Icons.email_outlined, 'Email',
                                user?.email ?? ''),
                            if (!isAdmin) ...[
                              const Divider(height: 20),
                              _infoRow(
                                  Icons.school_outlined,
                                  'Semester',
                                  data?['semester'] != null
                                      ? 'Semester ${data!['semester']}'
                                      : '—'),
                            ],
                            const Divider(height: 20),
                            _infoRow(
                                Icons.badge_outlined,
                                'Role',
                                isAdmin ? 'Admin' : 'Student'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
