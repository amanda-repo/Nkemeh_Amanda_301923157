# Portfolio 4 NoSQL and Advanced Data Models

## Document model

The `clinic_events` database holds one collection, `appointment_events`. Each document records one event in an appointment's life: either a booking or a completed visit.

Every document has the same main fields: `_id`, `event_type`, `occurred_at`, `patient`, `doctor`, `appointment` and `details`. The patient (email and name), the doctor (name and specialty) and the appointment (date and slot) are small documents embedded inside the event. Only `details` changes with the event type. A booking stores a reason. A completed visit stores notes, diagnoses, prescriptions and a follow-up period.

Example completed-visit document:

```javascript
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
}
```

## Implementation and results

MongoDB runs locally in the Codespace (see the setup notes), and I used mongosh to enter and query the data. I inserted four fictional events: a booking and a completed visit for Amina Bello, and a booking and a completed visit for Chidi Okafor. The collection was empty before the insert.

- **Count:** the collection holds 4 documents.
- **Patient history:** searching for Amina Bello's email returns E001 (booked) and then E002 (completed), sorted by date.
- **Nested search:** searching `details.follow_up_days` for 14 or more returns only E004, Chidi Okafor's completed hypertension visit. The booking events have no follow-up field, so they do not match.

These events are separate MongoDB examples. They reuse the same fictional patients and doctor as the PostgreSQL data, but they were typed in separately, and PostgreSQL was not changed.

## Why MongoDB fits

A booking and a completed visit share some fields but carry different details. A booking needs only a reason. A visit can hold notes, several diagnoses and several prescriptions. In PostgreSQL that detail would need several tables and joins. In MongoDB, one document keeps the whole event together, so a patient's history is read in one query, and each event can have its own fields.

There are limits. The patient and doctor names copied into each event are snapshots, so they do not update if the original records change. MongoDB does not enforce foreign keys here, and this exercise adds no schema validator, so nothing stops a document with a missing field. The four events are only a small sample, not a full audit history. PostgreSQL still handles the rules that matter most, such as unique appointment slots, foreign keys and transactions, and the two databases are not synchronised.

## Files

- [MongoDB.js](Nkemeh_Amanda_301923157_P4_MongoDB.js)
- [Setup.md](Nkemeh_Amanda_301923157_P4_Setup.md)
- [Screenshots](screenshots/)

## References

- [MongoDB insertMany](https://www.mongodb.com/docs/manual/reference/method/db.collection.insertMany/)
- [Query embedded documents](https://www.mongodb.com/docs/manual/tutorial/query-embedded-documents/)