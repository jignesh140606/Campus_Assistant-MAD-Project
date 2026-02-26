import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class CalendarEvent {
  final String name;
  final String type; // Holiday | Festival | Exam | Academic | Important
  final DateTime start;
  final DateTime end;
  final String description;

  const CalendarEvent({
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    required this.description,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 2026 INDIAN CALENDAR – HOLIDAYS & FESTIVALS ONLY
// (Source: calendarlabs.com / india.gov.in verified dates)
// ─────────────────────────────────────────────────────────────────────────────
final List<CalendarEvent> _indiaCalendar2026 = [

  // ── JANUARY ────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'New Year Day',
    type: 'Holiday',
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 1, 1),
    description: 'New Year Day – public holiday across India.',
  ),
  CalendarEvent(
    name: 'Makar Sankranti / Pongal / Uttarayan',
    type: 'Festival',
    start: DateTime(2026, 1, 14),
    end: DateTime(2026, 1, 14),
    description: 'Harvest festival celebrated as Uttarayan (Gujarat), Pongal (Tamil Nadu) and Makar Sankranti (pan-India). Kite-flying day.',
  ),
  CalendarEvent(
    name: 'Republic Day',
    type: 'Holiday',
    start: DateTime(2026, 1, 26),
    end: DateTime(2026, 1, 26),
    description: 'National Holiday – 77th Republic Day. India\'s constitution came into effect on this day in 1950.',
  ),

  // ── FEBRUARY ───────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Maha Shivratri',
    type: 'Festival',
    start: DateTime(2026, 2, 15),
    end: DateTime(2026, 2, 15),
    description: 'The Great Night of Lord Shiva – one of the most significant Hindu festivals. Observed with fasting and night-long prayers.',
  ),

  // ── MARCH ──────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Holika Dahan',
    type: 'Festival',
    start: DateTime(2026, 3, 3),
    end: DateTime(2026, 3, 3),
    description: 'Holika Dahan – bonfire lit on the eve of Holi, symbolising the victory of good over evil.',
  ),
  CalendarEvent(
    name: 'Dhuleti / Rangwali Holi',
    type: 'Festival',
    start: DateTime(2026, 3, 4),
    end: DateTime(2026, 3, 4),
    description: 'Dhuleti (Dhulandi) – Festival of Colours. People celebrate by throwing coloured powder and water. Public holiday.',
  ),
  CalendarEvent(
    name: 'Ugadi / Gudi Padwa',
    type: 'Festival',
    start: DateTime(2026, 3, 19),
    end: DateTime(2026, 3, 19),
    description: 'Hindu New Year celebrated as Ugadi (Andhra Pradesh, Telangana, Karnataka) and Gudi Padwa (Maharashtra).',
  ),
  CalendarEvent(
    name: 'Eid-ul-Fitr',
    type: 'Festival',
    start: DateTime(2026, 3, 21),
    end: DateTime(2026, 3, 21),
    description: 'Eid-ul-Fitr – marks the end of Ramadan. One of the most important Islamic festivals. Public holiday.',
  ),
  CalendarEvent(
    name: 'Ram Navami',
    type: 'Festival',
    start: DateTime(2026, 3, 26),
    end: DateTime(2026, 3, 26),
    description: 'Birth anniversary of Lord Rama – celebrated with prayers, processions and recitation of Ramayana.',
  ),
  CalendarEvent(
    name: 'Mahavir Jayanti',
    type: 'Festival',
    start: DateTime(2026, 3, 31),
    end: DateTime(2026, 3, 31),
    description: 'Birth anniversary of Lord Mahavira, the 24th Tirthankara of Jainism. National holiday.',
  ),

  // ── APRIL ──────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Good Friday',
    type: 'Holiday',
    start: DateTime(2026, 4, 3),
    end: DateTime(2026, 4, 3),
    description: 'Good Friday – commemorates the crucifixion of Jesus Christ. National public holiday.',
  ),
  CalendarEvent(
    name: 'Dr. Ambedkar Jayanti / Baisakhi',
    type: 'Holiday',
    start: DateTime(2026, 4, 14),
    end: DateTime(2026, 4, 14),
    description: 'Dr. B.R. Ambedkar\'s birth anniversary (national holiday) + Baisakhi – harvest festival and Sikh New Year.',
  ),

  // ── MAY ────────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Buddha Purnima / Labour Day',
    type: 'Holiday',
    start: DateTime(2026, 5, 1),
    end: DateTime(2026, 5, 1),
    description: 'Buddha Purnima – birth, enlightenment & death anniversary of Gautama Buddha. Also International Labour Day.',
  ),
  CalendarEvent(
    name: 'Eid ul-Adha (Bakri Id)',
    type: 'Festival',
    start: DateTime(2026, 5, 27),
    end: DateTime(2026, 5, 27),
    description: 'Eid ul-Adha (Bakri Id) – Festival of Sacrifice commemorating Ibrahim\'s willingness to sacrifice his son. Public holiday.',
  ),

  // ── JUNE ───────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Muharram',
    type: 'Festival',
    start: DateTime(2026, 6, 26),
    end: DateTime(2026, 6, 26),
    description: 'Muharram – Islamic New Year and day of mourning for the martyrdom of Imam Husain. Public holiday.',
  ),

  // ── JULY ───────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Rath Yatra',
    type: 'Festival',
    start: DateTime(2026, 7, 16),
    end: DateTime(2026, 7, 16),
    description: 'Rath Yatra – chariot procession of Lord Jagannath celebrated with great fervour, especially in Puri, Odisha.',
  ),

  // ── AUGUST ─────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Independence Day',
    type: 'Holiday',
    start: DateTime(2026, 8, 15),
    end: DateTime(2026, 8, 15),
    description: 'National Holiday – 80th Independence Day of India. Flag hoisting ceremonies held across the country.',
  ),
  CalendarEvent(
    name: 'Onam',
    type: 'Festival',
    start: DateTime(2026, 8, 26),
    end: DateTime(2026, 8, 26),
    description: 'Onam – harvest festival of Kerala. Celebrated with traditional boat races, flower carpets (Pookalam) and feasts.',
  ),
  CalendarEvent(
    name: 'Milad-un-Nabi',
    type: 'Festival',
    start: DateTime(2026, 8, 26),
    end: DateTime(2026, 8, 26),
    description: 'Milad-un-Nabi – birth anniversary of Prophet Muhammad (PBUH). Public holiday.',
  ),
  CalendarEvent(
    name: 'Raksha Bandhan',
    type: 'Festival',
    start: DateTime(2026, 8, 28),
    end: DateTime(2026, 8, 28),
    description: 'Raksha Bandhan – sisters tie a protective thread (rakhi) on their brothers\' wrists as a symbol of love and protection.',
  ),

  // ── SEPTEMBER ──────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Janmashtami',
    type: 'Festival',
    start: DateTime(2026, 9, 4),
    end: DateTime(2026, 9, 4),
    description: 'Janmashtami – birth anniversary of Lord Krishna. Celebrated with midnight prayers, Dahi Handi and bhajans.',
  ),
  CalendarEvent(
    name: "Teachers' Day",
    type: 'Important',
    start: DateTime(2026, 9, 5),
    end: DateTime(2026, 9, 5),
    description: "Teachers' Day – birth anniversary of Dr. Sarvepalli Radhakrishnan. Students honour their teachers across India.",
  ),
  CalendarEvent(
    name: 'Ganesh Chaturthi',
    type: 'Festival',
    start: DateTime(2026, 9, 14),
    end: DateTime(2026, 9, 24),
    description: 'Ganesh Chaturthi (Vinayaka Chaturthi) – 10-day festival celebrating the birth of Lord Ganesha. Grand processions on Anant Chaturdashi.',
  ),

  // ── OCTOBER ────────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Gandhi Jayanti',
    type: 'Holiday',
    start: DateTime(2026, 10, 2),
    end: DateTime(2026, 10, 2),
    description: 'National Holiday – Birth anniversary of Mahatma Gandhi, Father of the Nation.',
  ),
  CalendarEvent(
    name: 'Navratri',
    type: 'Festival',
    start: DateTime(2026, 10, 11),
    end: DateTime(2026, 10, 19),
    description: 'Shardiya Navratri – nine nights of worship of Goddess Durga. Garba and Dandiya Raas celebrations.',
  ),
  CalendarEvent(
    name: 'Dussehra (Vijayadashami)',
    type: 'Holiday',
    start: DateTime(2026, 10, 20),
    end: DateTime(2026, 10, 20),
    description: 'Vijayadashami – victory of Lord Rama over Ravana, symbolising the triumph of good over evil. Public holiday.',
  ),

  // ── NOVEMBER ───────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Dhanteras',
    type: 'Festival',
    start: DateTime(2026, 11, 6),
    end: DateTime(2026, 11, 6),
    description: 'Dhanteras – Diwali begins. Day of wealth and prosperity; people buy gold, silver and utensils.',
  ),
  CalendarEvent(
    name: 'Naraka Chaturdashi (Choti Diwali)',
    type: 'Festival',
    start: DateTime(2026, 11, 7),
    end: DateTime(2026, 11, 7),
    description: 'Naraka Chaturdashi – small Diwali; oil bath, lighting of diyas and bursting of crackers.',
  ),
  CalendarEvent(
    name: 'Diwali (Deepavali)',
    type: 'Holiday',
    start: DateTime(2026, 11, 8),
    end: DateTime(2026, 11, 8),
    description: 'Diwali – Festival of Lights. Lakshmi Puja performed after sunset. Most celebrated Hindu festival. Public holiday.',
  ),
  CalendarEvent(
    name: 'Govardhan Puja',
    type: 'Festival',
    start: DateTime(2026, 11, 9),
    end: DateTime(2026, 11, 9),
    description: 'Govardhan Puja / Annakut – offerings made to Lord Krishna; celebration of the lifting of Govardhan Hill.',
  ),
  CalendarEvent(
    name: 'Bhai Dooj',
    type: 'Festival',
    start: DateTime(2026, 11, 10),
    end: DateTime(2026, 11, 10),
    description: 'Bhai Dooj – brothers visit sisters and sisters apply tilak on brothers\' foreheads. Celebration of sibling bond.',
  ),
  CalendarEvent(
    name: "Children's Day",
    type: 'Important',
    start: DateTime(2026, 11, 14),
    end: DateTime(2026, 11, 14),
    description: "Children's Day – birth anniversary of India's first Prime Minister Pandit Jawaharlal Nehru.",
  ),
  CalendarEvent(
    name: 'Guru Nanak Jayanti',
    type: 'Holiday',
    start: DateTime(2026, 11, 24),
    end: DateTime(2026, 11, 24),
    description: 'Guru Nanak Jayanti (Gurpurab) – birth anniversary of Guru Nanak Dev Ji, founder of Sikhism. National holiday.',
  ),

  // ── DECEMBER ───────────────────────────────────────────────────────────────
  CalendarEvent(
    name: 'Christmas',
    type: 'Holiday',
    start: DateTime(2026, 12, 25),
    end: DateTime(2026, 12, 25),
    description: 'Christmas Day – birth of Jesus Christ. National public holiday celebrated across India.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

/// Expand every multi-day event into a date→events map.
Map<DateTime, List<CalendarEvent>> _buildEventMap(List<CalendarEvent> events) {
  final Map<DateTime, List<CalendarEvent>> map = {};
  for (final ev in events) {
    DateTime cursor = _normalise(ev.start);
    final last = _normalise(ev.end);
    while (!cursor.isAfter(last)) {
      map.putIfAbsent(cursor, () => []).add(ev);
      cursor = cursor.add(const Duration(days: 1));
    }
  }
  return map;
}

Color _typeColor(String type) {
  switch (type.toLowerCase()) {
    case 'holiday':
      return const Color(0xFFE53935);   // red
    case 'festival':
      return const Color(0xFFFF8F00);   // amber
    case 'exam':
      return const Color(0xFF8E24AA);   // purple
    case 'academic':
      return const Color(0xFF00897B);   // teal
    case 'important':
      return const Color(0xFF43A047);   // green
    default:
      return const Color(0xFF1E88E5);   // blue
  }
}

IconData _typeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'holiday':   return Icons.beach_access;
    case 'festival':  return Icons.celebration;
    case 'exam':      return Icons.assignment;
    case 'academic':  return Icons.school;
    case 'important': return Icons.star;
    default:          return Icons.event;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final Map<DateTime, List<CalendarEvent>> _eventMap =
      _buildEventMap(_indiaCalendar2026);

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay  = DateTime.now();
    _selectedDay = _normalise(DateTime.now());
  }

  List<CalendarEvent> _eventsFor(DateTime day) =>
      _eventMap[_normalise(day)] ?? [];

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final selectedEvents = _eventsFor(_selectedDay);
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'India Calendar 2026',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Holidays & Festivals – Full Year',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  child: _calendarPanel(),
                ),
                const SizedBox(width: 4),
                Expanded(child: _eventsPanel(selectedEvents)),
              ],
            )
          : Column(
              children: [
                _calendarPanel(),
                Expanded(child: _eventsPanel(selectedEvents)),
              ],
            ),
    );
  }

  // ── LEFT PANEL : CALENDAR ──────────────────────────────────────────────────
  Widget _calendarPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header gradient bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'India 2026 – ${DateFormat('MMMM').format(_focusedDay)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // TableCalendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TableCalendar<CalendarEvent>(
              firstDay: DateTime(2026, 1, 1),
              lastDay: DateTime(2026, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              calendarFormat: _format,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.twoWeeks: '2 Weeks',
                CalendarFormat.week: 'Week',
              },
              eventLoader: _eventsFor,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = _normalise(selected);
                  _focusedDay  = focused;
                });
              },
              onFormatChanged: (f) => setState(() => _format = f),
              onPageChanged:   (f) => setState(() => _focusedDay = f),
              calendarBuilders: CalendarBuilders(
                // Custom marker dots coloured by event type
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final distinct = events
                      .map((e) => e.type)
                      .toSet()
                      .take(3)
                      .toList();
                  return Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: distinct.map((t) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _typeColor(t),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                weekendTextStyle: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
                defaultTextStyle: const TextStyle(fontSize: 13),
                cellMargin: const EdgeInsets.all(4),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                titleTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: Color(0xFF1565C0), size: 22),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: Color(0xFF1565C0), size: 22),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF546E7A),
                ),
                weekendStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _dot('Holiday',   const Color(0xFFE53935)),
                _dot('Festival',  const Color(0xFFFF8F00)),
                _dot('Important', const Color(0xFF43A047)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF546E7A))),
        ],
      );

  // ── RIGHT PANEL : EVENTS ───────────────────────────────────────────────────
  Widget _eventsPanel(List<CalendarEvent> events) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: events.isEmpty
                    ? [const Color(0xFF78909C), const Color(0xFFB0BEC5)]
                    : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDay),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        events.isEmpty
                            ? 'No events today'
                            : '${events.length} event${events.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List or empty state
          Expanded(
            child: events.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _eventCard(events[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available,
              size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          Text(
            'No events on this date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap any highlighted date to see events',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(CalendarEvent ev) {
    final color = _typeColor(ev.type);
    final icon  = _typeIcon(ev.type);

    final isSingleDay = isSameDay(ev.start, ev.end);
    final dateLabel = isSingleDay
        ? DateFormat('dd MMM yyyy').format(ev.start)
        : '${DateFormat('dd MMM').format(ev.start)} – ${DateFormat('dd MMM yyyy').format(ev.end)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + type badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ev.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ev.type,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Date range
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (ev.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    ev.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
