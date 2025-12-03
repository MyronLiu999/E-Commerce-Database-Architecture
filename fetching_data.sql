
-- QUERY 1: Retrieve all products in the "fashion" category along with their associated attributes such as size, color, and material.
-- 1. Run MySQL query to get fashion product IDs
-- 2. Use those IDs in MongoDB query to get attributes
-- 3. Application layer joins the results

-- MySQL Query
SELECT p.product_id, p.product_name, p.price, p.category
FROM Product p 
WHERE p.category = 'fashion'
ORDER BY p.product_name;

-- MongoDB Query
-- Database: ecommerce_catalog, Collection: product_specs
/*
MongoDB:
db.product_specs.find(
  { 
    "product_id": { $in: [/* insert fashion product_ids from MySQL */] }
  },
  {
    "product_id": 1,
    "spec_id": 1,
    "attributes.size": 1,
    "attributes.color": 1,
    "attributes.material": 1
  }
).sort({"product_id": 1});
*/




-- QUERY 2: Retrieve the last five products viewed by Sarah within the past six months, ordered by most recent activity.
-- 1. Query MongoDB user_events to get Sarah's recent product views
-- 2. Use those product_ids in MySQL to get product details

-- MongoDB Query
-- Database: ecommerce_events, Collection: user_events
/*
db.user_events.find(
  {
    "user_id": 1001,  // Replace with Sarah's actual user_id
    "event_type": "view",
    "timestamp": {
      $gte: new Date(new Date().setMonth(new Date().getMonth() - 6))
    }
  },
  {
    "product_id": 1,
    "timestamp": 1,
    "_id": 0
  }
).sort({"timestamp": -1}).limit(5);
*/

-- MySQL Query
SELECT p.product_id, p.product_name, p.category, p.price 
FROM Product p 
WHERE p.product_id IN (/* insert product_ids from MongoDB result */);




-- QUERY 3: Check the current stock level for all items and return only items that are low in stock (e.g., less than five items).
-- MySQL Query
SELECT 
    i.spec_id,
    p.product_id,
    p.product_name,
    p.category,
    i.quantity
FROM Inventory i
JOIN Product p ON i.product_id = p.product_id
WHERE i.quantity < 5
ORDER BY i.quantity ASC, p.product_name;




-- QUERY 4: Retrieve all products in the "fashion" category that are available in either blue color or large size.
-- 1. Get fashion products from MySQL
-- 2. Filter by blue color OR large size in MongoDB
-- 3. Combine results

-- MySQL Query
SELECT product_id, product_name, price
FROM Product 
WHERE category = 'fashion';

-- MongoDB Query
-- Database: ecommerce_catalog, Collection: product_specs
/*
db.product_specs.find(
  {
    $and: [
      { "product_id": { $in: [/* insert fashion product_ids from MySQL */] } },
      {
        $or: [
          { "attributes.color": "blue" },
          { "attributes.size": { $in: ["L", "Large", "large"] } }
        ]
      }
    ]
  },
  {
    "product_id": 1,
    "spec_id": 1,
    "attributes.color": 1,
    "attributes.size": 1
  }
);
*/




-- QUERY 5: Display the number of times each product page has been viewed, ordered by popularity (e.g., number of views).
-- 1. Aggregate view events in MongoDB to count popularity
-- 2. Get product names from MySQL for top viewed products

-- MongoDB Query
-- Database: ecommerce_events, Collection: user_events
/*
db.user_events.aggregate([
  {
    $match: {
      "event_type": "view"
    }
  },
  {
    $group: {
      _id: "$product_id",
      view_count: { $sum: 1 },
      unique_viewers: { $addToSet: "$user_id" },
      last_viewed: { $max: "$timestamp" }
    }
  },
  {
    $addFields: {
      unique_viewer_count: { $size: "$unique_viewers" }
    }
  },
  {
    $project: {
      product_id: "$_id",
      view_count: 1,
      unique_viewer_count: 1,
      last_viewed: 1,
      _id: 0
    }
  },
  {
    $sort: { view_count: -1 }
  }
]);
*/

-- MySQL Query
SELECT product_id, product_name, category 
FROM Product 
WHERE product_id IN (/* insert top viewed product_ids from MongoDB */);




-- QUERY 6: Retrieve all recent search terms used by the user and categorize them based on frequency and time of day.

-- MongoDB Query
-- Database: ecommerce_events, Collection: user_events
/*
db.user_events.aggregate([
  {
    $match: {
      "event_type": "search",
      "search_term": { $ne: null }
    }
  },
  {
    $addFields: {
      hour_of_day: { $hour: "$timestamp" },
      time_period: {
        $switch: {
          branches: [
            { case: { $and: [ { $gte: ["$hour", 6] }, { $lt: ["$hour", 12] } ] }, then: "Morning" },
            { case: { $and: [ { $gte: ["$hour", 12] }, { $lt: ["$hour", 18] } ] }, then: "Afternoon" },
            { case: { $and: [ { $gte: ["$hour", 18] }, { $lt: ["$hour", 22] } ] }, then: "Evening" }
          ],
          default: "Night"
        }
      }
    }
  },
  {
    $group: {
      _id: {
        search_term: "$search_term",
        time_period: "$time_period"
      },
      frequency: { $sum: 1 },
      unique_users: { $addToSet: "$user_id" },
      last_searched: { $max: "$timestamp" }
    }
  },
  {
    $project: {
      search_term: "$_id.search_term",
      time_period: "$_id.time_period",
      frequency: 1,
      unique_user_count: { $size: "$unique_users" },
      last_searched: 1,
      _id: 0
    }
  },
  {
    $sort: { frequency: -1, search_term: 1 }
  }
]);
*/




-- QUERY 7: Fetch all carts for users, showing device type (e.g., laptop, tablet), the number of items in the cart, and total amount.
-- 1. Get active cart data from Redis
-- 2. Get cart analytics from MongoDB
-- 3. Get user details from MySQL

-- Redis Commands
/*
KEYS cart:*
For each key returned above:
JSON.GET {key_name}

Examples:
JSON.GET cart:user:1001  -- For a logged-in user cart 1001
JSON.GET cart:200001     -- For a guest session cart 200001
*/




-- MongoDB Query
-- Database: ecommerce_events, Collection: cart_sessions
/*
db.cart_sessions.find(
  {},
  {
    "cart_id": 1,
    "user_id": 1,
    "device_type": 1,
    "total_value": 1,
    "items": 1,
    "is_converted_to_order": 1
  }
).sort({"last_updated": -1});
*/

-- MySQL Query
SELECT 
    u.user_id,
    u.first_name,
    u.last_name
FROM User u
WHERE u.user_id IN (/* insert user_ids from cart data */);

-- QUERY 8: Retrieve all orders placed by Sarah, showing order IDs, item details, payment methods, shipping options chosen, and the status of each order.

-- MySQL Query
SELECT 
    o.order_id,
    o.check_out_timestamp,
    o.order_status,
    op.product_id,
    p.product_name,
    op.quantity,
    op.order_product_subtotal,
    py.payment_method,
    py.amount AS payment_amount,
    sm.method_name AS shipping_method,
    s.delivery_timestamp,
    CASE 
        WHEN o.order_status = 0 THEN 'Pending'
        WHEN o.order_status = 1 THEN 'Paid' 
        WHEN o.order_status = 2 THEN 'Shipped'
        WHEN o.order_status = 3 THEN 'Delivered'
        ELSE 'Unknown'
    END AS status_name
FROM `Order` o
JOIN User u ON o.user_id = u.user_id
JOIN OrderProduct op ON o.order_id = op.order_id  
JOIN Product p ON op.product_id = p.product_id
JOIN Payment py ON o.payment_id = py.payment_id
JOIN Shipping s ON op.shipping_id = s.shipping_id
JOIN ShippingMethod sm ON s.shipping_method_id = sm.shipping_method_id
WHERE u.first_name = 'Sarah'  -- Replace with actual user identification
ORDER BY o.check_out_timestamp DESC, o.order_id, op.order_product_id;




-- QUERY 9: List all items returned by the user, along with the refund status, amount, and any restocking fees.

-- MySQL Query
SELECT 
    r.return_id,
    p.product_id,
    p.product_name,
    op.quantity AS returned_quantity,
    r.return_amount,
    r.return_fee,
    r.return_requested_time,
    r.exp_return_time,
    CASE 
        WHEN r.return_status = 0 THEN 'Applied'
        WHEN r.return_status = 1 THEN 'Approved'
        WHEN r.return_status = 2 THEN 'Rejected'
        WHEN r.return_status = 3 THEN 'Closed'
        ELSE 'Unknown'
    END AS return_status_name,
    u.first_name,
    u.last_name
FROM `Return` r
JOIN OrderProduct op ON r.order_product_id = op.order_product_id
JOIN Product p ON op.product_id = p.product_id  
JOIN `Order` o ON op.order_id = o.order_id
JOIN User u ON o.user_id = u.user_id
WHERE u.first_name = 'Sarah'  -- Replace with actual user identification  
ORDER BY r.return_requested_time DESC;




-- QUERY 10: Retrieve the average number of days between purchases for Sarah.

-- MySQL Query
SELECT 
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(o2.check_out_timestamp, o1.check_out_timestamp)), 2) AS avg_days_between_purchases
FROM `Order` o1
JOIN `Order` o2 ON o1.user_id = o2.user_id AND o1.check_out_timestamp < o2.check_out_timestamp
JOIN User u ON o1.user_id = u.user_id
WHERE u.first_name = 'Sarah'
    AND o1.order_status IN (1, 2, 3)
    AND o2.order_status IN (1, 2, 3);




-- QUERY 11: Calculate the percentage of carts that did not convert to orders in the past 30 days.

-- MongoDB Query
-- Database: ecommerce_events, Collection: cart_sessions
/*
db.cart_sessions.aggregate([
  {
    $match: {
      "created_at": {
        $gte: new Date(new Date().setDate(new Date().getDate() - 30))
      }
    }
  },
  {
    $group: {
      _id: null,
      total_carts: { $sum: 1 },
      converted_carts: {
        $sum: {
          $cond: ["$is_converted_to_order", 1, 0]
        }
      },
      abandoned_carts: {
        $sum: {
          $cond: [{ $eq: ["$is_converted_to_order", false] }, 1, 0]
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      total_carts: 1,
      converted_carts: 1,
      abandoned_carts: 1,
      conversion_rate_percent: {
        $round: [
          { $multiply: [{ $divide: ["$converted_carts", "$total_carts"] }, 100] },
          2
        ]
      },
      abandonment_rate_percent: {
        $round: [
          { $multiply: [{ $divide: ["$abandoned_carts", "$total_carts"] }, 100] },
          2
        ]
      }
    }
  }
]);
*/




-- QUERY 12: Find the top 3 products most frequently purchased together with "headphones".

-- MySQL Query
SELECT 
    p2.product_id,
    p2.product_name,
    p2.category,
    COUNT(*) AS times_bought_together
FROM OrderProduct op1
JOIN Product p1 ON op1.product_id = p1.product_id
JOIN OrderProduct op2 ON op1.order_id = op2.order_id AND op1.product_id != op2.product_id
JOIN Product p2 ON op2.product_id = p2.product_id
WHERE (LOWER(p1.product_name) LIKE '%headphone%' OR LOWER(p1.category) = 'headphone')
    AND NOT (LOWER(p2.product_name) LIKE '%headphone%' OR LOWER(p2.category) = 'headphone')
GROUP BY p2.product_id, p2.product_name, p2.category
ORDER BY times_bought_together DESC
LIMIT 3;

-- Alternative: Neo4j Graph Database Approach
/*
MATCH (headphones:Product)-[:BOUGHT_WITH]->(other:Product)
WHERE toLower(headphones.name) CONTAINS 'headphone' 
   OR toLower(headphones.category) = 'headphone'
WITH other, count(*) as frequency
ORDER BY frequency DESC
LIMIT 3
RETURN other.product_id, other.name, other.category, frequency
*/




-- QUERY 13: For each user, compute days since last purchase and total order count.

-- MySQL Query
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(o.order_id) AS total_order_count,
    MAX(o.check_out_timestamp) AS last_purchase_date,
    DATEDIFF(NOW(), MAX(o.check_out_timestamp)) AS days_since_last_purchase
FROM User u
LEFT JOIN `Order` o ON u.user_id = o.user_id AND o.order_status IN (1, 2, 3)
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_order_count DESC;