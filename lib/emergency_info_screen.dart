import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EmergencyInfoScreen extends StatefulWidget {
  const EmergencyInfoScreen({super.key});

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<int> expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Information'),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('emergency_contacts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Firestore Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Make sure your Firestore documents have:\n'
                    '- name (String)\n'
                    '- phone (Number)\n'
                    '- description (String)\n'
                    '- priority (Number)',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No emergency contacts available'),
            );
          }

          // Sort documents by priority
          final documents = snapshot.data!.docs;
          try {
            documents.sort((a, b) {
              try {
                final dataA = a.data() as Map<String, dynamic>?;
                final dataB = b.data() as Map<String, dynamic>?;
                
                final priorityA = (dataA?['priority'] as num?)?.toInt() ?? 999;
                final priorityB = (dataB?['priority'] as num?)?.toInt() ?? 999;
                
                return priorityA.compareTo(priorityB);
              } catch (e) {
                return 0;
              }
            });
          } catch (e) {
            print('Error sorting contacts: $e');
          }
          
          final contacts = documents;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Header Info Card
              Card(
                color: Colors.red.shade50,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'In Case of Emergency',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap on any contact to reveal the phone number. Save important numbers in your contacts.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Contacts List
              Text(
                'College Emergency Contacts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              ...List.generate(contacts.length, (index) {
                try {
                  final doc = contacts[index];
                  final contact = doc.data() as Map<String, dynamic>?;
                  
                  if (contact == null) return const SizedBox.shrink();
                  
                  final isExpanded = expandedIndices.contains(index);
                  
                  // Safely get all fields with fallbacks
                  final name = contact['name'] ?? 'Unknown Contact';
                  final phone = contact['phone'] ?? 'N/A';
                  final description = contact['description'] ?? '';
                  
                  // Convert phone to string
                  final phoneNumber = phone.toString();

                  return EmergencyContactTile(
                    name: name.toString(),
                    number: phoneNumber,
                    description: description.toString(),
                    isExpanded: isExpanded,
                    onTap: () {
                      setState(() {
                        if (expandedIndices.contains(index)) {
                          expandedIndices.remove(index);
                        } else {
                          expandedIndices.add(index);
                        }
                      });
                    },
                  );
                } catch (e) {
                  print('Error processing contact $index: $e');
                  return const SizedBox.shrink();
                }
              }).toList(),

              const SizedBox(height: 24),

              // Additional Information
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Always remain calm in emergencies'),
                      _buildTip('Always call 911 for life-threatening situations'),
                      _buildTip('Provide clear location information'),
                      _buildTip('Follow instructions from emergency personnel'),
                      _buildTip('Save emergency numbers in your phone'),
                      _buildTip('Know evacuation routes from your location'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12, top: 4),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 18,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyContactTile extends StatelessWidget {
  final String name;
  final String number;
  final String description;
  final bool isExpanded;
  final VoidCallback onTap;

  const EmergencyContactTile({
    required this.name,
    required this.number,
    required this.description,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.phone,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            number,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      FloatingActionButton.small(
                        onPressed: () => _copyToClipboard(context),
                        backgroundColor: Colors.blue.shade600,
                        child: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$number copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
