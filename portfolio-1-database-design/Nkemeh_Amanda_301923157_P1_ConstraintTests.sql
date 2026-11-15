-- Deliberately invalid statements. Each one should fail.
-- Run them one at a time, OUTSIDE a transaction, so one error
-- does not stop the next test. Every test uses otherwise valid values
-- so only the rule being tested can cause the error.
-- Failed inserts may leave gaps in ID numbers. This is normal.

-- Test 1: required field missing (phone is NULL)
-- Expected: ERROR, null value in column "phone" violates not-null constraint
INSERT INTO public.patient (first_name, last_name, date_of_birth, phone, email)
VALUES ('Test', 'Missing', '1990-01-01', NULL, 'test.missing@example.com');

-- Test 2: repeated email (Rule 1)
-- Expected: ERROR, duplicate key value violates unique constraint "patient_email_key"
INSERT INTO public.patient (first_name, last_name, date_of_birth, phone, email)
VALUES ('Duplicate', 'Email', '1991-02-02', '0800000004', 'amina@example.com');

-- Test 3: doctor without a specialty (Rule 2)
-- Expected: ERROR, null value in column "specialty" violates not-null constraint
INSERT INTO public.doctor (first_name, last_name, specialty, phone)
VALUES ('Test', 'Doctor', NULL, '0800000099');

-- Test 4: appointment for a patient that does not exist (Rule 3)
-- The ID used is one higher than the largest existing patient_id.
-- Expected: ERROR, violates foreign key constraint "appointment_patient_id_fkey"
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES ((SELECT MAX(patient_id) + 1 FROM public.patient),
        (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
        '2026-12-10', '09:00', 'Booked');

-- Test 5: appointment for a doctor that does not exist (Rule 3)
-- Expected: ERROR, violates foreign key constraint "appointment_doctor_id_fkey"
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES ((SELECT patient_id FROM public.patient WHERE email = 'amina@example.com'),
        (SELECT MAX(doctor_id) + 1 FROM public.doctor),
        '2026-12-10', '09:00', 'Booked');

-- Test 6: status that is not allowed (Rule 6)
-- Expected: ERROR, violates check constraint "ck_appointment_status"
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES ((SELECT patient_id FROM public.patient WHERE email = 'amina@example.com'),
        (SELECT doctor_id FROM public.doctor WHERE first_name = 'Grace' AND last_name = 'Adeola'),
        '2026-12-10', '09:00', 'Pending');

-- Test 7: doctor already has an active appointment in this slot (Rule 4)
-- Dr Adams has Amina at 2026-12-01 10:00. Ngozi is free then.
-- Expected: ERROR, duplicate key value violates unique constraint "uq_doctor_slot"
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES ((SELECT patient_id FROM public.patient WHERE email = 'ngozi@example.com'),
        (SELECT doctor_id FROM public.doctor WHERE first_name = 'Daniel' AND last_name = 'Adams'),
        '2026-12-01', '10:00', 'Booked');

-- Test 8: patient already has an active appointment in this slot (Rule 5)
-- Amina sees Dr Adams at 2026-12-01 10:00. Dr Adeola is free then.
-- Expected: ERROR, duplicate key value violates unique constraint "uq_patient_slot"
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
VALUES ((SELECT patient_id FROM public.patient WHERE email = 'amina@example.com'),
        (SELECT doctor_id FROM public.doctor WHERE first_name = 'Grace' AND last_name = 'Adeola'),
        '2026-12-01', '10:00', 'Booked');

-- Test 9: diagnosis for an appointment that does not exist
-- Expected: ERROR, violates foreign key constraint "diagnosis_appointment_id_fkey"
INSERT INTO public.diagnosis (appointment_id, description, diagnosed_on)
VALUES ((SELECT MAX(appointment_id) + 1 FROM public.appointment),
        'Test condition', '2026-12-05');

-- Test 10: diagnosis without a description
-- Expected: ERROR, null value in column "description" violates not-null constraint
INSERT INTO public.diagnosis (appointment_id, description, diagnosed_on)
VALUES ((SELECT a.appointment_id FROM public.appointment a
         JOIN public.patient p ON p.patient_id = a.patient_id
         WHERE p.email = 'amina@example.com'
           AND a.appointment_date = '2026-12-01' AND a.slot_time = '10:00'),
        NULL, '2026-12-01');

-- Test 11: prescription with zero days (Rule 9)
-- Expected: ERROR, violates check constraint "ck_prescription_duration"
INSERT INTO public.prescription (appointment_id, medication, dosage, duration_days)
VALUES ((SELECT a.appointment_id FROM public.appointment a
         JOIN public.patient p ON p.patient_id = a.patient_id
         WHERE p.email = 'amina@example.com'
           AND a.appointment_date = '2026-12-01' AND a.slot_time = '10:00'),
        'Ibuprofen', '200 mg', 0);

-- Final check: counts after all invalid inserts have failed.
-- Expected: patient 3, doctor 2, appointment 6, diagnosis 4, prescription 4
SELECT 'patient' AS table_name, count(*) AS row_count FROM public.patient
UNION ALL SELECT 'doctor', count(*) FROM public.doctor
UNION ALL SELECT 'appointment', count(*) FROM public.appointment
UNION ALL SELECT 'diagnosis', count(*) FROM public.diagnosis
UNION ALL SELECT 'prescription', count(*) FROM public.prescription;