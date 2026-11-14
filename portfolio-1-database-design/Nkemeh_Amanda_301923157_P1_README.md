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

