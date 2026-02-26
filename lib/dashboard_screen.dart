import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'campus_events_screen.dart';
import 'emergency_info_screen.dart';
import 'academic_calendar_screen.dart';
import 'reminders_screen.dart';
import 'todays_classes_screen.dart';

// Weekday → timetable day label (mirrors TodaysClassesScreen)
const _kWeekdayLabel = {
  1: 'MON',
  2: 'TUE',
  3: 'WED',
  4: 'THU',
  5: 'FRI',
  6: 'SAT',
};

const _kClassColors = [
  Colors.blue,
  Colors.purple,
  Colors.teal,
  Colors.orange,
  Colors.indigo,
  Colors.pink,
];

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _studentName = '';
  int? _semester;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) {
      final data = doc.data();
      setState(() {
        _studentName = (data?['name'] as String?) ?? 'Student';
        _semester = data?['semester'] as int?;
        _loading = false;
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String? get _todayDay => _kWeekdayLabel[DateTime.now().weekday];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // ── 1. Header Banner ─────────────────────────────────────
                  _HeaderBanner(
                    greeting: _greeting,
                    name: _studentName,
                    semester: _semester,
                    now: now,
                    theme: theme,
                  ),

                  const SizedBox(height: 20),

                  // ── 2. Today's Classes ────────────────────────────────────
                  _SectionHeader(
                    icon: Icons.class_outlined,
                    title: "Today's Classes",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TodaysClassesScreen(),
                      ),
                    ),
                  ),
                  _TodaysClassesPreview(
                    semester: _semester,
                    todayDay: _todayDay,
                    theme: theme,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TodaysClassesScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 3. Quick Actions ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Quick Access',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionsRow(theme: theme),

                  const SizedBox(height: 20),

                  // ── 4. Upcoming Events / Reminders ────────────────────────
                  _SectionHeader(
                    icon: Icons.event_note_outlined,
                    title: 'Upcoming Events',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemindersScreen()),
                    ),
                  ),
                  _UpcomingEventsPreview(
                    theme: theme,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemindersScreen()),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 5. Campus Events ──────────────────────────────────────
                  _SectionHeader(
                    icon: Icons.celebration_outlined,
                    title: 'Campus Events',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CampusEventsScreen()),
                    ),
                  ),
                  _CampusEventsPreview(
                    theme: theme,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CampusEventsScreen()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Header Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderBanner extends StatelessWidget {
  final String greeting;
  final String name;
  final int? semester;
  final DateTime now;
  final ThemeData theme;

  const _HeaderBanner({
    required this.greeting,
    required this.name,
    required this.semester,
    required this.now,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (semester != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Sem $semester',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(now),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header with "View All"
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Today's Classes Preview
// ─────────────────────────────────────────────────────────────────────────────
class _TodaysClassesPreview extends StatelessWidget {
  final int? semester;
  final String? todayDay;
  final ThemeData theme;
  final VoidCallback onViewAll;

  const _TodaysClassesPreview({
    required this.semester,
    required this.todayDay,
    required this.theme,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (semester == null) {
      return _InfoTile(
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
        message: 'No semester assigned. Contact your admin.',
      );
    }
    if (todayDay == null) {
      return _InfoTile(
        icon: Icons.weekend_outlined,
        color: Colors.green,
        message: "It's Sunday — no classes today! 🎉",
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('today_classes')
            .where('semester', isEqualTo: semester)
            .where('day', isEqualTo: todayDay)
            .orderBy('sortOrder')
            .limit(3)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _InfoTile(
              icon: Icons.event_busy_outlined,
              color: Colors.grey,
              message: 'No classes scheduled for today.',
            );
          }
          return Column(
            children: [
              ...docs.asMap().entries.map((entry) {
                final data =
                    entry.value.data() as Map<String, dynamic>;
                final color =
                    _kClassColors[entry.key % _kClassColors.length];
                return _ClassPreviewCard(data: data, color: color);
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ClassPreviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color color;

  const _ClassPreviewCard({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['subject'] ?? 'Unknown Subject',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['timeStart'] ?? ''} – ${data['timeEnd'] ?? ''}  •  ${data['room'] ?? ''}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.person_outline, size: 14, color: color),
                  const SizedBox(height: 2),
                  Text(
                    data['teacher'] ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Quick Actions Row
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final ThemeData theme;
  const _QuickActionsRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: 'Calendar',
        color: Colors.indigo,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AcademicCalendarScreen())),
      ),
      _QuickAction(
        icon: Icons.alarm_outlined,
        label: 'Reminders',
        color: Colors.deepOrange,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RemindersScreen())),
      ),
      _QuickAction(
        icon: Icons.celebration_outlined,
        label: 'Events',
        color: Colors.teal,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CampusEventsScreen())),
      ),
      _QuickAction(
        icon: Icons.local_hospital_outlined,
        label: 'Emergency',
        color: Colors.red,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EmergencyInfoScreen())),
      ),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => actions[i],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Upcoming Events Preview (from `events` collection)
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingEventsPreview extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onViewAll;

  const _UpcomingEventsPreview(
      {required this.theme, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: false)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ));
          }
          final docs = snapshot.data?.docs ?? [];

          // Filter to upcoming only and take first 3
          final upcoming = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final dateStr = (data['date'] as String?) ?? '';
            if (dateStr.isEmpty) return false;
            try {
              final d = DateFormat('dd/MM/yyyy').parse(dateStr);
              return !d.isBefore(
                  DateTime(now.year, now.month, now.day));
            } catch (_) {
              return false;
            }
          }).take(3).toList();

          if (upcoming.isEmpty) {
            return _InfoTile(
              icon: Icons.event_available_outlined,
              color: Colors.blue,
              message: 'No upcoming events right now.',
            );
          }

          return Column(
            children: upcoming.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _EventPreviewCard(data: data, theme: theme);
            }).toList(),
          );
        },
      ),
    );
  }
}

class _EventPreviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;

  const _EventPreviewCard({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    final date = (data['date'] as String?) ?? '';
    final time = (data['eventTime'] as String?) ?? '';
    final location = (data['location'] as String?) ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event,
                  color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['title'] as String?) ?? 'Event',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(date,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                      if (time.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.access_time,
                            size: 11, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(time,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ],
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 11, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(location,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Campus Events Preview (same collection, most recent)
// ─────────────────────────────────────────────────────────────────────────────
class _CampusEventsPreview extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onViewAll;

  const _CampusEventsPreview(
      {required this.theme, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: true)
            .limit(2)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _InfoTile(
              icon: Icons.celebration_outlined,
              color: Colors.teal,
              message: 'No campus events posted yet.',
            );
          }
          return Column(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.celebration,
                        color: Colors.teal, size: 20),
                  ),
                  title: Text(
                    (data['title'] as String?) ?? 'Event',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (data['description'] as String?) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    (data['date'] as String?) ?? '',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: Info Tile (empty / no-data state)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _InfoTile({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.07),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.85), fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
