import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Approvals'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StudentList(status: 'pending'),
            _StudentList(status: 'approved'),
          ],
        ),
      ),
    );
  }
}

// ── Reusable list for pending / approved ──────────────────────
class _StudentList extends StatelessWidget {
  final String status;
  const _StudentList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
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
                      ? 'No pending approvals'
                      : 'No approved students yet',
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
            );
          },
        );
      },
    );
  }
}

// ── Individual student card ───────────────────────────────────
class _StudentCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String status;

  const _StudentCard(
      {required this.docId, required this.data, required this.status});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? 'Unknown';
    final email = data['email'] as String? ?? '';
    final semester = data['semester'] as int?;

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
              backgroundColor: status == 'pending'
                  ? Colors.orange[100]
                  : Colors.green[100],
              child: Icon(
                Icons.person,
                color: status == 'pending' ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(email,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12)),
                  if (semester != null)
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
                    tooltip: 'Reject',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'approved'
              ? 'Student approved successfully!'
              : 'Student moved back to pending'),
          backgroundColor:
              newStatus == 'approved' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmReject(
      BuildContext context, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Student'),
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
          const SnackBar(
            content: Text('Student rejected and removed.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
