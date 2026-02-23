import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'helpers/test_data_helper.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<DocumentSnapshot>> _eventsByDate = {};
  List<DocumentSnapshot> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _buildEventsMap(List<DocumentSnapshot> events) {
    _eventsByDate.clear();
    Set<String> processedEventIds = {}; // Track processed event IDs to prevent duplicates

    for (var event in events) {
      try {
        final data = event.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final eventId = event.id;
        final eventName = data['eventName'] ?? data['title'] ?? 'Unknown Event';

        // Skip if we've already processed this event
        if (processedEventIds.contains(eventId)) {
          continue;
        }

        final startDate = data['startDate'] as Timestamp?;
        final endDate = data['endDate'] as Timestamp?;

        if (startDate != null && endDate != null) {
          DateTime currentDate = _normalizeDate(startDate.toDate());
          final end = _normalizeDate(endDate.toDate());

          while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
            if (!_eventsByDate.containsKey(currentDate)) {
              _eventsByDate[currentDate] = [];
            }
            _eventsByDate[currentDate]!.add(event);
            currentDate = currentDate.add(const Duration(days: 1));
          }
          processedEventIds.add(eventId);
        } else {
          final dateStr = data['date'] as String?;
          if (dateStr != null && dateStr.isNotEmpty) {
            DateTime? parsedDate;

            try {
              parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
            } catch (e) {
              try {
                parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
              } catch (e2) {
                // Ignore if date format is incorrect
              }
            }

            if (parsedDate != null) {
              final normalizedDate = _normalizeDate(parsedDate);
              if (!_eventsByDate.containsKey(normalizedDate)) {
                _eventsByDate[normalizedDate] = [];
              }
              _eventsByDate[normalizedDate]!.add(event);
              processedEventIds.add(eventId);
            }
          }
        }
      } catch (e) {
        // Ignore errors in event processing
      }
    }
  }

  List<DocumentSnapshot> _getEventsForDay(DateTime day) {
    return _eventsByDate[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add),
            tooltip: 'Add Sample Holidays',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Test Data'),
                  content: const Text('Add sample holidays for testing?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await TestDataHelper.addSampleHolidays();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Sample holidays added!')),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('academic_events')
            .orderBy('startDate', descending: false)
            .snapshots(),
        builder: (context, academicSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('events')
                .orderBy('createdAt', descending: false)
                .snapshots(),
            builder: (context, campusSnapshot) {
              if (academicSnapshot.connectionState == ConnectionState.waiting ||
                  campusSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (academicSnapshot.hasError || campusSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('Error loading calendar'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              List<DocumentSnapshot> combinedEvents = [];
              if (academicSnapshot.hasData) {
                combinedEvents.addAll(academicSnapshot.data!.docs);
              }
              if (campusSnapshot.hasData) {
                combinedEvents.addAll(campusSnapshot.data!.docs);
              }

              if (combinedEvents.isEmpty) {
                return const Center(
                  child: Text('No events available'),
                );
              }

              _allEvents = combinedEvents;
              _buildEventsMap(_allEvents);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 900;

                  if (isWideScreen) {
                    return Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: _buildCalendarCard(),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          flex: 1,
                          child: _buildEventDetailsCard(),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: _buildCalendarCard(),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          flex: 1,
                          child: _buildEventDetailsCard(),
                        ),
                      ],
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildCalendarCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Calendar',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  defaultTextStyle: const TextStyle(fontSize: 13),
                  markersMaxCount: 2,
                  markerDecoration: BoxDecoration(
                    color: Colors.red.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70),
                  ),
                  markerSize: 6,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.blue.shade700,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.blue.shade700,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailsCard() {
    final events = _getEventsForDay(_selectedDay);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events (${events.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDay),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 56,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events on this day',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _buildEventDetailTile(events[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailTile(DocumentSnapshot event) {
    try {
      final data = event.data() as Map<String, dynamic>?;
      if (data == null) return const SizedBox.shrink();

      final eventName = (data['eventName'] as String?) ?? (data['title'] as String?) ?? 'Event';
      final eventType = data['eventType'] as String? ?? 'Activity';
      
      final startDate = data['startDate'] as Timestamp?;
      final endDate = data['endDate'] as Timestamp?;
      final dateStr = data['date'] as String?;
      
      String dateDisplay = 'N/A';
      if (startDate != null && endDate != null) {
        final startDateStr = DateFormat('dd MMM yyyy').format(startDate.toDate());
        final endDateStr = DateFormat('dd MMM yyyy').format(endDate.toDate());
        dateDisplay = startDateStr == endDateStr ? startDateStr : '$startDateStr - $endDateStr';
      } else if (dateStr != null && dateStr.isNotEmpty) {
        dateDisplay = dateStr;
      }

      final description = (data['description'] as String?) ?? '';

      Color eventColor = Colors.grey;
      IconData eventIcon = Icons.event;

      switch (eventType.toLowerCase()) {
        case 'festival':
          eventColor = Colors.orange;
          eventIcon = Icons.celebration;
          break;
        case 'holiday':
          eventColor = Colors.red;
          eventIcon = Icons.beach_access;
          break;
        case 'exam':
          eventColor = Colors.purple;
          eventIcon = Icons.assignment;
          break;
        case 'important':
          eventColor = Colors.green;
          eventIcon = Icons.star;
          break;
        default:
          eventColor = Colors.blue;
          eventIcon = Icons.event_available;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: eventColor, width: 5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: eventColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    eventIcon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: eventColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          eventType,
                          style: TextStyle(
                            fontSize: 10,
                            color: eventColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
