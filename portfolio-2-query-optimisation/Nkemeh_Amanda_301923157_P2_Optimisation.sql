-- Portfolio 2: execution plan comparison for Greenfield Family Clinic.
-- Section 1 (setup) runs once. Do not rerun it.

-- 1a. Create a separate area for the test table.
CREATE SCHEMA p2_benchmark;

-- 1b. Create 100,000 made-up appointment records for the speed test.
-- Each record has a start time and an end time 30 minutes later.
-- They use Amina's patient ID and Dr Adams' doctor ID from Portfolio 1.
-- This is a synthetic test table with no keys or constraints.
CREATE TABLE p2_benchmark.appointment_history AS
SELECT g AS history_id, p.patient_id, d.doctor_id,
       TIMESTAMPTZ '2000-01-01 00:00:00+00' + g * INTERVAL '1 hour' AS scheduled_at,
       TIMESTAMPTZ '2000-01-01 00:00:00+00' + g * INTERVAL '1 hour' + INTERVAL '30 minutes' AS ended_at
FROM generate_series(1, 100000) AS g
CROSS JOIN public.patient p
CROSS JOIN public.doctor d
WHERE p.email = 'amina@example.com'
  AND d.first_name = 'Daniel' AND d.last_name = 'Adams';

-- 1c. Refresh statistics so PostgreSQL can choose a plan, then count the rows.
ANALYZE p2_benchmark.appointment_history;
SELECT count(*) AS test_rows FROM p2_benchmark.appointment_history;

-- 2. Count appointments on one day (2005-01-01). Expected result: 24.
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- 3. Measure BEFORE the index.
-- Run once as a warm-up and ignore it. Clear the screen with Ctrl+L.
-- Then run it three more times and write down each Execution Time.
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- 4a. Add a B-tree index on the column used by the date filter.
CREATE INDEX appointment_history_scheduled_at_idx
    ON p2_benchmark.appointment_history (scheduled_at);

-- 4b. Measure AFTER the index with the identical statement.
--- Run once as a warm-up, clear the screen, then run three measured times.
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) AS appointments_on_day FROM p2_benchmark.appointment_history
WHERE scheduled_at >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND scheduled_at <  TIMESTAMPTZ '2005-01-02 00:00:00+00';