
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