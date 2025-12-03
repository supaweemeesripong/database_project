
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


--User table
CREATE TABLE user_account (
    user_id SERIAL PRIMARY KEY,
    username TEXT,
    password TEXT,
    role TEXT DEFAULT 'student' 
);

-- test user 
INSERT INTO user_account (username, password, role) 
VALUES ('demo_user', '1234', 'student');
SELECT fn_login_with_username_and_password('ghost_user', '1235');


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

--Available services Table
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

--search function
CREATE OR REPLACE FUNCTION fn_search_services(
    p_keyword TEXT
)
RETURNS TABLE (
    service_id INT,
    service_name VARCHAR,
    description TEXT,
    base_price NUMERIC,
    estimated_duration_times INT,
    required_cleaners INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.name, s.description, s.base_price, s.estimated_duration_times, s.required_cleaners
    FROM services s
    WHERE s.business_id = p_business_id
      AND s.is_active = TRUE
      AND s.name ILIKE '%' || p_keyword || '%';
END;
$$ LANGUAGE plpgsql;



--cleaner profiles table with 10+ rows data

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


--function for users to find top rating cleaner 

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



---