// Portfolio 4: MongoDB events for Greenfield Family Clinic (fictional data).
// These are separate MongoDB examples, not data extracted from PostgreSQL.
// The insert runs once. The guard below stops a second run adding duplicates.

// 1. Select the database and check the collection is empty (expected 0).
db = db.getSiblingDB("clinic_events")
db.appointment_events.countDocuments()

// 2. Insert four example events, only if the collection is empty.
if (db.appointment_events.countDocuments() === 0) {
  db.appointment_events.insertMany([
    {
      _id: "E001", event_type: "booked",
      occurred_at: ISODate("2026-11-28T09:00:00Z"),
      patient: { email: "amina@example.com", name: "Amina Bello" },
      doctor: { name: "Daniel Adams", specialty: "Cardiology" },
      appointment: { date: "2026-12-01", slot: "10:00" },
      details: { reason: "Fever and headache" }
    },
    {
      _id: "E002", event_type: "completed",
      occurred_at: ISODate("2026-12-01T10:30:00Z"),
      patient: { email: "amina@example.com", name: "Amina Bello" },
      doctor: { name: "Daniel Adams", specialty: "Cardiology" },
      appointment: { date: "2026-12-01", slot: "10:00" },
      details: {
        notes: "Fever for three days, advised rest and fluids",
        diagnoses: ["Flu", "Dehydration"],
        prescriptions: [
          { medication: "Paracetamol", dosage: "500 mg", duration_days: 5 },
          { medication: "Rehydration salts", dosage: "1 sachet", duration_days: 3 }
        ],
        follow_up_days: 7
      }
    },
    {
      _id: "E003", event_type: "booked",
      occurred_at: ISODate("2026-11-29T14:00:00Z"),
      patient: { email: "chidi@example.com", name: "Chidi Okafor" },
      doctor: { name: "Daniel Adams", specialty: "Cardiology" },
      appointment: { date: "2026-12-01", slot: "11:00" },
      details: { reason: "Blood pressure review" }
    },
    {
      _id: "E004", event_type: "completed",
      occurred_at: ISODate("2026-12-01T11:30:00Z"),
      patient: { email: "chidi@example.com", name: "Chidi Okafor" },
      doctor: { name: "Daniel Adams", specialty: "Cardiology" },
      appointment: { date: "2026-12-01", slot: "11:00" },
      details: {
        notes: "Blood pressure remains high, long-term treatment started",
        diagnoses: ["Hypertension"],
        prescriptions: [
          { medication: "Amlodipine", dosage: "5 mg", duration_days: 30 }
        ],
        follow_up_days: 30
      }
    }
  ])
}

// 3. Query 1: total number of events (expected 4).
db.appointment_events.countDocuments()

// 4. Query 2: one patient's event history in date order (expected E001 then E002).
db.appointment_events.find(
  { "patient.email": "amina@example.com" },
  { _id: 1, event_type: 1, occurred_at: 1, details: 1 }
).sort({ occurred_at: 1, _id: 1 }).toArray()

// 5. Query 3: nested-field filter, follow-up of 14 days or more (expected E004).
db.appointment_events.find({ "details.follow_up_days": { $gte: 14 } }).toArray()
