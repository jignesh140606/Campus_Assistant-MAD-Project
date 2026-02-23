# ⚡ SHORTEST TRICK - Add All 26 Events in 30 Seconds!

## Step 1: Get Your API Key (1 minute)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **campus_assistant** project
3. Click **Settings** ⚙️ → **Project Settings**
4. Copy **Project ID** (under General tab)
5. Go to **Service Accounts** tab
6. Look for **Web API Key** or go to **APIs & Services** in Google Cloud
7. Copy your **API Key**

---

## Step 2: Update the Script (30 seconds)

Open `add_events.py` and update these 2 lines at the top:

```python
PROJECT_ID = "YOUR_PROJECT_ID_HERE"  # Paste project ID
API_KEY = "YOUR_API_KEY_HERE"  # Paste API key
```

---

## Step 3: Run (10 seconds)

In PowerShell, run:

```powershell
python add_events.py
```

---

## ✅ Done!

You'll see:
```
🚀 Adding 26 academic events...
✅ 3% - Semester 1 Starts
✅ 7% - Independence Day
...
🎉 Successfully added 26/26 events!
```

---

## Test in App

```bash
flutter run
```

Go to Dashboard → Academic Calendar → See all events! 🎉

---

## Finding Your API Key

**Option 1: Firebase Console (Easiest)**
1. Firebase Console → Settings → Project Settings
2. Under "Your apps" → Web app
3. Look for `firebaseConfig.apiKey`

**Option 2: Google Cloud Console**
1. Google Cloud Console → APIs & Services → Credentials
2. Look for API key labeled "Browser key"

---

**That's it! Just 3 steps, 2 minutes total!** 🚀
