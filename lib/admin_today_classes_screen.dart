import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Day labels exactly matching the timetable image
const _kDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

const _kDayColors = {
  'MON': Colors.blue,
  'TUE': Colors.purple,
  'WED': Colors.teal,
  'THU': Colors.orange,
  'FRI': Colors.indigo,
  'SAT': Colors.pink,
};

class AdminTodayClassesScreen extends StatefulWidget {
  const AdminTodayClassesScreen({super.key});

  @override
  State<AdminTodayClassesScreen> createState() =>
      _AdminTodayClassesScreenState();
}

class _AdminTodayClassesScreenState extends State<AdminTodayClassesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedSemester = 1;

  // Today's day index (0=MON â€¦ 5=SAT, -1=SUN)
  static int get _todayTabIndex {
    final wd = DateTime.now().weekday; // Mon=1 â€¦ Sun=7
    return wd <= 6 ? wd - 1 : -1;
  }

  @override
  void initState() {
    super.initState();
    final initial = _todayTabIndex < 0 ? 0 : _todayTabIndex;
    _tabController = TabController(
        length: _kDays.length, vsync: this, initialIndex: initial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _selectedDay => _kDays[_tabController.index];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          onTap: (_) => setState(() {}),
          tabs: _kDays.map((d) {
            final isToday =
                _todayTabIndex >= 0 && _kDays[_todayTabIndex] == d;
            return Tab(
              child: Text(
                d,
                style: TextStyle(
                  fontWeight:
                      isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // â”€â”€ Semester selector â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.primary.withOpacity(0.07),
            child: Row(
              children: [
                const Icon(Icons.school_outlined, size: 18),
                const SizedBox(width: 8),
                const Text('Semester:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedSemester,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(
                      6,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Semester ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _selectedSemester = v!),
                  ),
                ),
              ],
            ),
          ),

          // â”€â”€ Class list for selected day + semester â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _kDays.map((day) {
                return _DayClassList(
                  day: day,
                  semester: _selectedSemester,
                  onEdit: (doc, data) =>
                      _showAddEditDialog(doc: doc, data: data),
                  onDelete: (id) => _confirmDelete(id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: Text('Add to $_selectedDay'),
      ),
    );
  }

  // â”€â”€ Add / Edit dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _showAddEditDialog({
    DocumentSnapshot? doc,
    Map<String, dynamic>? data,
  }) async {
    final isEdit = doc != null;
    final subjectCtrl =
        TextEditingController(text: isEdit ? data!['subject'] : '');
    final teacherCtrl =
        TextEditingController(text: isEdit ? data!['teacher'] : '');
    final roomCtrl =
        TextEditingController(text: isEdit ? data!['room'] : '');
    String selectedDay =
        isEdit ? (data!['day'] ?? _selectedDay) : _selectedDay;
    String timeStart =
        isEdit ? (data!['timeStart'] ?? '09:10 AM') : '09:10 AM';
    String timeEnd =
        isEdit ? (data!['timeEnd'] ?? '10:10 AM') : '10:10 AM';
    int sortOrder = isEdit ? (data!['sortOrder'] ?? 0) : 0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Class' : 'Add New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day picker (only shown in add mode; in edit mode it's fixed)
                if (!isEdit)
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _kDays
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setDlg(() => selectedDay = v!),
                  ),
                if (!isEdit) const SizedBox(height: 12),

                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    prefixIcon: Icon(Icons.book_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teacherCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teacher Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Room / Location',
                    prefixIcon: Icon(Icons.room_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Time row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: _parseTime(timeStart),
                          );
                          if (t != null) {
                            setDlg(() => timeStart = t.format(ctx));
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          child: Text(timeStart,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: _parseTime(timeEnd),
                          );
                          if (t != null) {
                            setDlg(() => timeEnd = t.format(ctx));
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule_outlined),
                          ),
                          child: Text(timeEnd,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  initialValue: sortOrder.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Display Order (1, 2, 3 â€¦)',
                    prefixIcon: Icon(Icons.sort),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => sortOrder = int.tryParse(v) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (subjectCtrl.text.trim().isEmpty) return;
                final classData = <String, dynamic>{
                  'subject': subjectCtrl.text.trim(),
                  'teacher': teacherCtrl.text.trim(),
                  'room': roomCtrl.text.trim(),
                  'timeStart': timeStart,
                  'timeEnd': timeEnd,
                  'semester': _selectedSemester,
                  'day': isEdit ? (data!['day'] ?? _selectedDay) : selectedDay,
                  'sortOrder': sortOrder,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                final col = FirebaseFirestore.instance
                    .collection('today_classes');
                if (isEdit) {
                  await col.doc(doc.id).update(classData);
                } else {
                  classData['createdAt'] = FieldValue.serverTimestamp();
                  await col.add(classData);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content:
            const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance
          .collection('today_classes')
          .doc(docId)
          .delete();
    }
  }

  TimeOfDay _parseTime(String raw) {
    try {
      final fmt = DateFormat.jm();
      final dt = fmt.parse(raw);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 10);
    }
  }
}

//  Per-day timetable TABLE 
class _DayClassList extends StatelessWidget {
  final String day;
  final int semester;
  final void Function(DocumentSnapshot, Map<String, dynamic>) onEdit;
  final void Function(String) onDelete;

  const _DayClassList({
    required this.day,
    required this.semester,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isToday {
    final wd = DateTime.now().weekday;
    return wd <= 6 && _kDays[wd - 1] == day;
  }

  @override
  Widget build(BuildContext context) {
    final dayColor = _kDayColors[day] ?? Colors.blue;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('today_classes')
          .where('semester', isEqualTo: semester)
          .where('day', isEqualTo: day)
          .orderBy('sortOrder')
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
                Icon(Icons.event_note_outlined,
                    size: 56, color: Colors.grey[400]),
                const SizedBox(height: 14),
                Text(
                  'No classes for $day  (Semester $semester)',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text('Tap + to add a class',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODAY banner
            if (_isToday)
              Container(
                color: dayColor.withOpacity(0.12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.today, color: dayColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'TODAY — ${DateFormat('EEEE, d MMM').format(DateTime.now())}',
                      style: TextStyle(
                        color: dayColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // Timetable table
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 24,
                    ),
                    child: Table(
                      border: TableBorder.all(
                        color: dayColor.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FixedColumnWidth(36),
                        1: FixedColumnWidth(110),
                        2: FlexColumnWidth(2.5),
                        3: FlexColumnWidth(1.2),
                        4: FixedColumnWidth(72),
                        5: FixedColumnWidth(80),
                      },
                      children: [
                        // Header
                        TableRow(
                          decoration: BoxDecoration(
                            color: dayColor.withOpacity(0.15),
                          ),
                          children: [
                            _hCell('#'),
                            _hCell('Time'),
                            _hCell('Subject'),
                            _hCell('Teacher'),
                            _hCell('Room'),
                            _hCell('Actions'),
                          ],
                        ),
                        // Data rows
                        for (int i = 0; i < docs.length; i++)
                          _buildRow(
                            context,
                            i,
                            docs[i],
                            docs[i].data() as Map<String, dynamic>,
                            dayColor,
                            i.isOdd,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hCell(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );

  TableRow _buildRow(
    BuildContext context,
    int i,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    Color dayColor,
    bool shaded,
  ) {
    final bg = shaded ? Colors.grey.shade50 : Colors.white;
    final time = '${data['timeStart'] ?? ''}\n–\n${data['timeEnd'] ?? ''}';

    return TableRow(
      decoration: BoxDecoration(color: bg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text('${i + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dayColor,
                  fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(time,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, height: 1.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(data['subject'] ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Text(data['teacher'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(data['room'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 30, minHeight: 30),
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.blue, size: 18),
              onPressed: () => onEdit(doc, data),
              tooltip: 'Edit',
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 30, minHeight: 30),
              icon: const Icon(Icons.delete_outlined,
                  color: Colors.red, size: 18),
              onPressed: () => onDelete(doc.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ],
    );
  }
}
