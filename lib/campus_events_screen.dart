import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampusEventsScreen extends StatelessWidget {
  CampusEventsScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  /* ---------------- CREATE ---------------- */
  Future<void> addEvent(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': titleController.text,
        'description': descController.text,
        'date': dateController.text,
        'location': locationController.text,
        'createdAt': Timestamp.now(),
      });

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to add event'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /* ---------------- READ ---------------- */
  Stream<QuerySnapshot> getEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /* ---------------- UPDATE ---------------- */
  Future<void> updateEvent(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('events').doc(docId).update({
      'title': titleController.text,
      'description': descController.text,
      'date': dateController.text,
      'location': locationController.text,
    });

    Navigator.pop(context); // close dialog

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
  }

  /* ---------------- DELETE ---------------- */
  Future<void> deleteEvent(String docId) async {
    await FirebaseFirestore.instance.collection('events').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -------- ADD EVENT FORM --------
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => addEvent(context),
              child: const Text('Add Event'),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // -------- READ EVENTS LIST --------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getEvents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['description']),
                              Text("📅 Date: ${data['date']}"),
                              Text("📍 Location: ${data['location']}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // UPDATE BUTTON (FIXED)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  titleController.text = data['title'];
                                  descController.text = data['description'];
                                  dateController.text = data['date'];
                                  locationController.text = data['location'];

                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Update Event'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: titleController,
                                            decoration: const InputDecoration(
                                                labelText: 'Event Title'),
                                          ),
                                          TextField(
                                            controller: descController,
                                            decoration: const InputDecoration(
                                                labelText: 'Description'),
                                          ),
                                          TextField(
                                            controller: dateController,
                                            decoration: const InputDecoration(
                                                labelText: 'Date'),
                                          ),
                                          TextField(
                                            controller: locationController,
                                            decoration: const InputDecoration(
                                                labelText: 'Location'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => updateEvent(
                                              context, data.id),
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // DELETE BUTTON
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteEvent(data.id),
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
