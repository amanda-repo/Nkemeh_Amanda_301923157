-- Session A. Do not run this whole file. Follow the A, B, A, B order.
-- psql prompt label: \set PROMPT1 'Session A%R%x%# '

SET application_name = 'p3_session_a';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

-- Book Dr Adeola at 10:00 on 2026-12-06 for Amina. Do not commit yet.
INSERT INTO public.appointment (patient_id, doctor_id, appointment_date, slot_time, status)
SELECT p.patient_id, d.doctor_id, DATE '2026-12-06', TIME '10:00', 'Booked'
FROM public.patient p CROSS JOIN public.doctor d
WHERE p.email = 'amina@example.com'
  AND d.first_name = 'Grace' AND d.last_name = 'Adeola';

-- STOP HERE. Switch to Session B and run its commands.

-- Back in A: confirm B is waiting on a lock.
SELECT application_name, wait_event_type FROM pg_stat_activity
WHERE application_name = 'p3_session_b';

-- Save Amina's booking. B's insert now fails.
COMMIT;

-- Switch to Session B for the outcome.