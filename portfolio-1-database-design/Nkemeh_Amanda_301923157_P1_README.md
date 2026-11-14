# Portfolio 1: Database Design and Modelling

## Selected case study
**Organisation:** Greenfield Family Clinic

**Nature of the business:** A mid-sized outpatient clinic where patients
book appointments with doctors, receive diagnoses and are given
prescriptions. The clinic needs a reliable database to manage scheduling
and patient records.

**Users of the database:**
- Receptionists: register patients and book, reschedule or cancel appointments.
- Doctors: view their schedule, record diagnoses and issue prescriptions.
- Clinic administrators: report on appointments and doctor workload.

**Major data to be stored:**
- Patients (contact details, date of birth)
- Doctors (specialty, contact details)
- Appointments (patient, doctor, date, time slot, status)
- Diagnoses and prescriptions linked to appointments

**Key operations the database will support:**
1. Register a patient.
2. Book an appointment without double-booking a doctor's time slot.
3. Cancel or complete an appointment.
4. Record a diagnosis and prescription.
5. Retrieve a patient's full history.
6. Report appointments per doctor and per day.