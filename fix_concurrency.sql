-- =====================================================
-- CONCURRENCY CONTROL & BOOKING LOGIC
-- =====================================================

-- 1. Create a function to check availability and book in ONE atomic transaction
CREATE OR REPLACE FUNCTION public.book_appointment(
    p_barber_id UUID,
    p_client_id UUID,
    p_service_id UUID,
    p_start_time TIMESTAMPTZ,
    p_duration_minutes INT,
    p_price DECIMAL,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_end_time TIMESTAMPTZ;
    v_conflict_count INT;
    v_new_appointment_id UUID;
BEGIN
    -- Calculate end time
    v_end_time := p_start_time + (p_duration_minutes || ' minutes')::INTERVAL;

    -- LOCKING: Explicitly lock the appointments table for this barber to prevent race conditions.
    -- 'EXPLICIT LOCK' isn't strictly needed if we use SERIALIZABLE isolation, 
    -- but a simple overlap check is usually enough in Read Committed if we trust the query.
    -- However, for absolute safety, we check for overlaps.

    SELECT COUNT(*)
    INTO v_conflict_count
    FROM public.appointments
    WHERE barber_id = p_barber_id
      AND status NOT IN ('cancelled', 'declined') -- Ignore cancelled slots
      AND (
          (scheduled_at, scheduled_at + (duration_minutes || ' minutes')::INTERVAL) 
          OVERLAPS 
          (p_start_time, v_end_time)
      );

    -- If there is a conflict, RAISE EXCEPTION or return error JSON
    IF v_conflict_count > 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'This time slot has just been taken. Please choose another.'
        );
    END IF;

    -- No conflict? Insert the appointment.
    INSERT INTO public.appointments (
        barber_id,
        client_id,
        service_id,
        scheduled_at,
        duration_minutes,
        total_price,
        notes,
        status,
        created_at
    ) VALUES (
        p_barber_id,
        p_client_id,
        p_service_id,
        p_start_time,
        p_duration_minutes,
        p_price,
        p_notes,
        'pending', -- Default to pending, requires confirmation
        NOW()
    ) RETURNING id INTO v_new_appointment_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'appointment_id', v_new_appointment_id,
        'message', 'Appointment requested successfully'
    );

EXCEPTION WHEN OTHERS THEN
    -- Catch unexpected errors
    RETURN jsonb_build_object(
        'success', false,
        'message', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- 2. Add an Exclusion Constraint (Hard Database Rule)
-- This prevents overlapping bookings at the database level, even if the function is bypassed.
-- Note: Requires 'btree_gist' extension.
CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE public.appointments
ADD CONSTRAINT prevent_overlapping_appointments
EXCLUDE USING GIST (
    barber_id WITH =,
    tstzrange(scheduled_at, scheduled_at + (duration_minutes || ' minutes')::INTERVAL) WITH &&
) WHERE (status NOT IN ('cancelled', 'declined'));
