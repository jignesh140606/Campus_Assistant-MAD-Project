import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Maps Dart weekday (1=Mon â€¦ 7=Sun) â†’ timetable day label
const _kWeekdayLabel = {
  1: 'MON',
  2: 'TUE',
  3: 'WED',
  4: 'THU',
  5: 'FRI',
  6: 'SAT',
};

const _kDayColors = [
  Colors.blue,
  Colors.purple,
  Colors.teal,
  Colors.orange,
  Colors.indigo,
  Colors.pink,
];

class TodaysClassesScreen extends StatefulWidget {
  const TodaysClassesScreen({super.key});

  @override
  State<TodaysClassesScreen> createState() => _TodaysClassesScreenState();
}

class _TodaysClassesScreenState extends State<TodaysClassesScreen> {
  int? _userSemester;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserSemester();
  }

  Future<void> _loadUserSemester() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) {
      setState(() {
        _userSemester = doc.data()?['semester'] as int?;
        _loadingProfile = false;
      });
    }
  }

  // Today's timetable day label â€” null if Sunday (no classes)
  String? get _todayDay =>
      _kWeekdayLabel[DateTime.now().weekday];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayLabel = _todayDay;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Classes"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : _userSemester == null
              ? const _NoSemesterWidget()
              // Sunday â€” no classes
              : todayLabel == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.weekend_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('It\'s Sunday  ðŸŽ‰',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('No classes today. Enjoy your day off!',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          color:
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: Row(
                            children: [
                              Icon(Icons.school,
                                  color: theme.colorScheme.primary,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sem $_userSemester  â€¢  ${DateFormat('EEEE, d MMM yyyy').format(now)}',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Class list for today
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('today_classes')
                                .where('semester',
                                    isEqualTo: _userSemester)
                                .where('day', isEqualTo: todayLabel)
                                .orderBy('sortOrder')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child:
                                        Text('Error: ${snapshot.error}'));
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final docs = snapshot.data?.docs ?? [];

                              if (docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_busy,
                                          size: 64,
                                          color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No classes scheduled for $todayLabel',
                                        style: theme
                                            .textTheme.titleMedium
                                            ?.copyWith(
                                                color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Check with your admin',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final data = docs[index].data()
                                      as Map<String, dynamic>;
                                  return _ClassCard(
                                      data: data, index: index);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const _ClassCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = _kDayColors[index % _kDayColors.length];

    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['subject'] ?? 'Unknown Subject',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _infoRow(
                Icons.access_time,
                '${data['timeStart'] ?? ''} â€“ ${data['timeEnd'] ?? ''}',
                color,
              ),
              const SizedBox(height: 4),
              _infoRow(Icons.person_outline,
                  data['teacher'] ?? 'N/A', Colors.grey[700]!),
              const SizedBox(height: 4),
              _infoRow(Icons.room_outlined,
                  data['room'] ?? 'N/A', Colors.grey[700]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _NoSemesterWidget extends StatelessWidget {
  const _NoSemesterWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_outlined,
              size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('No semester assigned to your account.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Please contact your admin.',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
