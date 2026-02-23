# Emergency Info Module - Database Setup Guide

## Firestore Database Structure

### Collection: `emergency_contacts`

Create a Firestore collection named **`emergency_contacts`** with the following structure:

---

## Document Fields

Each document in the `emergency_contacts` collection should have:

| Field Name | Type | Example | Description |
|-----------|------|---------|-------------|
| `name` | String | "Campus Security" | Contact name (displayed first) |
| `phone` | Number | 9876543210 | Phone number as number (shown when expanded) |
| `description` | String | "Campus Security & Safety" | Brief description |
| `priority` | Number | 1 | Priority order (lower = appears first) |

---

## Sample Data to Add

Add these documents to Firebase Firestore in the **`emergency_contacts`** collection:

### Document 1:
```
name: "Campus Security"
phone: "+91-9876543210"
description: "Campus Security & Safety"
priority: 1
```

### Document 2:
```
name: "Medical Emergency"
phone: "+91-9999999999"
description: "Campus Health Services"
priority: 2
```

### Document 3:
```
name: "Fire Department"
phone: "101"
description: "Emergency Fire Services"
priority: 3
```

### Document 4:
```
name: "Police"
phone: "100"
description: "Emergency Police Services"
priority: 4
```

### Document 5:
```
name: "Ambulance"
phone: "102"
description: "Emergency Medical Services"
priority: 5
```

### Document 6:
```
name: "Mental Health Crisis"
phone: "+91-8888888888"
description: "Mental Health Support Line"
priority: 6
```

### Document 7:
```
name: "Campus Counseling"
phone: "+91-7777777777"
description: "Student Counseling Services"
priority: 7
```

### Document 8:
```
name: "Poison Control"
phone: "+91-6666666666"
description: "Poison Emergency Control"
priority: 8
```

---

## How to Add Data to Firestore (Firebase Console)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **campus_assistant**
3. Click **Firestore Database** in the left sidebar
4. Click **Create Collection**
5. Enter collection name: **emergency_contacts**
6. Click **Add Document**
7. For each document:
   - Set the **Document ID** (auto-generated is fine)
   - Add fields manually or paste JSON:

```json
{
  "name": "Campus Security",
  "phone": "+91-9876543210",
  "description": "Campus Security & Safety",
  "priority": 1
}
```

---

## How It Works in the App

1. **Shows names only** - Users see contact names in a list
2. **Click to expand** - Tapping a contact reveals the phone number
3. **Copy number** - Users can tap the copy button to copy the number
4. **Auto-fetch** - App fetches latest contacts from Firestore in real-time
5. **Ordered by priority** - Contacts are ordered by priority number (ascending)

---

## Adding College-Specific Numbers

Replace the sample phone numbers with your college's actual emergency numbers:

- Campus Security: Your college security number
- Medical: Your college hospital/health center number
- Counseling: Your college counseling center number
- Dean/Warden: Your college administration numbers
- Other Services: Any other relevant numbers

---

## Mobile Firestore Rules (Security)

Make sure your Firestore rules allow reading emergency_contacts:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read emergency_contacts
    match /emergency_contacts/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Only admin can write
    }
  }
}
```

---

## Changes Made in Code

✅ **Removed:**
- Hardcoded emergency numbers
- Direct phone calling feature

✅ **Added:**
- Real-time Firestore data fetching
- Expandable contact tiles
- Copy to clipboard functionality
- Priority-based ordering
- Professional UI with animations

---

## Testing the Feature

1. Add documents to Firestore as shown above
2. Run the app: `flutter run`
3. Navigate to Dashboard → Emergency Info
4. Tap on any contact name to see the phone number
5. Tap the copy button to copy the number to clipboard
