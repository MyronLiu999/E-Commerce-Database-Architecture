-- 1. Create target database (if not exists) and switch to it
-- Critical step: Ensures all subsequent objects are created in the correct database
CREATE DATABASE IF NOT EXISTS Ecommerce;
USE Ecommerce;

-- 2. Create Address table first (required for foreign key constraint in User table)
-- Address table stores user address information, referenced by User.address_id
CREATE TABLE IF NOT EXISTS Address (
    address_id INT PRIMARY KEY,  -- Primary key, mapped to User.address_id
    street VARCHAR(255),         -- Street name (e.g., "123 Main St")
    city VARCHAR(100),           -- City name (e.g., "Los Angeles")
    state VARCHAR(100),          -- State/province (e.g., "CA" for California)
    zip_code VARCHAR(20),        -- Postal/zip code (e.g., "90001")
    country VARCHAR(100)         -- Country (e.g., "USA")
);

-- 3. Create User table (corrected structure with required fields and foreign key)
CREATE TABLE IF NOT EXISTS User (
    user_id VARCHAR(20) PRIMARY KEY,  -- Custom ID format: U1001-U2000
    email VARCHAR(255) NOT NULL,      -- Unique user email (non-null)
    first_name VARCHAR(100) NOT NULL, -- User's first name
    last_name VARCHAR(100) NOT NULL,  -- User's last name
    phone_number VARCHAR(20) NOT NULL,-- Contact phone number (formatted as +1-555-XXX-XXXX)
    password_hash VARCHAR(50) NOT NULL,-- Encrypted password (40-bit SHA1 hash)
    address_id INT NOT NULL,          -- Foreign key referencing Address.address_id
    FOREIGN KEY (address_id) REFERENCES Address(address_id) -- Enforce referential integrity
);

-- 4. Disable safe update mode (prevents errors when inserting via loop)
-- Temporarily turns off MySQL's safe update check for batch operations
SET SQL_SAFE_UPDATES = 0;

-- 5. Drop existing stored procedure (if it exists) to avoid duplicate creation errors
DROP PROCEDURE IF EXISTS GenerateUserData;

-- 6. Create stored procedure to batch generate 1000 user records
-- Fix: Corrected unclosed string in first_names definition (critical syntax fix)
DELIMITER //  -- Temporarily change delimiter to // (avoids misparsing ; inside the procedure)
CREATE PROCEDURE GenerateUserData()
BEGIN
    -- Declare variables for loop control and data generation
    DECLARE i INT DEFAULT 1;                  -- Loop counter (1 to 1000)
    DECLARE first_name_idx INT;               -- Random index for first name selection
    DECLARE last_name_idx INT;                -- Random index for last name selection
    DECLARE user_id VARCHAR(20);              -- Generated user_id (U1001-U2000)
    DECLARE first_name VARCHAR(100);          -- Randomly selected first name
    DECLARE last_name VARCHAR(100);           -- Randomly selected last name
    DECLARE email VARCHAR(255);               -- Unique email address
    DECLARE phone_number VARCHAR(20);         -- Formatted phone number
    DECLARE password_hash VARCHAR(50);        -- Encrypted password hash
    DECLARE address_id INT;                   -- Mapped address ID (1-1000)

    -- List of common English first names (extendable for more variety)
    DECLARE first_names VARCHAR(1000) DEFAULT 'Emma,Liam,Olivia,Noah,Ava,Ethan,Sophia,Lucas,Mia,James,Amelia,Oliver,Charlotte,Elijah,Aria,William,Isabella,Benjamin,Harper,Evelyn,Alexander,Chloe,Owen,Zoey,Elias,Luna,Axel,Ella,Amelia';
    -- List of common English last names (extendable for more variety)
    DECLARE last_names VARCHAR(1000) DEFAULT 'Wilson,Johnson,Smith,Brown,Jones,Garcia,Martinez,Rodriguez,Taylor,Davis,Hernandez,Moore,Martin,Jackson,Thompson,White,Davis,Harris,Thomas,Martinez';

    -- Loop to generate 1000 user records (i = 1 → U1001; i = 1000 → U2000)
    WHILE i <= 1000 DO
        -- Generate user_id in the format "U1001-U2000"
        SET user_id = CONCAT('U', 1000 + i);

        -- Calculate random index for first name (based on number of commas in first_names)
        -- Formula: 1 + random number between 0 and (total commas) → ensures valid index
        SET first_name_idx = FLOOR(1 + RAND() * (LENGTH(first_names) - LENGTH(REPLACE(first_names, ',', ''))));
        -- Extract random first name using SUBSTRING_INDEX (splits by commas)
        SET first_name = SUBSTRING_INDEX(SUBSTRING_INDEX(first_names, ',', first_name_idx), ',', -1);

        -- Same logic for random last name selection
        SET last_name_idx = FLOOR(1 + RAND() * (LENGTH(last_names) - LENGTH(REPLACE(last_names, ',', ''))));
        SET last_name = SUBSTRING_INDEX(SUBSTRING_INDEX(last_names, ',', last_name_idx), ',', -1);

        -- Generate unique email: firstname.lastname+user_id_suffix@example.com
        -- Lowercase to ensure consistency (e.g., emma.wilson1001@example.com)
        SET email = CONCAT(LOWER(first_name), '.', LOWER(last_name), 1000 + i, '@example.com');

        -- Generate phone number in +1-555-XXX-XXXX format (aligned with user_id)
        -- Example: U1001 → +1-555-1001-2001; U2000 → +1-555-2000-3000
        SET phone_number = CONCAT('+1-555-', 1000 + i, '-', 2000 + i);

        -- Generate password hash using SHA1 (40-bit alphanumeric string)
        -- Combines RAND() (random number) and UUID() (unique ID) for randomness
        SET password_hash = SHA1(CONCAT(RAND(), UUID()));

        -- Map address_id to loop counter (1-1000, matches Address table's address_id)
        SET address_id = i;

        -- Insert generated data into the User table
        INSERT INTO User (
            user_id, email, first_name, last_name, phone_number, password_hash, address_id
        ) VALUES (
            user_id, email, first_name, last_name, phone_number, password_hash, address_id
        );

        -- Increment loop counter to generate next record
        SET i = i + 1;
    END WHILE;

    -- Return success message after loop completes
    SELECT '1000 user records generated successfully!' AS result;
END //
DELIMITER ;  -- Restore default delimiter to ;

-- 7. Batch insert 1000 test address records (required for foreign key compatibility)
-- Ensures Address table has address_id 1-1000 (avoids foreign key constraint errors)
INSERT INTO Address (address_id, street, city, state, zip_code, country)
SELECT 
    i,
    CONCAT(i, ' Main St'),                          -- Dynamic street name (e.g., "1 Main St")
    CASE WHEN i % 10 = 0 THEN 'New York' ELSE 'Los Angeles' END,  -- Alternate cities
    'CA',                                           -- Fixed state (California)
    CONCAT('900', LPAD(i % 1000, 3, '0')),          -- Dynamic zip code (e.g., 900001)
    'USA'                                           -- Fixed country
FROM information_schema.tables t1, information_schema.tables t2  -- Cross-join for row generation
LIMIT 1000;  -- Restrict to 1000 records

-- 8. Call the stored procedure to generate user data
CALL GenerateUserData();

-- 9. Optional: Restore safe update mode (recommended for production environments)
SET SQL_SAFE_UPDATES = 1;