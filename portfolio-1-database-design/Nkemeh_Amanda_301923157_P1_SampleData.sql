-- Sample data for Greenfield Family Clinic (all names are fictional)
-- Parent tables are filled first. IDs are looked up, not guessed.

BEGIN;

-- Three patients
INSERT INTO public.patient (first_name, last_name, date_of_birth, phone, email)
VALUES ('Amina', 'Bello',  '1990-04-12', '0800000001', 'amina@example.com'),
       ('Chidi', 'Okafor', '1985-09-30', '0800000002', 'chidi@example.com'),
       ('Ngozi', 'Eze',    '2001-01-20', '0800000003', 'ngozi@example.com');

-- Two doctors
INSERT INTO public.doctor (first_name, last_name, specialty, phone)
VALUES ('Daniel', 'Adams',  'Cardiology',  '0800000011'),
       ('Grace',  'Adeola', 'Dermatology', '0800000012');

-- Six appointments in different states:
-- Completed (3), Booked (2), Cancelled (1).
-- Dr Adams' 2026-12-03 10:00 slot is cancelled for Ngozi, then booked again
-- by Chidi. This is valid because the unique index ignores cancelled rows.
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES
 ((SELECT patient_id FROM public.patient WHERE email = 'amina@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
  '2026-12-01', '10:00', 'Completed'),
 ((SELECT patient_id FROM public.patient WHERE email = 'chidi@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
  '2026-12-01', '11:00', 'Completed'),
 ((SELECT patient_id FROM public.patient WHERE email = 'amina@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Grace' AND last_name = 'Adeola'),
  '2026-12-02', '09:00', 'Completed'),
 ((SELECT patient_id FROM public.patient WHERE email = 'ngozi@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
  '2026-12-03', '10:00', 'Cancelled'),
 ((SELECT patient_id FROM public.patient WHERE email = 'chidi@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
  '2026-12-03', '10:00', 'Booked'),
 ((SELECT patient_id FROM public.patient WHERE email = 'ngozi@example.com'),
  (SELECT doctor_id FROM public.doctor WHERE first_name = 'Grace' AND last_name = 'Adeola'),
  '2026-12-04', '14:00', 'Booked');

-- Four diagnoses, linked to Completed appointments.
-- The appointment is found by patient email, date and time (active rows only).
INSERT INTO public.diagnosis (appointment_id, description, diagnosed_on)
SELECT a.appointment_id, v.description, v.diagnosed_on
FROM (VALUES
        ('amina@example.com', DATE '2026-12-01', TIME '10:00', 'Flu',          DATE '2026-12-01'),
        ('amina@example.com', DATE '2026-12-01', TIME '10:00', 'Dehydration',  DATE '2026-12-01'),
        ('chidi@example.com', DATE '2026-12-01', TIME '11:00', 'Hypertension', DATE '2026-12-01'),
        ('amina@example.com', DATE '2026-12-02', TIME '09:00', 'Eczema',       DATE '2026-12-02')
     ) AS v(email, appt_date, slot, description, diagnosed_on)
JOIN public.patient p ON p.email = v.email
JOIN public.appointment a ON a.patient_id = p.patient_id
                         AND a.appointment_date = v.appt_date
                         AND a.slot_time = v.slot
                         AND a.status <> 'Cancelled';

-- Four prescriptions, found the same way
INSERT INTO public.prescription (appointment_id, medication, dosage, duration_days)
SELECT a.appointment_id, v.medication, v.dosage, v.duration_days
FROM (VALUES
        ('amina@example.com', DATE '2026-12-01', TIME '10:00', 'Paracetamol',          '500 mg',     5),
        ('amina@example.com', DATE '2026-12-01', TIME '10:00', 'Rehydration salts',    '1 sachet',   3),
        ('chidi@example.com', DATE '2026-12-01', TIME '11:00', 'Amlodipine',           '5 mg',      30),
        ('amina@example.com', DATE '2026-12-02', TIME '09:00', 'Hydrocortisone cream', 'thin layer', 7)
     ) AS v(email, appt_date, slot, medication, dosage, duration_days)
JOIN public.patient p ON p.email = v.email
JOIN public.appointment a ON a.patient_id = p.patient_id
                         AND a.appointment_date = v.appt_date
                         AND a.slot_time = v.slot
                         AND a.status <> 'Cancelled';

COMMIT;