import 'package:cloud_firestore/cloud_firestore.dart';

class TestDataHelper {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleHolidays() async {
    final holidays = [
      {
        'eventName': 'Republic Day',
        'eventType': 'Holiday',
        'startDate': Timestamp.fromDate(DateTime(2026, 1, 26)),
        'endDate': Timestamp.fromDate(DateTime(2026, 1, 26)),
        'description': 'National holiday - Republic Day of India',
        'semester': 'Spring',
      },
      {
        'eventName': 'Holi Festival',
        'eventType': 'Festival',
        'startDate': Timestamp.fromDate(DateTime(2026, 3, 25)),
        'endDate': Timestamp.fromDate(DateTime(2026, 3, 25)),
        'description': 'Festival of Colors',
        'semester': 'Spring',
      },
      {
        'eventName': 'Diwali',
        'eventType': 'Festival',
        'startDate': Timestamp.fromDate(DateTime(2026, 10, 29)),
        'endDate': Timestamp.fromDate(DateTime(2026, 10, 29)),
        'description': 'Festival of Lights',
        'semester': 'Fall',
      },
      {
        'eventName': 'Spring Break',
        'eventType': 'Holiday',
        'startDate': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'endDate': Timestamp.fromDate(DateTime(2026, 4, 7)),
        'description': 'One week break',
        'semester': 'Spring',
      },
      {
        'eventName': 'Semester Exam',
        'eventType': 'Exam',
        'startDate': Timestamp.fromDate(DateTime(2026, 5, 10)),
        'endDate': Timestamp.fromDate(DateTime(2026, 5, 25)),
        'description': 'Final semester examinations',
        'semester': 'Spring',
      },
    ];

    print('Adding sample holidays...');
    for (var holiday in holidays) {
      try {
        await _firestore.collection('academic_events').add(holiday);
        print('Added: ${holiday['eventName']}');
      } catch (e) {
        print('Error adding holiday: $e');
      }
    }
    print('Sample holidays added!');
  }

  static Future<void> clearAllEvents() async {
    print('Clearing all events...');
    
    // Clear academic events
    final academicDocs = await _firestore.collection('academic_events').get();
    for (var doc in academicDocs.docs) {
      await doc.reference.delete();
    }
    print('Cleared academic events');

    // Clear campus events
    final campusDocs = await _firestore.collection('events').get();
    for (var doc in campusDocs.docs) {
      await doc.reference.delete();
    }
    print('Cleared campus events');
  }
}
