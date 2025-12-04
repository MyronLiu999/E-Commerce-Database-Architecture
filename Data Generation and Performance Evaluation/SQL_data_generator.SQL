-- E-Commerce Database Data Generation Script
-- Combined and updated version following database_design.md specifications

-- 1. Create target database (if not exists) and switch to it
DROP DATABASE IF EXISTS Ecommerce;
CREATE DATABASE Ecommerce;
USE Ecommerce;

-- ====================================================================
-- TABLE CREATION SECTION - Based on Current Database Design
-- ====================================================================

-- Country Table
CREATE TABLE Country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- State Table
CREATE TABLE State (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    tax_rate DECIMAL(6, 4) NOT NULL COMMENT 'Tax rate as decimal (0.1234 = 12.34%)',
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- City Table
CREATE TABLE City (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state_id INT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES State(state_id)
);

-- Address Table
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    address_type VARCHAR(50) NOT NULL COMMENT 'Shipping/Billing',
    zip_code VARCHAR(20),
    city_id INT NOT NULL,
    street_line TEXT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

-- User Table
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    password_hash VARCHAR(50) NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- Product Table
CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100) NOT NULL
);

-- Inventory Table
CREATE TABLE Inventory (
    spec_id VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL COMMENT 'Available stock quantity of the specific product specification',
    PRIMARY KEY (spec_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
) COMMENT='Product inventory management table - tracks stock levels per product specification';

-- Payment Table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_status TINYINT NOT NULL COMMENT '0-Unpaid/1-Paid',
    payment_method VARCHAR(50) NOT NULL COMMENT 'Credit Card/Bank Account/PayPal',
    amount DECIMAL(10, 2) NOT NULL,
    payment_timestamp DATETIME NOT NULL
);

-- Order Table (Updated with session_id and cart_id)
CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_status TINYINT NOT NULL COMMENT '0-Pending/1-Paid/2-Shipped/3-Completed',
    payment_id INT NOT NULL,
    check_out_timestamp DATETIME NOT NULL,
    session_id VARCHAR(100) COMMENT 'Session ID for conversion analysis',
    cart_id INT COMMENT 'Cart ID for conversion analysis',
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id)
);

-- Shipping Method Table
CREATE TABLE ShippingMethod (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL COMMENT 'Standard/Overnight/Mid-tier/Express/Economy/Priority/Same Day/Two Day/Ground/Air',
    base_cost DECIMAL(10, 2) NOT NULL
);

-- Shipping Table
CREATE TABLE Shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    shipping_method_id INT NOT NULL,
    address_id INT NOT NULL,
    delivery_timestamp DATETIME NOT NULL,
    FOREIGN KEY (shipping_method_id) REFERENCES ShippingMethod(shipping_method_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- Order Product Table
CREATE TABLE OrderProduct (
    order_product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    shipping_id INT NOT NULL,
    order_product_subtotal DECIMAL(10, 2) NOT NULL COMMENT 'Product amount + shipping fee + tax',
    order_product_status TINYINT NOT NULL COMMENT '0-Shipped/1-Completed',
    order_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);

-- Return Table
CREATE TABLE `Return` (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_product_id INT NOT NULL,
    shipping_id INT NOT NULL,
    return_status TINYINT NOT NULL COMMENT '0-Applied/1-Approved/2-Rejected/3-Closed',
    return_requested_time DATETIME NOT NULL,
    exp_return_time DATETIME,
    return_amount DECIMAL(10, 2) NOT NULL,
    return_fee DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_product_id) REFERENCES OrderProduct(order_product_id),
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id)
);

SELECT 'All tables created successfully!' AS Status;

-- ====================================================================
-- DATA GENERATION SECTION
-- ====================================================================

-- 2. Disable safe update mode for batch operations
SET SQL_SAFE_UPDATES = 0;

-- 3. Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS GenerateCountryData;
DROP PROCEDURE IF EXISTS GenerateStateData;
DROP PROCEDURE IF EXISTS GenerateCityData;
DROP PROCEDURE IF EXISTS GenerateAddressData;
DROP PROCEDURE IF EXISTS GenerateUserData;
DROP PROCEDURE IF EXISTS GenerateProductData;
DROP PROCEDURE IF EXISTS GenerateInventoryData;
DROP PROCEDURE IF EXISTS GeneratePaymentData;
DROP PROCEDURE IF EXISTS GenerateOrderData;
DROP PROCEDURE IF EXISTS GenerateShippingMethodData;
DROP PROCEDURE IF EXISTS GenerateShippingData;
DROP PROCEDURE IF EXISTS GenerateOrderProductData;
DROP PROCEDURE IF EXISTS GenerateReturnData;
DROP PROCEDURE IF EXISTS GenerateRefundData;


-- 4. Generate Country table (100 records: 10 states per country for 1000 total states)
-- generated by AI ChatGPT
DELIMITER //
CREATE PROCEDURE GenerateCountryData()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100 DO
        INSERT INTO Country (country_name)
        VALUES (CONCAT('Country_', i, '_', SUBSTRING(MD5(RAND()), 1, 10))) -- Random suffix to avoid duplicates
        ON DUPLICATE KEY UPDATE country_name = country_name; -- Skip duplicates
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
SHOW PROCEDURE STATUS WHERE Db = 'Ecommerce' AND Name = 'GenerateCountryData';
select * from Country;


-- 5. Generate State table (1000 records: 10 states per country)
DELIMITER //
CREATE PROCEDURE GenerateStateData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE country_id INT;
    WHILE i <= 1000 DO
        SET country_id = FLOOR(1 + RAND() * 100); -- Randomly link to Country ID 1-100
        INSERT INTO State (state_name, country_id, tax_rate)
        VALUES (CONCAT('State_', i, '_', SUBSTRING(MD5(RAND()), 1, 8)), country_id, ROUND(RAND() * 0.15, 4))
        ON DUPLICATE KEY UPDATE state_name = state_name; -- Skip duplicates
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 6. Generate City table (1000 records: randomly link to State ID 1-1000)
CREATE DATABASE IF NOT EXISTS Ecommerce;DROP PROCEDURE IF EXISTS GenerateCityData;DELIMITER //
CREATE PROCEDURE GenerateCityData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE state_id INT;
    WHILE i <= 1000 DO
        SET state_id = FLOOR(1 + RAND() * 1000); -- Randomly link to State ID 1-1000
        INSERT INTO City (city_name, state_id)
        VALUES (CONCAT('City_', i, '_', SUBSTRING(MD5(RAND()), 1, 8)), state_id)
        ON DUPLICATE KEY UPDATE city_name = city_name; -- Skip duplicates
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 7. Generate Address table (1000 records: link to City)
-- Generated by AI
DELIMITER //
CREATE PROCEDURE GenerateAddressData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE city_id INT;
    DECLARE address_type VARCHAR(50);
    DECLARE zip_code VARCHAR(20);
    WHILE i <= 1000 DO
        SET city_id = FLOOR(1 + RAND() * 1000); -- Randomly link to City ID 1-1000
        SET address_type = IF(RAND() > 0.5, 'Shipping', 'Billing'); -- Random address type
        SET zip_code = CONCAT(LPAD(FLOOR(10000 + RAND() * 89999), 5, '0')); -- Random 5-digit zip code
        INSERT INTO Address (address_type, zip_code, city_id, street_line)
        VALUES (
            address_type,
            zip_code,
            city_id,
            CONCAT(FLOOR(1 + RAND() * 9999), ' ', 
                   ELT(FLOOR(1 + RAND() * 10), 'Main', 'Oak', 'Pine', 'Maple', 'Cedar', 'Elm', 'Park', 'First', 'Second', 'Third'),
                   ' ',
                   ELT(FLOOR(1 + RAND() * 5), 'St', 'Ave', 'Blvd', 'Dr', 'Ln'))
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 8. Generate User table (1000 records with unique emails and proper foreign keys)
-- Generated by AI
DELIMITER //
CREATE PROCEDURE GenerateUserData()
BEGIN
    -- Declare variables for loop control and data generation
    DECLARE i INT DEFAULT 1;                  -- Loop counter (1 to 1000)
    DECLARE first_name_idx INT;               -- Random index for first name selection
    DECLARE last_name_idx INT;                -- Random index for last name selection
    DECLARE user_id_num INT;                  -- Generated user_id number
    DECLARE first_name VARCHAR(100);          -- Randomly selected first name
    DECLARE last_name VARCHAR(100);           -- Randomly selected last name
    DECLARE email VARCHAR(255);               -- Unique email address
    DECLARE phone_number VARCHAR(20);         -- Formatted phone number
    DECLARE password_hash VARCHAR(50);        -- Encrypted password hash
    DECLARE address_id INT;                   -- Mapped address ID (1-1000)

    -- List of common English first names (extendable for more variety)
    DECLARE first_names VARCHAR(1000) DEFAULT 'Emma,Liam,Olivia,Noah,Ava,Ethan,Sophia,Lucas,Mia,James,Amelia,Oliver,Charlotte,Elijah,Aria,William,Isabella,Benjamin,Harper,Evelyn,Alexander,Chloe,Owen,Zoey,Elias,Luna,Axel,Ella,Amelia';
    -- List of common English last names (extendable for more variety)
    DECLARE last_names VARCHAR(1000) DEFAULT 'Wilson,Johnson,Smith,Brown,Jones,Garcia,Martinez,Rodriguez,Taylor,Davis,Hernandez,Moore,Martin,Jackson,Thompson,White,Harris,Thomas,Williams,Clark';

    -- Loop to generate 1000 user records (i = 1 → User ID 1; i = 1000 → User ID 1000)
    WHILE i <= 1000 DO
        -- Generate user_id number
        SET user_id_num = 1000 + i;

        -- Calculate random index for first name (based on number of commas in first_names)
        SET first_name_idx = FLOOR(1 + RAND() * (LENGTH(first_names) - LENGTH(REPLACE(first_names, ',', ''))));
        -- Extract random first name using SUBSTRING_INDEX (splits by commas)
        SET first_name = SUBSTRING_INDEX(SUBSTRING_INDEX(first_names, ',', first_name_idx), ',', -1);

        -- Same logic for random last name selection
        SET last_name_idx = FLOOR(1 + RAND() * (LENGTH(last_names) - LENGTH(REPLACE(last_names, ',', ''))));
        SET last_name = SUBSTRING_INDEX(SUBSTRING_INDEX(last_names, ',', last_name_idx), ',', -1);

        -- Generate unique email: firstname.lastname+user_id_suffix@example.com
        SET email = CONCAT(LOWER(first_name), '.', LOWER(last_name), user_id_num, '@example.com');

        -- Generate phone number in +1-XXX-XXX-XXXX format
        SET phone_number = CONCAT('+1-', 
                                  LPAD(FLOOR(200 + RAND() * 799), 3, '0'), '-',
                                  LPAD(FLOOR(200 + RAND() * 799), 3, '0'), '-',
                                  LPAD(FLOOR(1000 + RAND() * 8999), 4, '0'));

        -- Generate password hash using SHA1 (40-bit alphanumeric string)
        SET password_hash = SHA1(CONCAT(RAND(), UUID()));

        -- Map address_id to loop counter (1-1000, matches Address table's address_id)
        SET address_id = i;

        -- Insert generated data into the User table
        INSERT INTO User (
            user_id, email, first_name, last_name, phone_number, password_hash, address_id
        ) VALUES (
            user_id_num, email, first_name, last_name, phone_number, password_hash, address_id
        );

        -- Increment loop counter to generate next record
        SET i = i + 1;
    END WHILE;

    -- Return success message after loop completes
    SELECT '1000 user records generated successfully!' AS result;
END //
DELIMITER ;

-- 9. Generate Product table (5000 records with random categories and prices per requirements)
-- Generated By AI
DELIMITER //
-- - Fixed category-product ID mapping (500 IDs per category)
-- - Category-specific price ranges (more realistic than uniform random)
-- - Product names include category + unique identifier
CREATE PROCEDURE GenerateProductData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE price DECIMAL(10, 2);
    DECLARE category VARCHAR(100);
    
    WHILE i <= 5000 DO
        -- ==============================================
        -- 1. Bind product ID to fixed category (500 IDs per category)
        -- ==============================================
        IF i BETWEEN 1 AND 500 THEN
            SET category = 'fashion';
            -- Price range: 10 - 500 (currency units, fits fashion products)
            SET price = ROUND(10 + RAND() * 490, 2);
        ELSEIF i BETWEEN 501 AND 1000 THEN
            SET category = 'headphone';
            -- Price range: 50 - 2000 (higher for electronic audio devices)
            SET price = ROUND(50 + RAND() * 1950, 2);
        ELSEIF i BETWEEN 1001 AND 1500 THEN
            SET category = 'vase';
            -- Price range: 20 - 800 (home decor, varies by material)
            SET price = ROUND(20 + RAND() * 780, 2);
        ELSEIF i BETWEEN 1501 AND 2000 THEN
            SET category = 'electronics';
            -- Price range: 100 - 10000 (smartphones/tablets, high value)
            SET price = ROUND(100 + RAND() * 9900, 2);
        ELSEIF i BETWEEN 2001 AND 2500 THEN
            SET category = 'home';
            -- Price range: 30 - 1500 (furniture/bedding, mid to high value)
            SET price = ROUND(30 + RAND() * 1470, 2);
        ELSEIF i BETWEEN 2501 AND 3000 THEN
            SET category = 'beauty';
            -- Price range: 5 - 300 (cosmetics/serums, low to mid value)
            SET price = ROUND(5 + RAND() * 295, 2);
        ELSEIF i BETWEEN 3001 AND 3500 THEN
            SET category = 'sports';
            -- Price range: 40 - 1200 (athletic gear/shoes)
            SET price = ROUND(40 + RAND() * 1160, 2);
        ELSEIF i BETWEEN 3501 AND 4000 THEN
            SET category = 'books';
            -- Price range: 8 - 150 (books/audiobooks, low value)
            SET price = ROUND(8 + RAND() * 142, 2);
        ELSEIF i BETWEEN 4001 AND 4500 THEN
            SET category = 'toys';
            -- Price range: 15 - 500 (building blocks/plush toys)
            SET price = ROUND(15 + RAND() * 485, 2);
        ELSEIF i BETWEEN 4501 AND 5000 THEN
            SET category = 'automotive';
            -- Price range: 20 - 1800 (car parts/accessories)
            SET price = ROUND(20 + RAND() * 1780, 2);
        END IF;

        -- ==============================================
        -- 2. Insert product record (consistent name format)
        -- ==============================================
        INSERT INTO Product (product_name, price, category)
        VALUES (
            -- Format: "Category_Product_ID_Random6Chars" (e.g., "Fashion_Product_1_7a3f9d")
            CONCAT(UPPER(SUBSTRING(category, 1, 1)), SUBSTRING(category, 2), '_Product_', i, '_', SUBSTRING(MD5(RAND()), 1, 6)),
            price,
            category
        );

        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;


-- 10. Stored procedure to generate 10000 Inventory records (matches table structure: spec_id, product_id, quantity)
-- Generated by AI
DELIMITER //
CREATE PROCEDURE GenerateInventoryData()
BEGIN
    -- All variable declarations must be placed at the top (MySQL stored procedure syntax requirement)
    DECLARE spec_id VARCHAR(100);
    DECLARE current_pid INT;
    DECLARE variant_suffix VARCHAR(50);
    DECLARE category_ranges JSON DEFAULT '[{"name":"Fashion","start":1,"end":500},{"name":"Headphone","start":501,"end":1000},{"name":"Vase","start":1001,"end":1500},{"name":"Electronics","start":1501,"end":2000},{"name":"Home","start":2001,"end":2500},{"name":"Beauty","start":2501,"end":3000},{"name":"Sports","start":3001,"end":3500},{"name":"Books","start":3501,"end":4000},{"name":"Toys","start":4001,"end":4500},{"name":"Automotive","start":4501,"end":5000}]';
    DECLARE i INT DEFAULT 0;
    DECLARE cat_start INT;
    DECLARE cat_end INT;

    -- ==============================================
    -- 1. Insert existing spec records (fixed known specifications)
    -- ==============================================
    INSERT IGNORE INTO Inventory (spec_id, product_id, quantity)
    VALUES
    -- Fashion products (1-500) with blue colors and large sizes for Query 4
    ('1_XS_pink', 1, FLOOR(RAND()*1000)),
    ('1_M_white', 1, FLOOR(RAND()*1000)),
    ('1_L_blue', 1, FLOOR(RAND()*1000)),         -- Large + blue for Query 4
    ('1_XL_black', 1, FLOOR(RAND()*1000)),
    ('2_L_denim', 2, FLOOR(RAND()*1000)),        -- Large for Query 4
    ('2_XXL_black', 2, FLOOR(RAND()*1000)),
    ('2_M_blue', 2, FLOOR(RAND()*1000)),         -- Blue for Query 4
    ('3_S_red', 3, FLOOR(RAND()*1000)),
    ('3_L_blue', 3, FLOOR(RAND()*1000)),         -- Large + blue for Query 4
    ('3_M_green', 3, FLOOR(RAND()*1000)),
    ('4_XS_white', 4, FLOOR(RAND()*1000)),
    ('4_Large_blue', 4, FLOOR(RAND()*1000)),     -- Large + blue for Query 4
    ('5_M_navy', 5, FLOOR(RAND()*1000)),
    ('5_L_cotton', 5, FLOOR(RAND()*1000)),       -- Large for Query 4
    ('6_S_blue', 6, FLOOR(RAND()*1000)),         -- Blue for Query 4
    ('6_XL_polyester', 6, FLOOR(RAND()*1000)),
    ('7_L_silk', 7, FLOOR(RAND()*1000)),         -- Large for Query 4
    ('7_M_blue', 7, FLOOR(RAND()*1000)),         -- Blue for Query 4
    ('8_S_wool', 8, FLOOR(RAND()*1000)),
    ('8_large_blue', 8, FLOOR(RAND()*1000)),     -- Large + blue for Query 4
    ('9_XS_linen', 9, FLOOR(RAND()*1000)),
    ('9_L_cashmere', 9, FLOOR(RAND()*1000)),     -- Large for Query 4
    ('10_M_denim', 10, FLOOR(RAND()*1000)),
    ('10_L_blue', 10, FLOOR(RAND()*1000)),       -- Large + blue for Query 4
    -- More fashion products with various blue shades and large sizes
    ('15_L_royal_blue', 15, FLOOR(RAND()*1000)),     -- Large + blue for Query 4
    ('20_XL_sky_blue', 20, FLOOR(RAND()*1000)),      -- Large + blue for Query 4
    ('25_L_navy_blue', 25, FLOOR(RAND()*1000)),      -- Large + blue for Query 4
    ('30_Large_powder_blue', 30, FLOOR(RAND()*1000)),-- Large + blue for Query 4
    ('35_L_denim_blue', 35, FLOOR(RAND()*1000)),     -- Large + blue for Query 4
    ('40_XL_blue', 40, FLOOR(RAND()*1000)),          -- Large + blue for Query 4
    ('45_L_cobalt_blue', 45, FLOOR(RAND()*1000)),    -- Large + blue for Query 4
    ('50_large_steel_blue', 50, FLOOR(RAND()*1000)), -- Large + blue for Query 4
    
    -- Other category products (keeping existing ones)
    ('501_ANC_black', 501, FLOOR(RAND()*1000)),
    ('501_ANC_white', 501, FLOOR(RAND()*1000)),
    ('502_wired_silver', 502, FLOOR(RAND()*1000)),
    ('502_wired_black', 502, FLOOR(RAND()*1000)),
    ('1001_ceramic_round', 1001, FLOOR(RAND()*1000)),
    ('1001_ceramic_tall', 1001, FLOOR(RAND()*1000)),
    ('1002_glass_amber', 1002, FLOOR(RAND()*1000)),
    ('1002_glass_green', 1002, FLOOR(RAND()*1000)),
    ('1501_256GB_black', 1501, FLOOR(RAND()*1000)),
    ('1501_512GB_white', 1501, FLOOR(RAND()*1000)),
    ('1502_128GB_gray', 1502, FLOOR(RAND()*1000)),
    ('1502_256GB_silver', 1502, FLOOR(RAND()*1000)),
    ('2001_oak_natural', 2001, FLOOR(RAND()*1000)),
    ('2001_walnut_brown', 2001, FLOOR(RAND()*1000)),
    ('2002_queen_blue', 2002, FLOOR(RAND()*1000)),
    ('2002_king_white', 2002, FLOOR(RAND()*1000)),
    ('2501_30ml_all', 2501, FLOOR(RAND()*1000)),
    ('2501_50ml_sensitive', 2501, FLOOR(RAND()*1000)),
    ('2502_red_matte', 2502, FLOOR(RAND()*1000)),
    ('2502_nude_matte', 2502, FLOOR(RAND()*1000)),
    ('3001_men_9_black', 3001, FLOOR(RAND()*1000)),
    ('3001_women_7_pink', 3001, FLOOR(RAND()*1000)),
    ('3002_6mm_blue', 3002, FLOOR(RAND()*1000)),
    ('3002_8mm_green', 3002, FLOOR(RAND()*1000)),
    ('3501_hardcover_fiction', 3501, FLOOR(RAND()*1000)),
    ('3501_paperback_fiction', 3501, FLOOR(RAND()*1000)),
    ('3502_audiobook_business', 3502, FLOOR(RAND()*1000)),
    ('3502_ebook_business', 3502, FLOOR(RAND()*1000)),
    ('4001_500pcs_6+', 4001, FLOOR(RAND()*1000)),
    ('4001_1000pcs_8+', 4001, FLOOR(RAND()*1000)),
    ('4002_plush_dog', 4002, FLOOR(RAND()*1000)),
    ('4002_plush_cat', 4002, FLOOR(RAND()*1000)),
    ('4501_filter_petrol', 4501, FLOOR(RAND()*1000)),
    ('4501_filter_diesel', 4501, FLOOR(RAND()*1000)),
    ('4502_mount_vent', 4502, FLOOR(RAND()*1000)),
    ('4502_mount_dashboard', 4502, FLOOR(RAND()*1000));

    -- ==============================================
    -- 2. Generate remaining records (fill up to 10000 total)
    -- ==============================================
    OUTER_LOOP: WHILE i < 10 DO
        -- Convert JSON-extracted values to integers to avoid type exceptions
        SET cat_start = CAST(JSON_UNQUOTE(JSON_EXTRACT(category_ranges, CONCAT('$[',i,'].start'))) AS UNSIGNED);
        SET cat_end = CAST(JSON_UNQUOTE(JSON_EXTRACT(category_ranges, CONCAT('$[',i,'].end'))) AS UNSIGNED);
        SET current_pid = cat_start;

        INNER_LOOP: WHILE current_pid <= cat_end DO
            -- Skip products with existing records
            IF NOT EXISTS (SELECT 1 FROM Inventory WHERE product_id = current_pid) THEN
                -- Generate 1st spec_id (avoid duplication)
                SET variant_suffix = ELT(FLOOR(1+RAND()*10), 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');
                SET spec_id = CONCAT(current_pid, '_', variant_suffix, '_', FLOOR(RAND()*100));
                INSERT IGNORE INTO Inventory (spec_id, product_id, quantity)
                VALUES (spec_id, current_pid, FLOOR(RAND()*1000));

                -- Generate 2nd spec_id (different random number range to reduce duplication)
                SET variant_suffix = ELT(FLOOR(1+RAND()*10), 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');
                SET spec_id = CONCAT(current_pid, '_', variant_suffix, '_', FLOOR(RAND()*100 + 100));
                INSERT IGNORE INTO Inventory (spec_id, product_id, quantity)
                VALUES (spec_id, current_pid, FLOOR(RAND()*1000));
            END IF;

            SET current_pid = current_pid + 1;
            -- Exit all loops if 10000 records are reached
            IF (SELECT COUNT(*) FROM Inventory) >= 10000 THEN
                LEAVE OUTER_LOOP;
            END IF;
        END WHILE INNER_LOOP;

        SET i = i + 1;
        IF (SELECT COUNT(*) FROM Inventory) >= 10000 THEN
            LEAVE OUTER_LOOP;
        END IF;
    END WHILE OUTER_LOOP;

    -- ==============================================
    -- 3. Final fill: ensure exactly 10000 records
    -- ==============================================
    WHILE (SELECT COUNT(*) FROM Inventory) < 10000 DO
        SET i = FLOOR(0+RAND()*10);
        SET cat_start = CAST(JSON_UNQUOTE(JSON_EXTRACT(category_ranges, CONCAT('$[',i,'].start'))) AS UNSIGNED);
        SET cat_end = CAST(JSON_UNQUOTE(JSON_EXTRACT(category_ranges, CONCAT('$[',i,'].end'))) AS UNSIGNED);
        SET current_pid = FLOOR(cat_start + RAND()*(cat_end - cat_start));
        
        -- Generate highly unique spec_id
        SET variant_suffix = ELT(FLOOR(1+RAND()*20), 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T');
        SET spec_id = CONCAT(current_pid, '_', variant_suffix, '_', FLOOR(RAND()*1000));
        INSERT IGNORE INTO Inventory (spec_id, product_id, quantity)
        VALUES (spec_id, current_pid, FLOOR(RAND()*1000));
    END WHILE;
END //
DELIMITER ;

-- 11. Generate Payment table (100000 records per requirements)
DELIMITER //
CREATE PROCEDURE GeneratePaymentData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE status TINYINT;
    DECLARE method VARCHAR(50);
    DECLARE amount DECIMAL(10, 2);
    DECLARE payment_time DATETIME;
    -- Updated payment methods to match design
    SET @methods = 'Credit Card,Bank Account,PayPal';
    WHILE i <= 100000 DO -- Changed to 100000 for order requirements
        SET status = IF(RAND() > 0.1, 1, 0); -- 90% paid, 10% unpaid
        -- Randomly select a payment method
        SET method = SUBSTRING_INDEX(SUBSTRING_INDEX(@methods, ',', FLOOR(1 + RAND() * 3)), ',', -1);
        SET amount = FLOOR(50 + RAND() * 9950) + RAND(); -- Random payment amount (50-10000)
        -- Random payment timestamp (within last 1 year)
        SET payment_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY);
        INSERT INTO Payment (payment_status, payment_method, amount, payment_timestamp)
        VALUES (status, method, amount, payment_time);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 12. Generate Order table (100000 records: link to User and Payment, add session_id and cart_id)
DELIMITER //
CREATE PROCEDURE GenerateOrderData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE user_id INT;
    DECLARE order_status TINYINT;
    DECLARE payment_id INT;
    DECLARE check_out_time DATETIME;
    DECLARE session_id VARCHAR(100);
    DECLARE cart_id INT;
    WHILE i <= 100000 DO -- 100000 orders per requirements
        SET user_id = FLOOR(1 + RAND() * 1000) + 1000; -- Randomly link to User ID 1000-2000
        SET order_status = FLOOR(RAND() * 4); -- 0-Pending, 1-Paid, 2-Shipped, 3-Completed
        SET payment_id = i; -- One-to-one mapping with Payment table
        -- Generate session_id for conversion analysis
        SET session_id = CONCAT('sess_', LPAD(i, 8, '0'), '_', SUBSTRING(MD5(RAND()), 1, 8));
        -- Generate cart_id for conversion analysis
        SET cart_id = FLOOR(10000 + RAND() * 90000); -- Random cart ID (10000-99999)
        -- Order timestamp ≤ Payment timestamp (logical consistency)
        SET check_out_time = DATE_SUB((SELECT payment_timestamp FROM Payment WHERE payment_id = i LIMIT 1), INTERVAL FLOOR(RAND() * 24) HOUR);
        INSERT INTO `Order` (user_id, order_status, payment_id, check_out_timestamp, session_id, cart_id)
        VALUES (user_id, order_status, payment_id, check_out_time, session_id, cart_id);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 12. Generate ShippingMethod table (10 records: sufficient for shipping needs)
DELIMITER //
CREATE PROCEDURE GenerateShippingMethodData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE shipping_method_id INT;
    DECLARE method_name VARCHAR(100);
    DECLARE base_cost DECIMAL(10, 2);
    -- Updated shipping methods to match design
    SET @method_names = 'Standard,Overnight,Mid-tier,Express,Economy,Priority,Same Day,Two Day,Ground,Air';
    WHILE i <= 10 DO
        SET method_name = SUBSTRING_INDEX(SUBSTRING_INDEX(@method_names, ',', i), ',', -1);
        SET base_cost = FLOOR(5 + RAND() * 50) + RAND(); -- Random base cost (5-55)
        SET shipping_method_id = i;
        INSERT INTO ShippingMethod (shipping_method_id, method_name, base_cost)
        VALUES (shipping_method_id, method_name, base_cost);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 13. Generate Shipping table (100000 records: link to ShippingMethod and Address)
DELIMITER //
CREATE PROCEDURE GenerateShippingData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE method_id INT;
    DECLARE address_id INT;
    DECLARE delivery_time DATETIME;
    WHILE i <= 100000 DO
        SET method_id = FLOOR(1 + RAND() * 10); -- Randomly link to ShippingMethod ID 1-10
        SET address_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Address ID 1-1000
        -- Delivery time is order time + 1-14 days
        SET delivery_time = DATE_ADD(NOW(), INTERVAL FLOOR(1 + RAND() * 14) DAY);
        INSERT INTO Shipping (shipping_method_id, address_id, delivery_timestamp)
        VALUES (method_id, address_id, delivery_time);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 14. Generate OrderProduct table (150000 records: link to Order, Product, and Shipping)
DROP PROCEDURE IF EXISTS GenerateOrderProductData;
DELIMITER //
CREATE PROCEDURE GenerateOrderProductData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE product_id INT;
    DECLARE quantity INT;
    DECLARE shipping_id INT;
    DECLARE subtotal DECIMAL(10, 2);
    DECLARE status TINYINT;
    DECLARE order_id INT;
    WHILE i <= 150000 DO -- More order products than orders (some orders have multiple items)
        SET product_id = FLOOR(1 + RAND() * 5000); -- Randomly link to Product ID 1-5000
        SET quantity = FLOOR(1 + RAND() * 5); -- Random order quantity (1-5 units)
        SET shipping_id = FLOOR(1 + RAND() * 100000); -- Randomly link to Shipping ID 1-100000
        SET subtotal = FLOOR(50 + RAND() * 500) + RAND(); -- Random subtotal (includes tax+shipping)
        SET status = IF(RAND() > 0.3, 0, 1); -- 70% shipped, 30% completed
        SET order_id = CAST(i*2/3 AS UNSIGNED INT); -- Randomly link to Order ID 1-100000
        INSERT INTO OrderProduct (order_product_id, product_id, quantity, shipping_id, order_product_subtotal, order_product_status, order_id)
        VALUES (i, product_id, quantity, shipping_id, subtotal, status, order_id);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 16. Generate Return table (10000 records: link to OrderProduct, add return_fee)
DELIMITER //
CREATE PROCEDURE GenerateReturnData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE order_product_id INT;
    DECLARE shipping_id INT;
    DECLARE status TINYINT;
    DECLARE request_time DATETIME;
    DECLARE expected_return DATETIME;
    DECLARE amount DECIMAL(10, 2);
    DECLARE return_fee DECIMAL(10, 2);
    WHILE i <= 10000 DO -- ~7% return rate
        SET order_product_id = FLOOR(1 + RAND() * 150000); -- Randomly link to OrderProduct ID 1-150000
        SET shipping_id = FLOOR(1 + RAND() * 100000); -- Randomly link to Shipping ID 1-100000
        SET status = FLOOR(RAND() * 4); -- 0-Applied, 1-Approved, 2-Rejected, 3-Closed
        -- Random return request timestamp (within last 30 days)
        SET request_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY);
        -- Expected return time 5-14 days after request
        SET expected_return = DATE_ADD(request_time, INTERVAL FLOOR(5 + RAND() * 10) DAY);
        SET amount = FLOOR(20 + RAND() * 480) + RAND(); -- Random return amount
        SET return_fee = FLOOR(5 + RAND() * 25) + RAND(); -- Random return fee (5-30)
        INSERT INTO `Return` (return_id, order_product_id, shipping_id, return_status, return_requested_time, exp_return_time, return_amount, return_fee)
        VALUES (i, order_product_id, shipping_id, status, request_time, expected_return, amount, return_fee);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 17. Execute all data generation procedures in dependency order
DELIMITER ;
USE Ecommerce
CALL GenerateCountryData();
CALL GenerateStateData();
CALL GenerateCityData();
CALL GenerateAddressData();
CALL GenerateUserData();
CALL GenerateProductData();
CALL GenerateInventoryData();
CALL GeneratePaymentData();
CALL GenerateOrderData();
CALL GenerateShippingMethodData();
CALL GenerateShippingData();
CALL GenerateOrderProductData();
CALL GenerateReturnData();

-- 18. Restore safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Display completion message
SELECT 'All data generation completed successfully!' AS Status,
       'Generated: 1000 users, 5000 products, 10000 inventory records, 100000 orders with session/cart tracking, 150000 order items, 10000 returns' AS Summary;

-- Insert Sarah (sample user)
USE Ecommerce;
INSERT INTO User (user_id, email, first_name, last_name, phone_number, password_hash, address_id)
VALUES (
  1000,
  'sarah.han1022@example.com',
  'Sarah',
  'han',
  '+1-202-555-1234',
  '7a2f9d4e6b1c8f3a7d2e5c9b0a4f1e3d',
  1
);