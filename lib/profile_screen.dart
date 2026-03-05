// ignore_for_file: deprecated_member_use
// Lab 11 – Option B: Image / Media Upload
// Users can update their profile photo via camera or gallery.
// Photo is uploaded to Firebase Storage; URL saved in Firestore.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _newPhotoUrl;   // overrides Firestore value after a successful upload
  bool _uploading = false;
  double _uploadProgress = 0; // 0.0 – 1.0

  // ── Pick image & upload to Firebase Storage ────────────────────────────────
  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 55,   // ~30–60 KB for a 400×400 image → fast upload
      maxWidth: 400,
      maxHeight: 400,     // cap both axes so portrait shots don't stay huge
    );
    if (picked == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    try {
      // readAsBytes() is safe on Android 13+ scoped storage (no File path needed)
      final bytes = await picked.readAsBytes();
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

      // Use an UploadTask so we can stream real progress to the UI
      final task = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      task.snapshotEvents.listen((snap) {
        if (mounted && snap.totalBytes > 0) {
          setState(() {
            _uploadProgress = snap.bytesTransferred / snap.totalBytes;
          });
        }
      });

      await task; // wait for completion
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': downloadUrl});

      if (mounted) {
        setState(() {
          _newPhotoUrl = downloadUrl;
          _uploading = false;
          _uploadProgress = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile photo updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadProgress = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Bottom sheet – camera or gallery ──────────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Update Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use camera to capture'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF3E5F5),
                  child: Icon(Icons.photo_library, color: Color(0xFF7B1FA2)),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an existing photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build Screen ──────────────────────────────────────────────────────────
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

          // Prefer just-uploaded URL over stored Firestore URL
          final storedUrl = data?['photoUrl'] as String?;
          final displayUrl = _newPhotoUrl ?? storedUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Avatar with camera-edit overlay ────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.15),
                      backgroundImage: displayUrl != null
                          ? NetworkImage(displayUrl) as ImageProvider
                          : null,
                      child: _uploading
                          ? SizedBox(
                              width: 44,
                              height: 44,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _uploadProgress > 0
                                        ? _uploadProgress
                                        : null,
                                    strokeWidth: 3,
                                  ),
                                  if (_uploadProgress > 0)
                                    Text(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            )
                          : (displayUrl == null
                              ? Icon(
                                  role == 'admin'
                                      ? Icons.admin_panel_settings
                                      : Icons.person,
                                  size: 52,
                                  color: theme.colorScheme.primary,
                                )
                              : null),
                    ),
                    // Camera edit button
                    Positioned(
                      bottom: 0,
                      right: -4,
                      child: GestureDetector(
                        onTap: _uploading ? null : _showImageSourceSheet,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2.5),
                          ),
                          padding: const EdgeInsets.all(7),
                          child: const Icon(Icons.camera_alt,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_uploading) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _uploadProgress > 0
                            ? 'Uploading ${(_uploadProgress * 100).toInt()}%…'
                            : 'Preparing image…',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],

                const SizedBox(height: 16),
                Text(name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),

                // ── Role badge ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        role == 'admin' ? Colors.red[50] : Colors.blue[50],
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

                // ── Semester badge (students only) ─────────────────────────
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
                          color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 12),

                // ── Profile detail tiles ────────────────────────────────────
                _ProfileTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? ''),
                if (role == 'student' && semester != null)
                  _ProfileTile(
                      icon: Icons.school_outlined,
                      label: 'Semester',
                      value: 'Semester $semester'),
                _ProfileTile(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: role == 'admin' ? 'Administrator' : 'Student'),
                _ProfileTile(
                    icon: Icons.photo_camera_outlined,
                    label: 'Profile Photo',
                    value: displayUrl != null
                        ? 'Photo uploaded ✓'
                        : 'No photo – tap the camera icon above'),

                const SizedBox(height: 24),

                // ── Change photo button ─────────────────────────────────────
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  onPressed: _uploading ? null : _showImageSourceSheet,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Change Profile Photo'),
                ),
                const SizedBox(height: 12),

                // ── Logout ─────────────────────────────────────────────────
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

