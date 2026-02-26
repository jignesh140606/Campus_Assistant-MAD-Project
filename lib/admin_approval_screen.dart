import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approvals'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Students Pending'),
              Tab(text: 'Students Approved'),
              Tab(text: 'Admin Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UserList(role: 'student', status: 'pending'),
            _UserList(role: 'student', status: 'approved'),
            _UserList(role: 'admin',   status: 'pending'),
          ],
        ),
      ),
    );
  }
}

// ── Reusable list for any role + status ───────────────────────
class _UserList extends StatelessWidget {
  final String role;
  final String status;
  const _UserList({required this.role, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final isAdmin = role == 'admin';

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.hourglass_empty
                      : Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? (isAdmin ? 'No pending admin requests' : 'No pending approvals')
                      : (isAdmin ? 'No approved admins yet' : 'No approved students yet'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _StudentCard(
              docId: doc.id,
              data: data,
              status: status,
              isAdminCard: role == 'admin',
            );
          },
        );
      },
    );
  }
}

// ── Individual user card (student or admin) ──────────────────
class _StudentCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String status;
  final bool isAdminCard;

  const _StudentCard({
    required this.docId,
    required this.data,
    required this.status,
    this.isAdminCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? 'Unknown';
    final email = data['email'] as String? ?? '';
    final semester = data['semester'] as int?;

    // Badge color: admin = indigo, student = blue/green
    final badgeColor = isAdminCard ? Colors.indigo : Colors.blue;
    final avatarColor = status == 'pending'
        ? (isAdminCard ? Colors.indigo[100]! : Colors.orange[100]!)
        : Colors.green[100]!;
    final avatarIconColor = status == 'pending'
        ? (isAdminCard ? Colors.indigo : Colors.orange)
        : Colors.green;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor,
              child: Icon(
                isAdminCard ? Icons.admin_panel_settings : Icons.person,
                color: avatarIconColor,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isAdminCard ? 'Admin' : 'Student',
                          style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(email,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12)),
                  if (!isAdminCard && semester != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          'Semester $semester',
                          style: TextStyle(
                              color: Colors.blue[700], fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            if (status == 'pending')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Approve
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 28),
                    tooltip: 'Approve',
                    onPressed: () =>
                        _updateStatus(context, docId, 'approved'),
                  ),
                  // Reject
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        color: Colors.red, size: 28),
                    tooltip: isAdminCard ? 'Reject Admin' : 'Reject',
                    onPressed: () =>
                        _confirmReject(context, docId, name),
                  ),
                ],
              )
            else
              // Revoke approved
              IconButton(
                icon: const Icon(Icons.block, color: Colors.orange, size: 26),
                tooltip: 'Revoke Approval',
                onPressed: () =>
                    _updateStatus(context, docId, 'pending'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, String id, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'status': newStatus});

    if (context.mounted) {
      final label = isAdminCard ? 'Admin' : 'Student';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'approved'
              ? '$label approved successfully!'
              : '$label moved back to pending'),
          backgroundColor:
              newStatus == 'approved' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmReject(
      BuildContext context, String id, String name) async {
    final label = isAdminCard ? 'Admin' : 'Student';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject $label'),
        content: Text(
            'Are you sure you want to reject "$name"?\n\nThis will delete their account permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject & Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label rejected and removed.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
