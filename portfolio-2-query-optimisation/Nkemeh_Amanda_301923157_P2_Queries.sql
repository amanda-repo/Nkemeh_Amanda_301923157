-- Portfolio 2: queries for Greenfield Family Clinic (read-only)

-- Q1: Appointments that are booked, with patient and doctor.
SELECT a.appointment_date, a.slot_time,
       p.first_name || ' ' || p.last_name AS patient,
       d.first_name || ' ' || d.last_name AS doctor
FROM public.appointment a
JOIN public.patient p USING (patient_id)
JOIN public.doctor d USING (doctor_id)
WHERE a.status = 'Booked'
ORDER BY a.appointment_date, a.slot_time;

-- Q2: A doctor is free for a slot when they have no active appointment in it.
-- Cancelled appointments are ignored, matching the partial unique index.
SELECT d.first_name || ' ' || d.last_name AS doctor, d.specialty
FROM public.doctor d
WHERE NOT EXISTS (
    SELECT 1 FROM public.appointment a
    WHERE a.doctor_id = d.doctor_id
      AND a.appointment_date = DATE '2026-12-01'
      AND a.slot_time = TIME '10:00'
      AND a.status <> 'Cancelled'
)
ORDER BY doctor;

-- Q3: Count completed appointments for each patient, including patients with none.
SELECT p.first_name || ' ' || p.last_name AS patient,
       count(a.appointment_id) AS completed_appointments
FROM public.patient p
LEFT JOIN public.appointment a
       ON a.patient_id = p.patient_id AND a.status = 'Completed'
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY patient;