# Adding 4 Emergency Contacts to Firestore - Step by Step

## Prerequisites
- Go to: https://console.firebase.google.com
- Select your **campus_assistant** project
- Click **Firestore Database** in left sidebar
- You should see your **emergency_contacts** collection

---

## Adding Document 5 (Ambulance)

1. Click on the **emergency_contacts** collection
2. Click **"+ Add document"** button
3. In the **Document ID** field - let Firebase auto-generate (just leave blank and click outside)
4. Click **"+ Add field"** and add these fields:

   | Field Name | Type | Value |
   |-----------|------|-------|
   | name | String | Ambulance |
   | phone | Number | 102 |
   | description | String | Emergency Medical Services |
   | priority | Number | 5 |

5. Click **"Save"**

---

## Adding Document 6 (Mental Health Crisis)

1. Click **"+ Add document"** button again
2. Click **"+ Add field"** and add:

   | Field Name | Type | Value |
   |-----------|------|-------|
   | name | String | Mental Health Crisis |
   | phone | Number | 8888888888 |
   | description | String | Mental Health Support Line |
   | priority | Number | 6 |

3. Click **"Save"**

---

## Adding Document 7 (Campus Counseling)

1. Click **"+ Add document"** button again
2. Click **"+ Add field"** and add:

   | Field Name | Type | Value |
   |-----------|------|-------|
   | name | String | Campus Counseling |
   | phone | Number | 7777777777 |
   | description | String | Student Counseling Services |
   | priority | Number | 7 |

3. Click **"Save"**

---

## Adding Document 8 (Poison Control)

1. Click **"+ Add document"** button again
2. Click **"+ Add field"** and add:

   | Field Name | Type | Value |
   |-----------|------|-------|
   | name | String | Poison Control |
   | phone | Number | 6666666666 |
   | description | String | Poison Emergency Control |
   | priority | Number | 8 |

3. Click **"Save"**

---

## Important Notes When Adding Fields:

### For String Fields (text):
- Click dropdown and select **"String"**
- Type the value
- Example: "Ambulance", "Emergency Medical Services"

### For Number Fields:
- Click dropdown and select **"Number"**
- Type ONLY the digits (no + or - symbols)
- For phone: 102, 9876543210, 8888888888
- For priority: 5, 6, 7, 8

---

## Verify Data Was Added

After adding all 4 documents:
1. You should see **8 total documents** in the emergency_contacts collection
2. Open your app and navigate to Dashboard → Emergency Info
3. You should see all 8 contacts listed
4. Tap on any contact name to reveal the phone number

---

## If Still Not Showing

If documents still don't appear:

1. **Check field names** - Must be exactly: `name`, `phone`, `description`, `priority`
2. **Check data types** - `name` and `description` must be String; `phone` and `priority` must be Number
3. **Refresh the app** - Stop and restart: `flutter run`
4. **Check Firestore Rules** - Make sure rules allow read access for authenticated users

