-- 1. Create the user_db database
CREATE DATABASE user_db;

-- 2. Create department table
CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    department_head VARCHAR(255),  -- Can also be a foreign key to userdata if needed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- created timestamp
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create role table
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) UNIQUE NOT NULL,
    role_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- created timestamp
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create userdata table with department_id and role_id as foreign keys
CREATE TABLE userdata (
    id SERIAL PRIMARY KEY,                              -- auto-incrementing primary key
    user_id VARCHAR(50) UNIQUE NOT NULL,                -- manual-only user ID
    user_full_name VARCHAR(255) UNIQUE NOT NULL,
    user_address VARCHAR(255),
    user_telephone VARCHAR(15),
    user_type VARCHAR(50) NOT NULL,
    department_id INTEGER,
    role_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- created timestamp
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- updated timestamp
    CONSTRAINT fk_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_role
        FOREIGN KEY (role_id)
        REFERENCES role(role_id)
        ON DELETE SET NULL
);

-- Insert sample data into userdata
--INSERT INTO userdata (user_name, user_type, user_address, user_telephone)
--VALUES ('Judy', 'User', '123 User St', '123-456-7890')
--ON CONFLICT (user_id) DO NOTHING;
--
---- Query all data
--SELECT * FROM userdata;
--
--DROP Table department
