# Greenfield Family Clinic Database Design

## Entities

I chose five entities for my clinic appointment system:

| Entity | Information stored |
|---|---|
| patient | A registered patient |
| doctor | A doctor working at the clinic |
| appointment | One booked visit between a patient and a doctor |
| diagnosis | One condition recorded during an appointment |
| prescription | One medication issued during an appointment |

I kept diagnosis and prescription separate from appointment. For example, one visit may produce two diagnoses and three prescriptions. I record the visit once, and each diagnosis or prescription links back to it.

## Attributes and keys

I use an automatically generated ID for each record. In the table below, **unique** means no repeated values. **Required** means the value cannot be `NULL` (missing); checking for blank text is a separate rule.

| Entity | Attributes and proposed PostgreSQL types | Keys and required values |
|---|---|---|
| patient | patient_id BIGINT; first_name VARCHAR(60); last_name VARCHAR(60); date_of_birth DATE; phone VARCHAR(20); email VARCHAR(254) | PK: patient_id. Unique: email. All required. |
| doctor | doctor_id BIGINT; first_name VARCHAR(60); last_name VARCHAR(60); specialty VARCHAR(80); phone VARCHAR(20) | PK: doctor_id. All required. |
| appointment | appointment_id BIGINT; patient_id BIGINT; doctor_id BIGINT; appointment_date DATE; slot_time TIME; status VARCHAR(10) | PK: appointment_id. FKs: patient_id → patient.patient_id; doctor_id → doctor.doctor_id. All required. |
| diagnosis | diagnosis_id BIGINT; appointment_id BIGINT; description TEXT; diagnosed_on DATE | PK: diagnosis_id. FK: appointment_id → appointment.appointment_id. All required. |
| prescription | prescription_id BIGINT; appointment_id BIGINT; medication VARCHAR(120); dosage VARCHAR(60); duration_days INTEGER | PK: prescription_id. FK: appointment_id → appointment.appointment_id. All required. |

`BIGINT` and `INTEGER` hold whole numbers, such as IDs and days. `VARCHAR(60)` holds text up to 60 characters. `DATE` holds a calendar date, `TIME` holds a time of day, and `TEXT` holds text of any length.

**Design assumption:** Appointments use fixed time slots, so each booking has one date and one start time.

## Relationships

| Tables linked | Relationship | Meaning |
|---|---|---|
| patient → appointment | One to many | A patient can have zero or more appointments; each appointment belongs to exactly one patient. |
| doctor → appointment | One to many | A doctor can have zero or more appointments; each appointment belongs to exactly one doctor. |
| appointment → diagnosis | One to many | An appointment can have zero or more diagnoses; each diagnosis belongs to exactly one appointment. |
| appointment → prescription | One to many | An appointment can have zero or more prescriptions; each prescription belongs to exactly one appointment. |

For example, Dr Adams' 10:00 slot on Monday can be booked, cancelled, and then booked again by another patient. I keep both appointment records, but only one can be active at a time. A foreign key links the records on its own; it does not stop a slot being booked twice.

To enforce this, I use partial unique indexes. Each one applies only to active appointments, so cancelled records stay in the table and their slots can be rebooked.

```sql
-- Rule 4: a doctor cannot have two active appointments in the same slot
CREATE UNIQUE INDEX uq_doctor_slot
ON appointment (doctor_id, appointment_date, slot_time)
WHERE status <> 'Cancelled';

-- Rule 5: a patient cannot have two active appointments in the same slot
CREATE UNIQUE INDEX uq_patient_slot
ON appointment (patient_id, appointment_date, slot_time)
WHERE status <> 'Cancelled';
```

## Business rules and constraints

- **Rules 1 and 2:** Patient IDs, doctor IDs and patient emails are unique, and each doctor has one specialty.
- **Rule 3:** Required foreign keys link each appointment to an existing patient and an existing doctor.
- **Rule 4:** A doctor has at most one active appointment per slot. Enforced by `uq_doctor_slot` (see Relationships).
- **Rule 5:** A patient cannot hold two active appointments in the same slot. Enforced by `uq_patient_slot` (see Relationships).
- **Rule 6:** A CHECK constraint allows only Booked, Completed or Cancelled as status.
- **Rule 7:** Cancelling changes the status and keeps the record, so the history stays and the slot is free to rebook.
- **Rule 8:** A diagnosis or prescription must belong to an existing appointment, and that appointment must be Completed. A foreign key covers the first part; the second needs a trigger or transaction logic, not just a key.
- **Rule 9:** A CHECK constraint requires duration_days to be greater than zero.

A slot is available when it has no active appointment. This can be calculated, so the design has no separate availability field.