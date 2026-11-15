-- Session B. Do not run this whole file. Follow the A, B, A, B order.
-- psql commands: \pset pager off  and  \set PROMPT1 'Session B%R%x%# '

SET application_name = 'p3_session_b';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

-- B cannot see A's uncommitted booking, so the slot looks free (expected 0).
SELECT count(*) AS visible_active_bookings
FROM public.appointment a
WHERE a.doctor_id = (SELECT doctor_id FROM public.doctor
                     WHERE first_name = 'Grace' AND last_name = 'Adeola')
  AND a.appointment_date = DATE '2026-12-06'
  AND a.slot_time = TIME '10:00'
  AND a.status <> 'Cancelled';

-- Try to book the same slot for Chidi. B waits until A commits.
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
SELECT p.patient_id, d.doctor_id, DATE '2026-12-06', TIME '10:00', 'Booked'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.email = 'chidi@example.com'
  AND d.first_name = 'Grace' AND d.last_name = 'Adeola';

-- STOP HERE. Switch to Session A, check the wait, and commit.

-- After A commits, B gets the uq_doctor_slot error. Undo B and check the result.
ROLLBACK;

SELECT p.first_name || ' ' || p.last_name AS patient,
       d.last_name AS doctor, a.appointment_date, a.slot_time,
       count(*) AS active_bookings
FROM public.appointment a
JOIN public.patient p USING (patient_id)
JOIN public.doctor d  USING (doctor_id)
WHERE d.last_name = 'Adeola'
  AND a.appointment_date = DATE '2026-12-06'
  AND a.slot_time = TIME '10:00'
  AND a.status <> 'Cancelled'
GROUP BY p.patient_id, p.first_name, p.last_name, d.last_name,
         a.appointment_date, a.slot_time;