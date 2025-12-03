
CREATE OR REPLACE FUNCTION fn_login_with_username_and_password(
    p_username TEXT,
    p_password TEXT
)
RETURNS INT AS
$$
DECLARE
    v_user_id INT;
BEGIN
    SELECT user_id INTO v_user_id
    FROM user_account
    WHERE username = p_username
      AND password = p_password;

    IF v_user_id IS NULL THEN
        RETURN 1; -- login failed
    END IF;

    RETURN 0; -- login success
END;
$$ LANGUAGE plpgsql;


-- 1. User table-----
CREATE TABLE  IF NOT EXISTS user_account (
    user_id SERIAL PRIMARY KEY,
    username TEXT,
    password TEXT,
    role TEXT DEFAULT 'student' 
);

-- test user 
INSERT INTO user_account (username, password, role) 
VALUES ('demo_user', '1234', 'student');
SELECT fn_login_with_username_and_password('ghost_user', '1235');


----services functions-----
CREATE OR REPLACE FUNCTION fn_list_available_services()
RETURNS TABLE (
    service_id INT,
    service_name VARCHAR(100),
    description TEXT,
    base_price NUMERIC(10, 2),
    estimated_duration_times INT,
    required_cleaners INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id AS service_id,
        s.name AS service_name,
        s.description,
        s.base_price,
        s.estimated_duration_times,
        s.required_cleaners
    FROM services s
    WHERE s.is_active = TRUE
    ORDER BY s.base_price ASC;
END;
$$;

-- 2.services Table-----
CREATE TABLE IF NOT EXISTS Services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price NUMERIC(10, 2) NOT NULL,
    estimated_duration_times INT, 
    required_cleaners INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

 
 INSERT INTO Services (name, description, base_price, estimated_duration_times, required_cleaners, is_active)
VALUES
  ('Basic Room Cleaning', 'Sweep, mop, clean bathroom', 300, 1, 1, TRUE),
  ('Deep Room Cleaning', 'Clean bed, floor, bathroom, balcony', 1000, 2, 5, TRUE),
  ('Large Room Cleaning', 'For shared or larger dorm rooms', 900, 2, 3, TRUE),
  ('Suite Cleaning', 'Full suite clean with furniture', 1000, 3, 5, TRUE),
  ('Express Cleaning', 'Fast clean under 1 hour', 400, 1, 1, TRUE),
  ('Shared Room Cleaning', 'For rooms with 2+ students', 700, 2, 2, TRUE),
  ('Post-Party Cleaning', 'Remove trash and wash dishes', 900, 3, 3, TRUE),
  ('Monthly Touch-Up', 'Light clean for subscription users', 500, 1, 2, TRUE),
  ('Bathroom-Focused Cleaning', 'Deep clean bathroom only', 350, 1, 1, TRUE),
  ('Furniture & Floor Care', 'Wipe furniture, mop, polish', 750, 2, 5, TRUE);

--search function-----
CREATE OR REPLACE FUNCTION fn_search_services(
    p_keyword TEXT
)
RETURNS TABLE (
    service_id INT,
    service_name VARCHAR(100),
    description TEXT,
    base_price NUMERIC(10, 2),
    estimated_duration_times INT,
    required_cleaners INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        s.description,
        s.base_price,
        s.estimated_duration_times,
        s.required_cleaners
    FROM services s
    WHERE s.is_active = TRUE
      AND (
           s.name ILIKE '%' || p_keyword || '%' 
        OR s.description ILIKE '%' || p_keyword || '%'
      )
    ORDER BY s.base_price ASC;
END;
$$ LANGUAGE plpgsql;




--3.Cleaner Table-----

CREATE TABLE IF NOT EXISTS team_profiles (
    profile_id SERIAL PRIMARY KEY,
    cleaner_username TEXT,
    full_name TEXT,
    bio TEXT,
    rating DECIMAL(2,1) 
);	


INSERT INTO team_profiles (cleaner_username, full_name, bio, rating) VALUES
('cleaner_joy', 'Auntie Joy', 'Expert in dorm organization and laundry services.', 4.8),
('cleaner_big', 'Big Clean Team', 'Heavy lifting and deep cleaning specialists for moving out.', 5.0),
('cleaner_somchai', 'Uncle Somchai', 'Specializes in high windows, fans, and heavy furniture.', 4.5),
('cleaner_fast', 'Turbo Cleaners', 'Fast service! We finish a standard room in 30 minutes.', 4.2),
('cleaner_eco', 'Green Leaf', 'We use 100% organic, non-toxic cleaning products.', 4.9),
('cleaner_ac', 'Cool Breeze AC', 'Air conditioner cleaning and filter replacement.', 4.7),
('cleaner_laundry', 'Fold & Go', 'Wash, dry, and fold service. Delivered to your door.', 4.6),
('cleaner_pest', 'NoMoreBugs', 'Deep clean plus anti-cockroach gel application.', 4.3),
('cleaner_student', 'Dorm Mate Dave', 'Affordable basic sweeping and mopping by a student.', 3.9),
('cleaner_night', 'Night Owl Services', 'Available for booking after 8:00 PM for late students.', 4.1),
('cleaner_bath', 'Sparkle Bath', 'Focused entirely on scrubbing bathroom mold and tiles.', 4.8),
('cleaner_move', 'Deposit Saver', 'Guaranteed clean to help you get your dorm deposit back.', 5.0);


--function for users to find top rating cleaner---- 

CREATE OR REPLACE FUNCTION fn_get_top_rated_teams(p_min_rating DECIMAL)
RETURNS TABLE(name TEXT, biography TEXT, stars DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT full_name, bio, rating
    FROM team_profiles
    WHERE rating >= p_min_rating
    ORDER BY rating DESC;
END;
$$ LANGUAGE plpgsql;


---4.Location Table------
CREATE TABLE dorm_locations (
    location_id SERIAL PRIMARY KEY,
    user_name TEXT,       
    dorm_name TEXT,       
    building_name TEXT,   
    room_number TEXT          
);

INSERT INTO dorm_locations (user_name, dorm_name, building_name, room_number) VALUES
('student_tang', 'Tangsin Dorm', 'Building A', '412'),
('student_alice', 'Tangsin Dorm', 'Building B', '305'),
('student_bob', 'International House', 'Tower 1', '1002'),
('student_cat', 'City Park Dorm', 'Wing C', '204'),
('student_dave', 'Riverside Home', 'Main', '101'),
('student_eve', 'Green View', 'Block 4', '550'),
('student_frank', 'The Loft', 'Building A', '808'),
('student_grace', 'Campus Condo', 'T1', '1204'),
('student_grace', 'Campus Condo', 'T2', '303'),
('student_hank', 'Elite Ladies', 'Suite A', '112'),
('student_ivy', 'Tangsin Dorm', 'Building A', '413'),
('student_jack', 'Victory Corner', 'North', '777');

---
CREATE OR REPLACE FUNCTION fn_get_user_location(p_user TEXT)
RETURNS dorm_locations AS $$
DECLARE
    loc dorm_locations;
BEGIN
    SELECT *
    INTO loc
    FROM dorm_locations
    WHERE user_name = p_user
    ORDER BY location_id DESC
    LIMIT 1;

    RETURN loc;
END;
$$ LANGUAGE plpgsql;



---5.Date and time Table-------

CREATE TABLE IF NOT EXISTS service_date_time (
    availability_id SERIAL PRIMARY KEY,
    user_name TEXT NOT NULL,                   
    role TEXT CHECK (role IN ('customer','cleaner')),
    available_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);


INSERT INTO service_date_time (user_name, role, available_date, start_time, end_time) VALUES

('student_tang',      'customer', '2025-12-05', '10:00', '12:00'),
('student_alice',     'customer', '2025-12-05', '13:00', '15:00'),
('student_bob',       'customer', '2025-12-06', '09:00', '11:00'),
('student_cat',       'customer', '2025-12-06', '11:30', '14:30'),
('student_dave',      'customer', '2025-12-07', '14:00', '16:00'),
('student_ivy',       'customer', '2025-12-07', '08:00', '10:00'),
('cleaner_joy',       'cleaner',  '2025-12-05', '09:00', '17:00'),
('cleaner_somchai',   'cleaner',  '2025-12-05', '11:00', '19:00'),
('cleaner_eco',       'cleaner',  '2025-12-06', '08:00', '14:00'),
('cleaner_night',     'cleaner',  '2025-12-06', '20:00', '23:00'),
('cleaner_fast',      'cleaner',  '2025-12-07', '07:00', '10:00'),
('cleaner_sara',      'cleaner',  '2025-12-07', '10:00', '18:00');


ALTER TABLE service_date_time
ADD CONSTRAINT service_dt_unique UNIQUE (user_name, role, available_date, start_time);




--save cleaners and customers availble time
CREATE OR REPLACE FUNCTION fn_save_service_date_time(
    p_user TEXT,
    p_role TEXT,
    p_date DATE,
    p_start TIME,
    p_end TIME
)
RETURNS INT AS $$
DECLARE v_id INT;
BEGIN
    INSERT INTO service_date_time (user_name, role, available_date, start_time, end_time)
    VALUES (p_user, p_role, p_date, p_start, p_end)

    ON CONFLICT (user_name, role, available_date, start_time)
    DO UPDATE SET end_time = EXCLUDED.end_time

    RETURNING availability_id INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;



--find matching cleaners, customers available service time
CREATE OR REPLACE FUNCTION fn_find_matching_cleaners(
    p_customer_username TEXT,
    p_date DATE
)
RETURNS TABLE (
    cleaner_username   TEXT,
    cleaner_full_name  TEXT,
    rating             DECIMAL(2,1),
    match_start        TIME,
    match_end          TIME
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cl.user_name AS cleaner_username,
        tp.full_name AS cleaner_full_name,
        tp.rating,
        GREATEST(c.start_time, cl.start_time) AS match_start,
        LEAST(c.end_time,   cl.end_time)      AS match_end
    FROM service_date_time c
    JOIN service_date_time cl
      ON c.available_date = cl.available_date
    LEFT JOIN team_profiles tp
      ON tp.cleaner_username = cl.user_name
    WHERE
        c.user_name = p_customer_username
        AND c.role = 'customer'
        AND cl.role = 'cleaner'
        AND c.available_date = p_date
        -- time overlap:
        AND c.start_time < cl.end_time
        AND cl.start_time < c.end_time
        -- make sure overlap is positive, not zero
        AND GREATEST(c.start_time, cl.start_time)
            < LEAST(c.end_time, cl.end_time)
    ORDER BY
        rating DESC NULLS LAST,
        match_start ASC;
END;
$$ LANGUAGE plpgsql;


-- 6. Bookings table -----
CREATE TABLE IF NOT EXISTS bookings (
    booking_id SERIAL PRIMARY KEY,

   
    customer_username TEXT NOT NULL,
    cleaner_username  TEXT NOT NULL,

    
    service_id  INT NOT NULL REFERENCES services(id),
    location_id INT NOT NULL REFERENCES dorm_locations(location_id),

    
    booking_date DATE NOT NULL,
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,

   
    status TEXT CHECK (status IN ('pending','confirmed','completed','cancelled'))
        DEFAULT 'pending',

   
    total_price NUMERIC(10, 2) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- create a new booking based on service duration
CREATE OR REPLACE FUNCTION fn_create_booking(
    p_customer_username TEXT,
    p_cleaner_username  TEXT,
    p_service_id        INT,
    p_location_id       INT,
    p_booking_date      DATE,
    p_start_time        TIME
)
RETURNS INT AS $$
DECLARE
    v_booking_id     INT;
    v_duration_hours INT;
    v_end_time       TIME;
    v_price          NUMERIC(10,2);
BEGIN
    -- get service duration & base price
    SELECT estimated_duration_times,
           base_price
    INTO   v_duration_hours,
           v_price
    FROM services
    WHERE id = p_service_id
      AND is_active = TRUE;

    IF v_duration_hours IS NULL THEN
        RAISE EXCEPTION 'Service % not found or inactive', p_service_id;
    END IF;

    -- calculate end_time: start + duration (in HOURS)
    v_end_time := (p_start_time::time + (v_duration_hours || ' hours')::interval)::time;

    -- insert booking
    INSERT INTO bookings (
        customer_username,
        cleaner_username,
        service_id,
        location_id,
        booking_date,
        start_time,
        end_time,
        status,
        total_price
    )
    VALUES (
        p_customer_username,
        p_cleaner_username,
        p_service_id,
        p_location_id,
        p_booking_date,
        p_start_time,
        v_end_time,
        'pending',
        v_price
    )
    RETURNING booking_id INTO v_booking_id;

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql;


--- input of create_booking function, then it will return new booking id----
SELECT fn_create_booking(
    'student_tang',    -- customer
    'cleaner_joy',     -- cleaner
    1,                 -- service_id
    1,                 -- location_id
    '2025-12-05',      -- date
    '11:00'            -- start_time
);

