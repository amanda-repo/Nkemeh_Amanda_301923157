-- Greenfield Family Clinic schema (PostgreSQL 16)
-- Tables are created in the public schema, parent tables first.

BEGIN;

-- Patients registered at the clinic
CREATE TABLE public.patient (
    patient_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name    VARCHAR(60)  NOT NULL,
    last_name     VARCHAR(60)  NOT NULL,
    date_of_birth DATE         NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    email         VARCHAR(254) NOT NULL UNIQUE  -- Rule 1: no repeated emails
);

-- Doctors working at the clinic
CREATE TABLE public.doctor (
    doctor_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name  VARCHAR(60) NOT NULL,
    specialty  VARCHAR(80) NOT NULL,            -- Rule 2: one specialty per doctor
    phone      VARCHAR(20) NOT NULL
);

-- One booked visit between a patient and a doctor
CREATE TABLE public.appointment (
    appointment_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id       BIGINT      NOT NULL REFERENCES public.patient (patient_id),  -- Rule 3
    doctor_id        BIGINT      NOT NULL REFERENCES public.doctor (doctor_id),    -- Rule 3
    appointment_date DATE        NOT NULL,
    slot_time        TIME        NOT NULL,
    status           VARCHAR(10) NOT NULL,
    CONSTRAINT ck_appointment_status                -- Rule 6: allowed statuses
        CHECK (status IN ('Booked', 'Completed', 'Cancelled'))
);

-- Rule 4: a doctor has one active appointment per slot (cancelled rows ignored)
CREATE UNIQUE INDEX uq_doctor_slot
    ON public.appointment (doctor_id, appointment_date, slot_time)
    WHERE status <> 'Cancelled';

-- Rule 5: a patient has one active appointment per slot (cancelled rows ignored)
CREATE UNIQUE INDEX uq_patient_slot
    ON public.appointment (patient_id, appointment_date, slot_time)
    WHERE status <> 'Cancelled';

-- One condition recorded during an appointment
CREATE TABLE public.diagnosis (
    diagnosis_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id BIGINT NOT NULL REFERENCES public.appointment (appointment_id),
    description    TEXT   NOT NULL,
    diagnosed_on   DATE   NOT NULL
);

-- One medication issued during an appointment
CREATE TABLE public.prescription (
    prescription_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id  BIGINT       NOT NULL REFERENCES public.appointment (appointment_id),
    medication      VARCHAR(120) NOT NULL,
    dosage          VARCHAR(60)  NOT NULL,
    duration_days   INTEGER      NOT NULL,
    CONSTRAINT ck_prescription_duration         -- Rule 9: duration above zero
        CHECK (duration_days > 0)
);

-- Limits of this schema:
-- Rule 7 (cancel keeps history) is handled by updating status, not deleting.
-- Rule 8 (diagnosis or prescription only for a Completed appointment) is NOT
-- enforced here. The foreign keys only prove the appointment exists, so a
-- trigger or transaction logic is needed to check its status.

COMMIT;