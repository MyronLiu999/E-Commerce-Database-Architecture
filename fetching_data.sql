-- Generate Country table (100 records: 10 states per country for 1000 total states)
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

-- Generate State table (1000 records: 10 states per country)
DELIMITER //
CREATE PROCEDURE GenerateStateData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE country_id INT;
    WHILE i <= 1000 DO
        SET country_id = FLOOR(1 + RAND() * 100); -- Randomly link to Country ID 1-100
        INSERT INTO State (state_name, country_id)
        VALUES (CONCAT('State_', i, '_', SUBSTRING(MD5(RAND()), 1, 8)), country_id)
        ON DUPLICATE KEY UPDATE state_name = state_name; -- Skip duplicates
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate City table (1000 records: randomly link to State ID 1-1000)
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

-- Generate User table (1000 records with unique emails)
DELIMITER //
CREATE PROCEDURE GenerateUserData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE phone VARCHAR(20);
    WHILE i <= 1000 DO
        -- Generate random 11-digit phone number
        SET phone = CONCAT('1', FLOOR(3000000000 + RAND() * 6999999999));
        INSERT INTO User (email, first_name, last_name, phone_number)
        VALUES (
            CONCAT('user_', i, '_', SUBSTRING(MD5(RAND()), 1, 8), '@example.com'), -- Unique email
            CONCAT('First_', SUBSTRING(MD5(RAND()), 1, 4)),
            CONCAT('Last_', SUBSTRING(MD5(RAND()), 1, 4)),
            phone
        ) ON DUPLICATE KEY UPDATE email = email; -- Skip duplicates
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Address table (1000 records: link to User and City)
DELIMITER //
CREATE PROCEDURE GenerateAddressData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE user_id INT;
    DECLARE city_id INT;
    DECLARE address_type VARCHAR(50);
    DECLARE zip_code VARCHAR(20);
    WHILE i <= 1000 DO
        SET user_id = FLOOR(1 + RAND() * 1000); -- Randomly link to User ID 1-1000
        SET city_id = FLOOR(1 + RAND() * 1000); -- Randomly link to City ID 1-1000
        SET address_type = IF(RAND() > 0.5, 'Shipping Address', 'Billing Address'); -- Random address type
        SET zip_code = CONCAT(FLOOR(100000 + RAND() * 899999)); -- Random 6-digit zip code
        INSERT INTO Address (user_id, address_type, zip_code, city_id, street_line)
        VALUES (
            user_id,
            address_type,
            zip_code,
            city_id,
            CONCAT('Street_', i, ', ', (SELECT city_name FROM City WHERE city_id = city_id LIMIT 1), ', ', SUBSTRING(MD5(RAND()), 1, 10))
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Product table (1000 records with random categories and prices)
DELIMITER //
CREATE PROCEDURE GenerateProductData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE price DECIMAL(10, 2);
    DECLARE category VARCHAR(100);
    -- Preset English product categories (randomly selected)
    SET @categories = 'Mobile Phones,Laptops,Home Appliances,Clothing,Food,Books,Cosmetics,Household Items,Sports Equipment,Digital Accessories';
    WHILE i <= 1000 DO
        SET price = FLOOR(10 + RAND() * 9990) + RAND(); -- Random price (10-10000 currency units)
        -- Randomly select a category from the preset list
        SET category = SUBSTRING_INDEX(SUBSTRING_INDEX(@categories, ',', FLOOR(1 + RAND() * 10)), ',', -1);
        INSERT INTO Product (name, price, category)
        VALUES (
            CONCAT(category, '_Product_', i, '_', SUBSTRING(MD5(RAND()), 1, 6)), -- Product name includes category
            price,
            category
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Inventory table (1000 records: link to Product and Address)
DELIMITER //
CREATE PROCEDURE GenerateInventoryData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE product_id INT;
    DECLARE address_id INT;
    DECLARE quantity INT;
    WHILE i <= 1000 DO
        SET product_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Product ID 1-1000
        SET address_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Address ID 1-1000 (warehouse)
        SET quantity = FLOOR(0 + RAND() * 1000); -- Random stock quantity (0-1000 units)
        INSERT INTO Inventory (product_id, quantity_available, address_id)
        VALUES (product_id, quantity, address_id)
        ON DUPLICATE KEY UPDATE quantity_available = quantity; -- Update quantity if duplicate
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Payment table (1000 records with random payment methods/statuses)
DELIMITER //
CREATE PROCEDURE GeneratePaymentData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE status TINYINT;
    DECLARE method VARCHAR(50);
    DECLARE amount DECIMAL(10, 2);
    DECLARE payment_time DATETIME;
    -- Preset English payment methods
    SET @methods = 'Card,PayPal,App Pay';
    WHILE i <= 1000 DO
        SET status = FLOOR(RAND() * 2); -- 0-Unpaid, 1-Paid (random)
        -- Randomly select a payment method
        SET method = SUBSTRING_INDEX(SUBSTRING_INDEX(@methods, ',', FLOOR(1 + RAND() * 3)), ',', -1);
        SET amount = FLOOR(50 + RAND() * 9950) + RAND(); -- Random payment amount (50-10000 currency units)
        -- Random payment timestamp (within last 1 year)
        SET payment_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY);
        INSERT INTO Payment (payment_status, payment_method, amount, payment_timestamp)
        VALUES (status, method, amount, payment_time);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Order table (1000 records: link to User and Payment)
DELIMITER //
CREATE PROCEDURE GenerateOrderData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE user_id INT;
    DECLARE order_status TINYINT;
    DECLARE payment_id INT;
    DECLARE check_out_time DATETIME;
    WHILE i <= 1000 DO
        SET user_id = FLOOR(1 + RAND() * 1000); -- Randomly link to User ID 1-1000
        SET order_status = FLOOR(RAND() * 4); -- 0-Pending, 1-Paid, 2-Shipped, 3-Completed (random)
        SET payment_id = i; -- One-to-one mapping with Payment table (ID 1-1000)
        -- Order timestamp ≤ Payment timestamp (logical consistency)
        SET check_out_time = DATE_SUB((SELECT payment_timestamp FROM Payment WHERE payment_id = payment_id LIMIT 1), INTERVAL FLOOR(RAND() * 24) HOUR);
        INSERT INTO `Order` (user_id, order_status, payment_id, check_out_timestamp)
        VALUES (user_id, order_status, payment_id, check_out_time);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate ShippingMethod table (10 records: sufficient for 1000 Shipping records)
DELIMITER //
CREATE PROCEDURE GenerateShippingMethodData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE method_name VARCHAR(100);
    DECLARE base_cost DECIMAL(10, 2);
    -- Preset English shipping methods
    SET @method_names = 'Express,JD.com Logistics,Amazon Logistics,SF Express,ZTO Express,YTO Express,STO Express,Yunda Express,Best Express,J&T Express';
    WHILE i <= 10 DO
        SET method_name = SUBSTRING_INDEX(SUBSTRING_INDEX(@method_names, ',', i), ',', -1);
        SET base_cost = FLOOR(8 + RAND() * 52) + RAND(); -- Random base cost (8-60 currency units)
        INSERT INTO ShippingMethod (method_name, base_cost)
        VALUES (method_name, base_cost);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Shipping table (1000 records: link to ShippingMethod and Address)
DELIMITER //
CREATE PROCEDURE GenerateShippingData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE method_id INT;
    DECLARE address_id INT;
    WHILE i <= 1000 DO
        SET method_id = FLOOR(1 + RAND() * 10); -- Randomly link to ShippingMethod ID 1-10
        SET address_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Address ID 1-1000 (destination)
        INSERT INTO Shipping (shipping_method_id, address_id)
        VALUES (method_id, address_id);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate OrderProduct table (1000 records: link to Order, Product, and Shipping)
DELIMITER //
CREATE PROCEDURE GenerateOrderProductData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE product_id INT;
    DECLARE quantity INT;
    DECLARE unit_price DECIMAL(10, 2);
    DECLARE shipping_id INT;
    DECLARE total DECIMAL(10, 2);
    DECLARE status TINYINT;
    DECLARE order_id INT;
    WHILE i <= 1000 DO
        SET product_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Product ID 1-1000
        SET quantity = FLOOR(1 + RAND() * 10); -- Random order quantity (1-10 units)
        SET unit_price = (SELECT price FROM Product WHERE product_id = product_id LIMIT 1); -- Get product price
        SET shipping_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Shipping ID 1-1000
        SET total = quantity * unit_price; -- Subtotal (quantity × unit price)
        SET status = FLOOR(RAND() * 2); -- 0-Shipped, 1-Completed (random)
        SET order_id = FLOOR(1 + RAND() * 1000); -- Randomly link to Order ID 1-1000
        INSERT INTO OrderProduct (product_id, quantity, unit_price, shipping_id, order_product_total, order_product_status, order_id)
        VALUES (product_id, quantity, unit_price, shipping_id, total, status, order_id);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Return table (1000 records: link to OrderProduct)
DELIMITER //
CREATE PROCEDURE GenerateReturnData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE order_product_id INT;
    DECLARE reason VARCHAR(255);
    DECLARE request_time DATETIME;
    DECLARE receive_time DATETIME;
    DECLARE amount DECIMAL(10, 2);
    -- Preset English return reasons
    SET @reasons = 'Quality Issue,Wrong Size,Color Mismatch,Functional Defect,7-Day No-Reason Return,Other';
    WHILE i <= 1000 DO
        SET order_product_id = FLOOR(1 + RAND() * 1000); -- Randomly link to OrderProduct ID 1-1000
        -- Randomly select a return reason
        SET reason = SUBSTRING_INDEX(SUBSTRING_INDEX(@reasons, ',', FLOOR(1 + RAND() * 6)), ',', -1);
        -- Random return request timestamp (within last 30 days)
        SET request_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY);
        -- Receive time ≥ request time (30% chance of unprocessed return)
        SET receive_time = IF(RAND() > 0.3, DATE_ADD(request_time, INTERVAL FLOOR(RAND() * 7) DAY), NULL);
        SET amount = FLOOR(50 + RAND() * 9950) + RAND(); -- Random return amount
        INSERT INTO `Return` (order_product_id, return_reason, return_requested_time, return_received_time, return_amount)
        VALUES (order_product_id, reason, request_time, receive_time, amount);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Generate Refund table (1000 records with random statuses)
DELIMITER //
CREATE PROCEDURE GenerateRefundData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE amount DECIMAL(10, 2);
    DECLARE status TINYINT;
    DECLARE refund_time DATETIME;
    WHILE i <= 1000 DO
        SET amount = FLOOR(50 + RAND() * 9950) + RAND(); -- Random refund amount
        SET status = FLOOR(RAND() * 3); -- 0-Processing, 1-Successful, 2-Rejected (random)
        -- Random refund timestamp (within last 30 days)
        SET refund_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY);
        INSERT INTO Refund (refund_amount, refund_status, refund_timestamp)
        VALUES (amount, status, refund_time);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;