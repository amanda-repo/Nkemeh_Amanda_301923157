# Greenfield Family Clinic Normalisation

Normalisation separates information into related tables to reduce repeated details and avoid inconsistent updates. The same three appointments are used below. Only the fields needed to explain each change are shown; the fields left out are listed at the end.

Dates are in year-month-day order. Names and emails are fictional. In the examples, each person has one name column for readability; the final design splits it into first_name and last_name.

## Starting patient list

| patient_id | patient_name | patient_email | Appointments |
| --- | --- | --- | --- |
| 1 | Amina Bello | amina@example.com | Dr Daniel Adams (doctor 1, Cardiology), 2026-12-01 10:00, Completed; diagnoses: Flu, Dehydration; prescriptions: Paracetamol 500 mg for 5 days, Rehydration salts 1 sachet for 3 days. Dr Grace Adeola (doctor 2, Dermatology), 2026-12-02 09:00, Completed; diagnoses: Eczema; prescriptions: Hydrocortisone cream, thin layer, for 7 days. |
| 2 | Chidi Okafor | chidi@example.com | Dr Daniel Adams (doctor 1, Cardiology), 2026-12-01 11:00, Completed; diagnoses: Hypertension; prescriptions: Amlodipine 5 mg for 30 days. |

The first row holds two appointments, and each appointment holds its own lists of diagnoses and prescriptions, all in one cell. Finding one diagnosis or changing one prescription is awkward.

## 1NF: One value per cell

**Term:** 1NF (First Normal Form) means every cell holds one value, with no repeated lists.

**What moved:** each appointment gets its own row. The diagnosis list and the prescription list each get their own table, with one row per diagnosis and one row per prescription. They are separate because putting both lists in one table would pair every diagnosis with every prescription, which creates rows that mean nothing.

### Appointment list

For this example, the key is **(doctor_id, appointment_date, slot_time)**. Together these three values identify one appointment, assuming a doctor never has two appointments in the same slot. This matches Rule 4, and the examples show only active appointments. doctor_id alone is not enough, because Dr Adams appears twice.

| doctor_id | appointment_date | slot_time | patient_id | patient_name | patient_email | doctor_name | specialty | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2026-12-01 | 10:00 | 1 | Amina Bello | amina@example.com | Daniel Adams | Cardiology | Completed |
| 1 | 2026-12-01 | 11:00 | 2 | Chidi Okafor | chidi@example.com | Daniel Adams | Cardiology | Completed |
| 2 | 2026-12-02 | 09:00 | 1 | Amina Bello | amina@example.com | Grace Adeola | Dermatology | Completed |

### Diagnosis list

Key: **(doctor_id, appointment_date, slot_time, description)**. The first three values point to the appointment.

| doctor_id | appointment_date | slot_time | description |
| --- | --- | --- | --- |
| 1 | 2026-12-01 | 10:00 | Flu |
| 1 | 2026-12-01 | 10:00 | Dehydration |
| 1 | 2026-12-01 | 11:00 | Hypertension |
| 2 | 2026-12-02 | 09:00 | Eczema |

### Prescription list

Key: **(doctor_id, appointment_date, slot_time, medication)**. The first three values point to the appointment.

| doctor_id | appointment_date | slot_time | medication | dosage | duration_days |
| --- | --- | --- | --- | --- | --- |
| 1 | 2026-12-01 | 10:00 | Paracetamol | 500 mg | 5 |
| 1 | 2026-12-01 | 10:00 | Rehydration salts | 1 sachet | 3 |
| 1 | 2026-12-01 | 11:00 | Amlodipine | 5 mg | 30 |
| 2 | 2026-12-02 | 09:00 | Hydrocortisone cream | thin layer | 7 |

**Problem removed:** no cell holds a list. But Amina's email and Dr Adams' specialty are still repeated, so a correction means editing several rows.

## 2NF: Details depend on the whole key

**Terms:** 2NF (Second Normal Form) includes 1NF. A **combined key** is a key made of more than one field. A **partial dependency** is a non-key field that depends on only part of a combined key.

**Appointment list:** here, **doctor_id alone determines doctor_name and specialty**. Those details describe the doctor, whatever the date or time of the appointment. That is a partial dependency, so they move into a separate table.

### doctor

Key: **doctor_id**.

| doctor_id | doctor_name | specialty |
| --- | --- | --- |
| 1 | Daniel Adams | Cardiology |
| 2 | Grace Adeola | Dermatology |

### Appointment details

Key: **(doctor_id, appointment_date, slot_time)**. doctor_id links to doctor.

| doctor_id | appointment_date | slot_time | patient_id | patient_name | patient_email | status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 2026-12-01 | 10:00 | 1 | Amina Bello | amina@example.com | Completed |
| 1 | 2026-12-01 | 11:00 | 2 | Chidi Okafor | chidi@example.com | Completed |
| 2 | 2026-12-02 | 09:00 | 1 | Amina Bello | amina@example.com | Completed |

**Diagnosis list:** it has no partial dependency. Its only non-key information is the description, which is part of the key, so it is already in 2NF.

**Prescription list:** dosage and duration_days describe that medication in that appointment. They depend on the whole key, so it is already in 2NF. Nothing is invented here: only the appointment list had a field depending on part of its key.

**Problem removed:** Dr Adams' specialty is stored once in doctor. Changing it updates one row. Amina's email is still repeated.

## 3NF: Keep details with the thing they describe

**Term:** 3NF (Third Normal Form) includes 2NF. A non-key field must not depend on another non-key field.

**Appointment details:** one link remains. **patient_id determines patient_name and patient_email.** These describe the patient, not the appointment, so they move into a separate table.

### patient

Key: **patient_id**.

| patient_id | patient_name | patient_email |
| --- | --- | --- |
| 1 | Amina Bello | amina@example.com |
| 2 | Chidi Okafor | chidi@example.com |

### appointment (before adding an ID)

Key: **(doctor_id, appointment_date, slot_time)**. patient_id and doctor_id are foreign keys. A **foreign key** is a field that holds another table's key, which links the rows.

| doctor_id | appointment_date | slot_time | patient_id | status |
| --- | --- | --- | --- | --- |
| 1 | 2026-12-01 | 10:00 | 1 | Completed |
| 1 | 2026-12-01 | 11:00 | 2 | Completed |
| 2 | 2026-12-02 | 09:00 | 1 | Completed |

**Problem removed:** Amina's email is stored once in patient. Changing it updates one row, and the IDs still link her to every appointment.

## Final design: replacing the combined key with generated IDs

The final design gives each appointment its own **appointment_id** instead of identifying it by three combined fields. Diagnosis and prescription rows then point to the appointment with one value, and each gets its own ID. Adding an ID is a design choice for simpler links, not what makes a table 3NF. A table with an ID can still have repeated or dependent details; the splits above are what achieve 3NF.

### patient
Key: **patient_id**.

| patient_id | first_name | last_name | email |
| --- | --- | --- | --- |
| 1 | Amina | Bello | amina@example.com |
| 2 | Chidi | Okafor | chidi@example.com |

### doctor
Key: **doctor_id**.

| doctor_id | first_name | last_name | specialty |
| --- | --- | --- | --- |
| 1 | Daniel | Adams | Cardiology |
| 2 | Grace | Adeola | Dermatology |

### appointment
Key: **appointment_id**. patient_id and doctor_id are foreign keys.

| appointment_id | patient_id | doctor_id | appointment_date | slot_time | status |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 1 | 2026-12-01 | 10:00 | Completed |
| 2 | 2 | 1 | 2026-12-01 | 11:00 | Completed |
| 3 | 1 | 2 | 2026-12-02 | 09:00 | Completed |

### diagnosis
Key: **diagnosis_id**. appointment_id is a foreign key.

| diagnosis_id | appointment_id | description |
| --- | --- | --- |
| 1 | 1 | Flu |
| 2 | 1 | Dehydration |
| 3 | 2 | Hypertension |
| 4 | 3 | Eczema |

### prescription
Key: **prescription_id**. appointment_id is a foreign key.

| prescription_id | appointment_id | medication | dosage | duration_days |
| --- | --- | --- | --- | --- |
| 1 | 1 | Paracetamol | 500 mg | 5 |
| 2 | 1 | Rehydration salts | 1 sachet | 3 |
| 3 | 2 | Amlodipine | 5 mg | 30 |
| 4 | 3 | Hydrocortisone cream | thin layer | 7 |

These are the five tables in the ER diagram. The IDs keep them linked, so a patient's appointments, diagnoses and prescriptions can be brought together when needed.

## Fields left out of the examples

- **patient:** date_of_birth and phone.
- **doctor:** phone.
- **diagnosis:** diagnosed_on.
- **Names:** the examples first show one name column, while the final tables use first_name and last_name as in the design.

Unique values (patient email), the no-double-booking indexes, the status and duration checks, and the rule that a diagnosis needs a Completed appointment are still needed. Normalisation does not enforce those rules by itself.