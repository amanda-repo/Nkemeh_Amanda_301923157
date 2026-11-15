-- Portfolio 3: commit and rollback for Greenfield Family Clinic.
-- Run once, in order. Failed inserts can leave gaps in generated IDs.

-- 1. Starting-data check.
SELECT a.appointment_date, a.slot_time, p.last_name AS patient,
       d.last_name AS doctor, a.status
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
JOIN public.doctor d  ON d.doctor_id  = a.doctor_id
ORDER BY a.appointment_date, a.slot_time, a.status;

-- 2. Cancel one booked appointment and save it with COMMIT.
BEGIN;

-- Cancel only if the appointment is still Booked.
UPDATE public.appointment
SET status = 'Cancelled'
WHERE appointment_id = (
        SELECT a.appointment_id
        FROM public.appointment a
        JOIN public.patient p ON p.patient_id = a.patient_id
        WHERE p.email = 'ngozi@example.com'
          AND a.appointment_date = DATE '2026-12-04'
          AND a.slot_time = TIME '14:00')
  AND status = 'Booked';

COMMIT;

-- 2b. Repeat the same cancellation. The status condition stops it running twice.
UPDATE public.appointment
SET status = 'Cancelled'
WHERE appointment_id = (
        SELECT a.appointment_id
        FROM public.appointment a
        JOIN public.patient p ON p.patient_id = a.patient_id
        WHERE p.email = 'ngozi@example.com'
          AND a.appointment_date = DATE '2026-12-04'
          AND a.slot_time = TIME '14:00')
  AND status = 'Booked';

-- 3. Add a valid appointment, then break a rule, then undo everything with ROLLBACK.
BEGIN;

INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
SELECT p.patient_id, d.doctor_id, DATE '2026-12-05', TIME '09:00', 'Booked'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.email = 'amina@example.com'
  AND d.first_name = 'Grace' AND d.last_name = 'Adeola';

-- Deliberate error: 'Pending' is not an allowed status (ck_appointment_status).
UPDATE public.appointment
SET status = 'Pending'
WHERE patient_id = (SELECT patient_id FROM public.patient WHERE email = 'amina@example.com')
  AND appointment_date = DATE '2026-12-05'
  AND slot_time = TIME '09:00';

ROLLBACK;

-- 4. Check the saved cancellation stayed and the rolled-back booking is gone.
SELECT a.status AS saved_status
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
WHERE p.email = 'ngozi@example.com'
  AND a.appointment_date = DATE '2026-12-04' AND a.slot_time = TIME '14:00';

SELECT count(*) AS amina_dec5_appointments
FROM public.appointment a
JOIN public.patient p ON p.patient_id = a.patient_id
WHERE p.email = 'amina@example.com' AND a.appointment_date = DATE '2026-12-05';