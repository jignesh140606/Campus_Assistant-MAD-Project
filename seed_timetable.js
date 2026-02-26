// Timetable Seeder — 6-IT-1, B.Tech (IT), Room 607
// Run: node seed_timetable.js

const admin = require('firebase-admin');
const serviceAccount = require('./campus-assistant-3f1a7-firebase-adminsdk-fbsvc-a1daf6540c.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─── Timetable Data ───────────────────────────────────────────────────────────
// Time slots: 09:10-10:10 | 10:10-11:10 | LUNCH 11:10-12:10
//             12:10-01:10 | 01:10-02:10 | BREAK 02:10-02:20
//             02:20-03:20 | 03:20-04:20
// ─────────────────────────────────────────────────────────────────────────────

const timetable = [

  // ── MONDAY ──────────────────────────────────────────────────────────────────
  { day: 'MON', sortOrder: 1, subject: 'LP (Language with Programming)',    teacher: 'CZ',           room: '607',        timeStart: '09:10', timeEnd: '10:10' },
  { day: 'MON', sortOrder: 2, subject: 'CC (Cloud Computing)',              teacher: 'SBS',          room: '607',        timeStart: '10:10', timeEnd: '11:10' },
  { day: 'MON', sortOrder: 3, subject: 'CC (Cloud Computing)',              teacher: 'RVP',          room: '607',        timeStart: '12:10', timeEnd: '01:10' },
  { day: 'MON', sortOrder: 4, subject: 'CRNS (Computer Networks & Sec.)',   teacher: 'MMA',          room: '607',        timeStart: '01:10', timeEnd: '02:10' },
  { day: 'MON', sortOrder: 5, subject: 'IOT / BT / DL (Lab)',               teacher: 'BHP/MMA/PPP/HNY/NAS/MF', room: 'LAB', timeStart: '02:20', timeEnd: '04:20' },

  // ── TUESDAY ─────────────────────────────────────────────────────────────────
  { day: 'TUE', sortOrder: 1, subject: 'A1-LP | B1-CC | C1-CRNS | D1-LP (Lab)', teacher: 'DB/RVP/MMA/DB', room: '613A/614A/628A', timeStart: '09:10', timeEnd: '11:10' },
  { day: 'TUE', sortOrder: 2, subject: 'IOT / BT / DL (Lab)',               teacher: 'AKP/MMA/PPP',  room: '609/610/607', timeStart: '12:10', timeEnd: '02:10' },
  { day: 'TUE', sortOrder: 3, subject: 'CRNS (Computer Networks & Sec.)',   teacher: 'PNP',          room: '607',        timeStart: '02:20', timeEnd: '03:20' },
  { day: 'TUE', sortOrder: 4, subject: 'CRNS (Computer Networks & Sec.)',   teacher: 'PNP',          room: '607',        timeStart: '03:20', timeEnd: '04:20' },

  // ── WEDNESDAY ───────────────────────────────────────────────────────────────
  { day: 'WED', sortOrder: 1, subject: 'A1-CRNS | B1-MAD | C1-CC | D1-MAD (Lab)', teacher: 'PNP/---/RVP/---', room: '615A/628A/615A/628A', timeStart: '09:10', timeEnd: '11:10' },
  { day: 'WED', sortOrder: 2, subject: 'LP (Language with Programming)',    teacher: 'CZ',           room: '607',        timeStart: '12:10', timeEnd: '01:10' },
  { day: 'WED', sortOrder: 3, subject: 'CRNS (Computer Networks & Sec.)',   teacher: 'MMA',          room: '607',        timeStart: '01:10', timeEnd: '02:10' },
  { day: 'WED', sortOrder: 4, subject: 'LP (Language with Programming)',    teacher: 'PMP',          room: '607',        timeStart: '02:20', timeEnd: '03:20' },
  { day: 'WED', sortOrder: 5, subject: 'CC (Cloud Computing)',              teacher: 'RVP',          room: '607',        timeStart: '03:20', timeEnd: '04:20' },

  // ── THURSDAY ────────────────────────────────────────────────────────────────
  { day: 'THU', sortOrder: 1, subject: 'A1-MAD | B1-CRNS | C1-LP | D1-CC (Lab)',  teacher: 'SMP/PNP/RSK/RVP', room: '614A/628A/614B/613A', timeStart: '09:10', timeEnd: '11:10' },
  { day: 'THU', sortOrder: 2, subject: 'Aptitude Session',                  teacher: '---',          room: '607',        timeStart: '12:10', timeEnd: '01:10' },
  { day: 'THU', sortOrder: 3, subject: 'CPD (Career & Personal Dev.)',      teacher: 'NP',           room: '607',        timeStart: '02:20', timeEnd: '04:20' },

  // ── FRIDAY ──────────────────────────────────────────────────────────────────
  { day: 'FRI', sortOrder: 1, subject: 'A1-CC | B1-LP | C1-CRNS | D1-CC (Lab)',   teacher: 'SBS/CZ/MMA/SBS', room: '613A/628A/615A/613A', timeStart: '09:10', timeEnd: '11:10' },
  { day: 'FRI', sortOrder: 2, subject: 'RM / CP (Lab)',                     teacher: 'PMP/NAS/SBS/SMP/BHP', room: 'LAB', timeStart: '12:10', timeEnd: '02:10' },
  { day: 'FRI', sortOrder: 3, subject: 'IOT / BT / DL (Lab)',               teacher: 'BHP/MMA/PPP',  room: '628A/614A/607', timeStart: '02:20', timeEnd: '04:20' },

  // ── SATURDAY ────────────────────────────────────────────────────────────────
  { day: 'SAT', sortOrder: 1, subject: 'SGP (Software Group Project)',       teacher: 'DB/HNY/MMA/MRP', room: '614B/628A/615A/614A', timeStart: '09:10', timeEnd: '11:10' },
  { day: 'SAT', sortOrder: 2, subject: 'MAD (Mobile App Dev.)',              teacher: 'JHV',          room: '607',        timeStart: '12:10', timeEnd: '01:10' },
  { day: 'SAT', sortOrder: 3, subject: 'MAD (Mobile App Dev.)',              teacher: 'JHV',          room: '607',        timeStart: '01:10', timeEnd: '02:10' },
  { day: 'SAT', sortOrder: 4, subject: 'MAD (Mobile App Dev.)',              teacher: 'SMP',          room: '608',        timeStart: '02:20', timeEnd: '03:20' },
  { day: 'SAT', sortOrder: 5, subject: 'MAD (Mobile App Dev.)',              teacher: 'SMP',          room: '608',        timeStart: '03:20', timeEnd: '04:20' },
];

// ─── Seed Function ────────────────────────────────────────────────────────────

async function seedTimetable() {
  console.log('Starting timetable seed for Semester 6...\n');

  // Delete existing sem 6 timetable docs first (clean slate)
  const existing = await db.collection('today_classes')
    .where('semester', '==', 6)
    .get();

  if (!existing.empty) {
    const batch = db.batch();
    existing.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    console.log(`Deleted ${existing.size} existing Semester 6 entries.\n`);
  }

  // Insert new timetable in batches of 500
  const chunks = [];
  for (let i = 0; i < timetable.length; i += 500) {
    chunks.push(timetable.slice(i, i + 500));
  }

  let total = 0;
  for (const chunk of chunks) {
    const batch = db.batch();
    for (const entry of chunk) {
      const ref = db.collection('today_classes').doc();
      batch.set(ref, {
        ...entry,
        semester: 6,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    total += chunk.length;
    console.log(`  Inserted ${total} / ${timetable.length} entries...`);
  }

  console.log('\n✅ Timetable seed complete!');
  console.log(`   Total entries: ${timetable.length}`);
  console.log('   Days: MON / TUE / WED / THU / FRI / SAT');
  console.log('   Semester: 6\n');
  console.log('Student view example:');
  console.log('  Today = Thursday → shows THU entries (Aptitude + Lab + CPD)');

  process.exit(0);
}

seedTimetable().catch(err => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
