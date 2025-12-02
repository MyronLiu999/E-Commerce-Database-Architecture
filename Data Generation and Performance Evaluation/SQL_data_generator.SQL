-- E-Commerce Database Data Generation Script
-- Combined and updated version following database_design.md specifications

-- 1. Create target database (if not exists) and switch to it
CREATE DATABASE IF NOT EXISTS Ecommerce;
USE Ecommerce;

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
DELIMITER //
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
        SET user_id_num = i;

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
DELIMITER //
CREATE PROCEDURE GenerateProductData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE price DECIMAL(10, 2);
    DECLARE category VARCHAR(100);
    -- Updated product categories to match design document examples
    SET @categories = 'fashion,headphone,vase,electronics,home,beauty,sports,books,toys,automotive';
    WHILE i <= 5000 DO -- Changed to 5000 as per requirements
        SET price = FLOOR(10 + RAND() * 9990) + RAND(); -- Random price (10-10000 currency units)
        -- Randomly select a category from the preset list
        SET category = SUBSTRING_INDEX(SUBSTRING_INDEX(@categories, ',', FLOOR(1 + RAND() * 10)), ',', -1);
        INSERT INTO Product (product_name, price, category)
        VALUES (
            CONCAT(UPPER(SUBSTRING(category, 1, 1)), SUBSTRING(category, 2), '_Product_', i, '_', SUBSTRING(MD5(RAND()), 1, 6)), -- Product name includes category
            price,
            category
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 10. Generate Inventory table (10000 records: link to Product with spec_id)
DELIMITER //
CREATE PROCEDURE GenerateInventoryData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE product_id INT;
    DECLARE spec_id VARCHAR(100);
    DECLARE quantity INT;
    DECLARE variant_idx INT;
    DECLARE variant_suffix VARCHAR(50);
    DECLARE attempts INT DEFAULT 0;
    DECLARE max_attempts INT DEFAULT 5;
    -- Variant suffixes for spec_id generation
    SET @variants = 'S_blue,M_red,L_black,XL_white,32GB,64GB,128GB,small,medium,large,ceramic,metal,plastic';
    
    WHILE i <= 10000 DO
        SET attempts = 0;
        spec_id_loop: LOOP
            SET product_id = FLOOR(1 + RAND() * 5000); -- Link to Product ID 1-5000
            -- Generate spec_id as product_id + variant + unique suffix
            SET variant_idx = FLOOR(1 + RAND() * 13);
            SET variant_suffix = SUBSTRING_INDEX(SUBSTRING_INDEX(@variants, ',', variant_idx), ',', -1);
            SET spec_id = CONCAT(product_id, '_', variant_suffix, '_', i); -- Add i for uniqueness
            SET quantity = FLOOR(RAND() * 1000); -- Random inventory quantity (0-999)
            
            -- Check if this spec_id already exists
            IF NOT EXISTS (SELECT 1 FROM Inventory WHERE spec_id = spec_id) THEN
                INSERT INTO Inventory (spec_id, product_id, quantity)
                VALUES (spec_id, product_id, quantity);
                LEAVE spec_id_loop;
            END IF;
            
            SET attempts = attempts + 1;
            IF attempts > max_attempts THEN
                -- Fallback: use guaranteed unique spec_id
                SET spec_id = CONCAT('SPEC_', i, '_', SUBSTRING(MD5(RAND()), 1, 8));
                INSERT INTO Inventory (spec_id, product_id, quantity)
                VALUES (spec_id, product_id, quantity);
                LEAVE spec_id_loop;
            END IF;
        END LOOP;
        
        SET i = i + 1;
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
    DECLARE session_id INT;
    DECLARE cart_id INT;
    WHILE i <= 100000 DO -- 100000 orders per requirements
        SET user_id = FLOOR(1 + RAND() * 1000); -- Randomly link to User ID 1-1000
        SET order_status = FLOOR(RAND() * 4); -- 0-Pending, 1-Paid, 2-Shipped, 3-Completed
        SET payment_id = i; -- One-to-one mapping with Payment table
        -- Generate unique session_id and cart_id using i for uniqueness
        SET session_id = 100000 + i; -- Sequential session IDs: 100001-200000
        SET cart_id = 1000 + (i % 99000); -- Cart IDs: 1000-100000, with some reuse for realistic scenario
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
    DECLARE method_name VARCHAR(100);
    DECLARE base_cost DECIMAL(10, 2);
    -- Updated shipping methods to match design
    SET @method_names = 'Standard,Overnight,Mid-tier,Express,Economy,Priority,Same Day,Two Day,Ground,Air';
    WHILE i <= 10 DO
        SET method_name = SUBSTRING_INDEX(SUBSTRING_INDEX(@method_names, ',', i), ',', -1);
        SET base_cost = FLOOR(5 + RAND() * 50) + RAND(); -- Random base cost (5-55)
        INSERT INTO ShippingMethod (method_name, base_cost)
        VALUES (method_name, base_cost);
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
        SET order_id = FLOOR(1 + RAND() * 100000); -- Randomly link to Order ID 1-100000
        INSERT INTO OrderProduct (product_id, quantity, shipping_id, order_product_subtotal, order_product_status, order_id)
        VALUES (product_id, quantity, shipping_id, subtotal, status, order_id);
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
        INSERT INTO `Return` (order_product_id, shipping_id, return_status, return_requested_time, exp_return_time, return_amount, return_fee)
        VALUES (order_product_id, shipping_id, status, request_time, expected_return, amount, return_fee);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 17. Execute all data generation procedures in dependency order
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
       'Generated: 1000 users, 5000 products, 10000 inventory records, 100000 orders, 150000 order items, 10000 returns' AS Summary;