import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class CampusEventsScreen extends StatefulWidget {
  const CampusEventsScreen({super.key});

  @override
  State<CampusEventsScreen> createState() => _CampusEventsScreenState();
}

class _CampusEventsScreenState extends State<CampusEventsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  /* ---------------- CREATE ---------------- */
  Future<void> addEvent(BuildContext context) async {
    if (titleController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill in title and date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('events').add({
      'title': titleController.text,
      'description': descController.text,
      'date': dateController.text,
      'location': locationController.text,
      'eventTime': timeController.text,
      'createdAt': Timestamp.now(),
    });

    // Notify: new event added
    NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📅 New Event Added',
      body: '${titleController.text} on ${dateController.text}'
          '${locationController.text.isNotEmpty ? " @ ${locationController.text}" : ""}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Event added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    titleController.clear();
    descController.clear();
    dateController.clear();
    locationController.clear();
    timeController.clear();
    selectedDate = null;
    selectedTime = null;
  }

  /* ---------------- READ ---------------- */
  Stream<QuerySnapshot> getEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /* ---------------- UPDATE ---------------- */
  Future<void> updateEvent(
      BuildContext context, String docId) async {
    if (titleController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill in title and date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('events')
        .doc(docId)
        .update({
      'title': titleController.text,
      'description': descController.text,
      'date': dateController.text,
      'location': locationController.text,
      'eventTime': timeController.text,
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✏️ Event updated successfully'),
        backgroundColor: Colors.blue,
      ),
    );

    titleController.clear();
    descController.clear();
    dateController.clear();
    locationController.clear();
    timeController.clear();
    selectedDate = null;
    selectedTime = null;
  }

  /* ---------------- DELETE ---------------- */
  Future<void> deleteEvent(
      BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(docId)
        .delete();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Event deleted successfully'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        final h = picked.hour.toString().padLeft(2, '0');
        final m = picked.minute.toString().padLeft(2, '0');
        timeController.text = '$h:$m';
      });
    }
  }

  void _showAddEventDialog(BuildContext context) {
    titleController.clear();
    descController.clear();
    dateController.clear();
    locationController.clear();
    timeController.clear();
    selectedDate = null;
    selectedTime = null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date (dd/MM/yyyy)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Event Time (optional – for 1-hour reminder)',
                  hintText: 'e.g. 10:30 AM',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await addEvent(context);
            },
            child: const Text('Add Event'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -------- READ EVENTS LIST --------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getEvents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!.docs;

                  if (events.isEmpty) {
                    return const Center(child: Text('No events added'));
                  }

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final data = events[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            data['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(data['description'] ?? ''),
                              Text("📅 Date: ${data['date']}"),
                              Text(
                                  "📍 Location: ${data['location'] ?? 'N/A'}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // UPDATE
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () {
                                  titleController.text =
                                      data['title'];
                                  descController.text =
                                      data['description'] ?? '';
                                  dateController.text =
                                      data['date'];
                                  locationController.text =
                                      data['location'] ?? '';
                                  timeController.text =
                                      data['eventTime'] ?? '';

                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Update Event'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: titleController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Event Title'),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: descController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Description'),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: dateController,
                                              decoration: InputDecoration(
                                                labelText: 'Date',
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                      Icons.calendar_today),
                                                  onPressed: () =>
                                                      _selectDate(context),
                                                ),
                                              ),
                                              readOnly: true,
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: locationController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Location'),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: timeController,
                                              decoration: InputDecoration(
                                                labelText: 'Event Time (optional)',
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                      Icons.access_time),
                                                  onPressed: () =>
                                                      _selectTime(context),
                                                ),
                                              ),
                                              readOnly: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              updateEvent(context, data.id),
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // DELETE (CONFIRMATION ADDED)
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text('Delete Event'),
                                      content: const Text(
                                          'Are you sure you want to delete this event?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context),
                                          child:
                                              const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              deleteEvent(
                                                  context,
                                                  data.id),
                                          child:
                                              const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
