import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTO-DELETE HELPER
// Deletes any event that has a specific time set AND that time has passed.
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _autoDeleteExpiredEvents() async {
  try {
    final now = DateTime.now();
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final dateStr = (data['date'] as String?) ?? '';
      final timeStr = (data['eventTime'] as String?) ?? '';

      if (dateStr.isEmpty || timeStr.isEmpty) continue;

      try {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
        final parts = timeStr.split(':');
        if (parts.length != 2) continue;
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h == null || m == null) continue;

        final eventDateTime = DateTime(
            parsedDate.year, parsedDate.month, parsedDate.day, h, m);

        // Delete if event time has passed
        if (eventDateTime.isBefore(now)) {
          await doc.reference.delete();
        }
      } catch (_) {
        continue;
      }
    }
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum ReminderStatus { startingSoon, today, upcoming, past }

class ReminderItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDateTime; // date + time combined
  final bool hasTime;           // whether user set a specific time
  final ReminderStatus status;
  final Duration? timeLeft;     // non-null only for startingSoon

  const ReminderItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDateTime,
    required this.hasTime,
    required this.status,
    this.timeLeft,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER – parse a Firestore event doc into ReminderItem
// ─────────────────────────────────────────────────────────────────────────────
ReminderItem? _parseEvent(
    QueryDocumentSnapshot doc, DateTime now) {
  try {
    final data = doc.data() as Map<String, dynamic>;
    final dateStr  = (data['date']      as String?) ?? '';
    final timeStr  = (data['eventTime'] as String?) ?? '';
    final title    = (data['title']     as String?) ?? 'Event';
    final desc     = (data['description'] as String?) ?? '';
    final location = (data['location']  as String?) ?? '';

    if (dateStr.isEmpty) return null;

    // Parse date – format dd/MM/yyyy
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }

    // Merge time if provided (HH:mm)
    bool hasTime = false;
    DateTime eventDateTime = DateTime(
        parsedDate.year, parsedDate.month, parsedDate.day, 0, 0);

    if (timeStr.isNotEmpty) {
      try {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          eventDateTime = DateTime(
              parsedDate.year, parsedDate.month, parsedDate.day, h, m);
          hasTime = true;
        }
      } catch (_) {}
    }

    // Classify
    final today    = DateTime(now.year, now.month, now.day);
    final evDay    = DateTime(eventDateTime.year, eventDateTime.month,
        eventDateTime.day);
    final diff     = eventDateTime.difference(now);

    ReminderStatus status;
    Duration? timeLeft;

    if (hasTime && diff.inMinutes >= 0 && diff.inMinutes <= 60) {
      status   = ReminderStatus.startingSoon;
      timeLeft = diff;
    } else if (eventDateTime.isBefore(now) &&
        !(evDay == today && !hasTime)) {
      status = ReminderStatus.past;
    } else if (evDay == today) {
      status = ReminderStatus.today;
    } else if (eventDateTime.isAfter(now)) {
      status = ReminderStatus.upcoming;
    } else {
      status = ReminderStatus.past;
    }

    return ReminderItem(
      id:            doc.id,
      title:         title,
      description:   desc,
      location:      location,
      eventDateTime: eventDateTime,
      hasTime:       hasTime,
      status:        status,
      timeLeft:      timeLeft,
    );
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  // Track IDs we've already notified to avoid repeated alerts
  final Set<String> _notifiedIds = {};

  @override
  void initState() {
    super.initState();
    // BUG03 FIX: removed _autoDeleteExpiredEvents() calls.
    // Auto-deleting events from shared Firestore caused past events to
    // permanently disappear for ALL users (admin + students).
    // Past events are now filtered client-side in _parseEvent() instead.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reminders',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Events within the next hour are highlighted',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          // Live clock badge
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                DateFormat('hh:mm a').format(_now),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _errorState();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          // Parse & classify
          final now  = _now;
          final items = snapshot.data!.docs
              .map((d) => _parseEvent(d, now))
              .whereType<ReminderItem>()
              .toList();

          if (items.isEmpty) return _emptyState();

          // Split into buckets
          final startingSoon = items
              .where((e) => e.status == ReminderStatus.startingSoon)
              .toList()
            ..sort((a, b) =>
                a.eventDateTime.compareTo(b.eventDateTime));
          final today = items
              .where((e) => e.status == ReminderStatus.today)
              .toList()
            ..sort((a, b) =>
                a.eventDateTime.compareTo(b.eventDateTime));
          final upcoming = items
              .where((e) => e.status == ReminderStatus.upcoming)
              .toList()
            ..sort((a, b) =>
                a.eventDateTime.compareTo(b.eventDateTime));
          final past = items
              .where((e) => e.status == ReminderStatus.past)
              .toList()
            ..sort((a, b) =>
                b.eventDateTime.compareTo(a.eventDateTime));

          // Fire a notification for each new "starting soon" event
          _fireStartingSoonNotifications(startingSoon);

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // ── Banner if any starting-soon ──
              if (startingSoon.isNotEmpty)
                _alertBanner(startingSoon.length),
              if (startingSoon.isNotEmpty) const SizedBox(height: 12),

              // Sections
              if (startingSoon.isNotEmpty)
                ..._section(
                    '🔔 Starting Soon',
                    const Color(0xFFE53935),
                    startingSoon),
              if (today.isNotEmpty)
                ..._section(
                    '📅 Today\'s Events',
                    const Color(0xFF1E88E5),
                    today),
              if (upcoming.isNotEmpty)
                ..._section(
                    '🗓️ Upcoming',
                    const Color(0xFF43A047),
                    upcoming),
              if (past.isNotEmpty)
                ..._section(
                    '🕐 Past Events',
                    const Color(0xFF90A4AE),
                    past),
            ],
          );
        },
      ),
    );
  }

  // ── STARTING SOON NOTIFICATIONS ──────────────────────────────────────────
  void _fireStartingSoonNotifications(List<ReminderItem> startingSoon) {
    for (final item in startingSoon) {
      if (_notifiedIds.contains(item.id)) continue; // already notified
      _notifiedIds.add(item.id);
      final mins = item.timeLeft?.inMinutes ?? 0;
      final timeLabel = mins <= 0 ? 'now' : 'in $mins min${mins == 1 ? '' : 's'}';
      NotificationService.instance.showNotification(
        id: item.id.hashCode,
        title: '🔔 Starting Soon: ${item.title}',
        body: 'Starts $timeLabel'
            '${item.location.isNotEmpty ? " @ ${item.location}" : ""}',
      );
    }
  }

  // ── ALERT BANNER ─────────────────────────────────────────────────────────
  Widget _alertBanner(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active,
              color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '⚠️ 1 event is starting within the next hour!'
                  : '⚠️ $count events are starting within the next hour!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION BUILDER ───────────────────────────────────────────────────────
  List<Widget> _section(
      String title, Color color, List<ReminderItem> items) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${items.length}',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      ...items.map((item) => _eventCard(item)),
      const SizedBox(height: 6),
    ];
  }

  // ── EVENT CARD ────────────────────────────────────────────────────────────
  Widget _eventCard(ReminderItem item) {
    final isStartingSoon = item.status == ReminderStatus.startingSoon;
    final isPast         = item.status == ReminderStatus.past;

    Color borderColor;
    Color bgColor;
    switch (item.status) {
      case ReminderStatus.startingSoon:
        borderColor = const Color(0xFFE53935);
        bgColor     = const Color(0xFFFFF3F3);
        break;
      case ReminderStatus.today:
        borderColor = const Color(0xFF1E88E5);
        bgColor     = const Color(0xFFF0F7FF);
        break;
      case ReminderStatus.upcoming:
        borderColor = const Color(0xFF43A047);
        bgColor     = const Color(0xFFF1FBF1);
        break;
      case ReminderStatus.past:
        borderColor = const Color(0xFFCFD8DC);
        bgColor     = const Color(0xFFF8F9FA);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(isStartingSoon ? 0.18 : 0.07),
            blurRadius: isStartingSoon ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isStartingSoon
                  ? Icons.notifications_active
                  : isPast
                      ? Icons.event_busy
                      : Icons.event_available,
              color: borderColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isPast
                              ? const Color(0xFF90A4AE)
                              : const Color(0xFF1A237E),
                          decoration: isPast
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    // Countdown badge for "starting soon"
                    if (isStartingSoon && item.timeLeft != null)
                      _countdownBadge(item.timeLeft!),
                  ],
                ),
                const SizedBox(height: 5),

                // Date & time
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: borderColor.withOpacity(0.8)),
                    const SizedBox(width: 5),
                    Text(
                      item.hasTime
                          ? DateFormat('dd MMM yyyy  •  hh:mm a')
                              .format(item.eventDateTime)
                          : DateFormat('dd MMM yyyy').format(item.eventDateTime),
                      style: TextStyle(
                          fontSize: 11,
                          color: borderColor.withOpacity(0.9),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                // Location
                if (item.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12,
                          color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Description
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── COUNTDOWN BADGE ───────────────────────────────────────────────────────
  Widget _countdownBadge(Duration d) {
    final mins = d.inMinutes;
    final label = mins <= 0
        ? 'Now!'
        : mins == 1
            ? '1 min'
            : '$mins mins';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY / ERROR ─────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No events found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text('Add events in Campus Events to see reminders here.',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          const Text('Error loading reminders',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
