# Portfolio 1: Database Design and Modelling

## Case study
Greenfield Family Clinic: A mid-sized outpatient clinic where patients
book appointments with doctors, receive diagnoses and are given
prescriptions. The clinic needs a reliable database to manage scheduling
and patient records.

## Users
- Receptionists: register patients and book, reschedule or cancel appointments.
- Doctors: view their schedule, record diagnoses and issue prescriptions.
- Clinic administrators: report on appointments and doctor workload.

## Major data to be stored
- Patients (contact details, date of birth)
- Doctors (specialty, contact details)
- Appointments (patient, doctor, date, time slot, status)
- Diagnoses and prescriptions linked to appointments

## Scope
Greenfield Family Clinic is a single-branch clinic with fictional records
and in-person appointments. Billing and insurance, patient portal login and
authentication, lab tests, referrals, and multi-branch scheduling are
outside this example.

## Key operations
- Register a patient.
- Book an appointment without double-booking a doctor's time slot.
- Cancel or complete an appointment.
- Record a diagnosis and prescription.
- Retrieve a patient's full history.
- Report appointments per doctor and per day.

## Business rules
- Each patient has a unique patient ID and a unique email address.
- Each doctor has one specialty and a unique doctor ID.
- Each appointment refers to one existing patient and one existing doctor.
- A doctor can have at most one active appointment in a given date and time slot.
- A patient can have several appointments, but not two active appointments
   with different doctors in the same time slot.
- Appointment status must be Booked, Completed or Cancelled.
- Cancelling an appointment changes its status without deleting its history,
   and a cancelled slot can be booked again.
- A diagnosis or prescription must belong to one existing appointment, and
   can only be recorded for a Completed appointment.
- Prescription duration must be greater than zero days.

## Design and implementation files

| File | Contents |
| --- | --- |
| [Design](Nkemeh_Amanda_301923157_P1_Design.md) | Entities, attributes, keys, relationships and constraints. |
| [ER diagram](Nkemeh_Amanda_301923157_P1_ERDiagram.md) | The five tables and their relationships. |
| [Normalisation](Nkemeh_Amanda_301923157_P1_Normalisation.md) | Example tables showing 1NF, 2NF and 3NF. |
| [Schema](Nkemeh_Amanda_301923157_P1_Schema.sql) | Table definitions, keys, constraints and partial indexes. |
| [Sample records](Nkemeh_Amanda_301923157_P1_SampleData.sql) | Fictional patients, doctors, appointments, diagnoses and prescriptions. |
| [Constraint tests](Nkemeh_Amanda_301923157_P1_ConstraintTests.sql) | Invalid inserts and the final count query. |
| [Setup notes](Nkemeh_Amanda_301923157_P1_Setup_Notes.md) | PostgreSQL installation and connection steps. |
| [Screenshots](screenshots/) | Saved commands and results. |

## Implementation

The database runs on PostgreSQL in GitHub Codespaces. Its name is greenfield_clinic_portfolio, and I connect to it with psql as the postgres user. It contains patient, doctor, appointment, diagnosis and prescription tables, each with an automatically generated primary key. Foreign keys link every appointment to one patient and one doctor, and every diagnosis and prescription to one appointment.

Patient emails are unique, all fields are required, and CHECK constraints allow only the statuses Booked, Completed and Cancelled and a prescription duration above zero. Two partial unique indexes stop a doctor or a patient having two active appointments in the same slot, while ignoring cancelled ones so the slot can be rebooked. I created the tables inside one BEGIN and COMMIT group, loaded the sample data in the same way, and ran each invalid insert on its own outside a transaction.

## Test results

Eleven invalid inserts were rejected: a missing phone, a repeated email, a missing specialty, a nonexistent patient, a nonexistent doctor, an invalid status, a doctor double-booking, a patient double-booking, a diagnosis for a nonexistent appointment, a missing diagnosis description and a prescription lasting zero days. Each failed on the intended rule, and the screenshots in the screenshots folder show the error messages. The valid data also includes a cancelled slot that was booked again, which the partial indexes allow.

The final counts are 3 patients, 2 doctors, 6 appointments, 4 diagnoses and 4 prescriptions, the same as before the tests, so the failed inserts added no rows. Failed inserts still use up ID numbers, so later IDs can skip values without affecting correctness.

The rule that a diagnosis or prescription is allowed only for a Completed appointment is not enforced by the table definitions and was not tested. It needs a trigger or transaction logic, which I consider in Portfolio 3. Reference: [PostgreSQL constraints](https://www.postgresql.org/docs/16/ddl-constraints.html).