# Q1 Function Database Decision

## Relational (MySQL)

### User
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Its schema is fixed and structured (e.g., email, first_name, phone_number), which aligns with SQL’s predefined table design to avoid redundancy and ensure efficient storage.

### Address/City/State/Country
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Address has consistent structured fields (street, zip_code, city_id, state_id, country_id) that match SQL’s rigid schema requirement, ensuring data uniformity

### Order
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Involves transaction-critical workflows (order creation, inventory deduction, payment recording) that require SQL’s ACID compliance to ensure atomicity (all steps succeed or fail together).

### OrderProduct
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Uses composite foreign keys (order_id → Order.order_id, product_id → Product.product_id) to enforce data validity, ensuring no order items reference non-existent orders or products. Supports efficient cross-table aggregation (e.g., calculating total items per order) via SQL’s JOIN and GROUP BY clauses.

### Payment
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Requires strict data consistency for financial records (e.g., payment amount, transaction status), which SQL’s transactions guarantee to avoid discrepancies (e.g., missing payments for orders).

### Shipping/ShippingMethod
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Features structured status and logistics fields (shipping_method, delivery_timestamp) that benefit from SQL’s index support for fast status queries (e.g., tracking all pending shipments).


### Return
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Has fixed structure requiring consistent joins and transactional integrity that benefit from SQL’s index support for fast status queries.

## Non-Relational

### Product Catalog
- **Database:** MongoDB + MySQL (Hybrid)
- **Type:** Document Store + Relational
- **Reason:** 
  - MySQL stores core product attributes (id, name, price, category, inventory) that need consistency
  - MongoDB stores flexible, category-specific attributes (size, color, material) that vary by product type
  - Contain some AI generated data in this part
**Database name:** `ecommerce_catalog`  
**Collection:** `product_attributes`

```json
[{
  "product_id": "P12345",
  "category": "fashion",
  "attributes": {
    "size": ["S", "M", "L"],
    "color": ["blue", "black"],
    "material": "cotton",
    "kind": "sweater"
  },
  "last_updated": "2025-11-25T17:00:00Z"
},
{
  "product_id": "D67890",
  "category": "headphone",
  "attributes": {
    "brand": "Sony",
    "model": "WH-1000XM6",
    "connection": ["Bluetooth 5.3", "Bluetooth 5.2"],
    "battery_life": ["30 hours", "20 hours"],
    "charging_method": ["USB-C"],
    "weight": "100g"
  },
  "last_updated": "2025-11-26T10:30:00Z"
},
{
  "product_id": "H23456",
  "category": "vase",
  "attributes": {
    "style": "Nordic minimalist",
    "material": ["ceramic base", "linen lampshade"],
    "size": {
      "height": "45cm",
      "base_diameter": "15cm",
      "shade_diameter": "25cm"
    },
    "color": ["white base + gray shade", "beige base + white shade"],
  },
  "last_updated": "2025-11-27T14:15:00Z"
}]
```


### Product Inventory
- **Database:** MongoDB
- **Type:** Document Store
- **Reason:** 
  - MongoDB stores flexible, category-specific attributes (size, color, material) that vary by product type
  - Contain some AI generated data in this part
**Database name:** `ecommerce_catalog_inventory`  
**Collection:** `product_attributes`

```json
[{
  "product_id": "P12345",
  "category": "fashion",
  "attributes": {
    "size": "S",
    "color": "blue",
    "material": "cotton",
    "kind": "sweater"
  },
},
{
  "product_id": "P12345",
  "category": "fashion",
  "attributes": {
    "size": "L",
    "color": "black",
    "material": "cotton",
    "kind": "sweater"
  },
},
{
  "product_id": "D67890",
  "category": "headphone",
  "attributes": {
    "brand": "Sony",
    "model": "WH-1000XM6",
    "connection": "Bluetooth 5.3",
    "battery_life": "30 hours",
    "charging_method": "USB-C",
    "weight": "100g"
  },
},
{
  "product_id": "H23456",
  "category": "vase",
  "attributes": {
    "style": "Nordic minimalist",
    "material": "ceramic base",
    "size": {
      "height": "45cm",
      "base_diameter": "15cm",
      "shade_diameter": "25cm"
    },
    "color": "white base + gray shade",
  },
}]
```


### Shopping Cart
- **Database:** Redis
- **Type:** Key-Value Store (Non-relational)
- **Reason:** Carts require extremely fast reads/writes, TTL expiration, and simple key-based lookup.

**Key:** `cart:{session_id}` or `cart:user:{user_id}`

```json
{
  "cart_id": "CART_8888",
  "items": [
    {
      "product_id": "P12345",
      "spec_id": "S_black",          // Specific attributes
      "quantity": 2          
    }
  ],
  "total_items": 2,
  "updated_at": "2025-11-25T16:40:00Z"
}
```


### Session
- **Database:** Redis
- **Type:** Key-Value Store (Non-relational)
- **Reason:** Session data is temporary and frequently accessed, benefiting from in-memory speed and automatic expiration.

**Key:** `session:{session_id}`

```json
{
  "device_type": "desktop",
  "user_id": "U123",
  "created_at": "2025-11-25T15:00:00Z",
  "last_activity": "2025-11-25T16:55:00Z"
}
```


### User Behavior
- **Database:** MongoDB
- **Type:** Document Store
- **Reason:** Behavior events are high-volume, append-only, and timestamped, better suited for flexible storage.

**Database name:** `ecommerce_events`  
**Collection:** `user_events`

```json
{
  "user_id": "U123",
  "session_id": "S_abc123",
  "event_type": "view",
  "product_id": "P12345",
  "search_term": null,
  "device_type": "mobile",
  "timestamp": "2025-11-25T16:10:00Z"
}
```

**Note:** Event types include: `view`, `click`, `search`, `add_to_cart`, `purchase`



# Q2 ERD
![Database diagram](db_design_SQL_Nov29_version5.png)

# Q3
I keep a small Product table in MySQL for attributes that are common to all products (product_id, name, price, category, etc.), and then store the category-specific attributes in a document store like MongoDB. In addition, we introduced 'spec_id' to distinguish different attributes of products

# Q4

To handle user sessions, I separate two ideas: **who the user is** and **what device they are using**.

And I utilize different database to handle different data.
* **Redis** gives very fast access to active sessions and carts.
* **MySQL** keeps long-term records and makes data survive across devices and time.

## 1. User vs Session

* **User ID:** This is the long-term identity stored in MySQL. It is the same across all devices.
* **Session ID:** This is a short-term token stored in a cookie on each device.
  Every device gets its own session ID. I store the actual session data in Redis.

## 2. Guest vs Logged-In

* **Guest users** get a new session ID when they first visit the site. Their cart and recent activity are tied to the session ID stored in Redis.
* When the user **logs in**, I attach the session to their **user ID** so it becomes part of their account.

## 3. Using the Website on Multiple Devices

If the same user logs in on another device (for example, phone + laptop):

* The new device gets a new session ID.
* As soon as they log in, the server loads their saved cart and session info from MySQL.
* Redis is updated so both devices now point to the *same* user-level cart.
* This means the user sees the **same cart** across all devices.

## 4. Multiple Shopping Sessions Over Time

* Redis stores recent session data and cart data for fast access.
* I also save important session info into MySQL occasionally (such as abandoned carts).
  This helps with analytics and makes sure nothing is lost if Redis resets.

## 5. Merging Carts

If someone adds items as a **guest** and then logs in:

1. I take the guest cart (from the session ID).
2. I take the user's saved cart (from their user ID).
3. I merge them together.
4. The merged cart becomes the new "official" cart for that user.

# Q5
1. order_product_subtotal: I defined this part be the sum of product amount and tax. They are computed and stored together each time instead of store them separately, which can reduce the rlationships and raise overall efficiency.
2. amount: I define this part be product amount + shipping fee + tax for the same reason.

# Q6
## Data Flow Between Databases

### Flow 1: MySQL --> MongoDB (Product Catalog Sync)
- **What flows:** Basic product info (id, name, price, category) and inventory levels are copied from MySQL into MongoDB for flexible attributes like sizes, colors, materials.
- **Freshness:** Synced every 2–5 minutes. Small delays are acceptable.
- **Fallback:** If MongoDB is down, basic product data still available from MySQL.

### Flow 2: Frontend --> MongoDB (User Behavior Events)
- **What flows:** Every view, click, search, or add-to-cart event saved in MongoDB's `user_events` collection.
- **Freshness:** Events appear within seconds for "recently viewed" and recommendations.
- **Fallback:** If MongoDB unavailable, events can be safely dropped. Shopping still works via MySQL.

### Flow 3: Frontend --> Redis (Sessions and Carts)
- **What flows:** Session data (`session_id`, `user_id`) and shopping cart items (`product_id`, `quantity`).
- **Freshness:** Real-time (milliseconds). Users must see cart changes immediately.
- **Fallback:** If Redis restarts, logged-in users can recover cart from MySQL snapshots.

### Flow 4: Redis --> MySQL (Checkout and Cart Snapshots)
- **What flows:** Cart data written to MySQL as permanent Order/OrderItem/Payment records during checkout. Periodic snapshots save abandoned carts.
- **Freshness:** Checkout writes are immediate. Snapshots every 10–30 minutes.
- **Fallback:** If snapshot fails, Redis holds recent cart. Orders and accounts remain safe.

### Flow 5: MongoDB --> MySQL (Reporting Tables)
- **What flows:** Aggregated metrics (daily views, search counts, user activity) from MongoDB `user_events` into MySQL reporting tables.
- **Freshness:** Updated hourly or nightly.
- **Fallback:** If batch job fails, older summary data remains. Core shopping functions unaffected.


# Q7

## Data Consistency and Integrity Challenges

### 1. Keeping Data Consistent Across Databases

**Problem:** Same data appears in multiple places (e.g., product info in both MySQL and MongoDB), causing mismatches when updates fail.

**Fix:**
- Make MySQL the main source of truth
- Use ETL jobs to sync MySQL --> MongoDB and MongoDB --> MySQL (reporting)
- Add retry logic for failed updates
- Treat MongoDB and Redis as helper layers, not authoritative

### 2. Redis Volatility (Data Can Disappear)

**Problem:** Redis is in-memory, so sessions or carts may be lost if Redis restarts or evicts keys.

**Fix:**
- Add TTL to sessions and carts
- Save carts to MySQL during checkout or using periodic snapshots
- Treat Redis as a cache, not permanent storage

### 3. MongoDB Schema Drift

**Problem:** MongoDB documents can slowly become inconsistent (missing fields, different field names).

**Fix:**
- Define simple JSON field rules for each collection
- Add basic validation before inserting documents
- Use occasional cleanup scripts to fix old documents


# Q8
Data that benefits most from in-memory storage includes sessions and shopping carts because they change often and require very fast access. I would store these in Redis and keep a small identifier (like a session_id or user_id) in the user’s cookie. When the user comes back, the server reads that identifier and retrieves the latest session or cart data from Redis or MySQL.

# Q9

I will use **MongoDB** to add a separate behavior-tracking layer alongside the normal e-commerce database to track user shopping behavior. MongoDB is flexible and doesn't need strict schema, in case more behaviors need to be added.

### What I Track
* Product views, clicks, search queries
* Time spent on pages
* Add-to-cart and purchase events (as behavior, not official orders)

**Database:** `ecommerce_events`  
**Collection:** `user_events`

```json
{
  "user_id": "U123",
  "session_id": "S_abc123",
  "event_type": "view",
  "product_id": "P12345",
  "timestamp": "2025-11-25T16:10:00Z"
}
```

**Indexes:** `user_id + timestamp` and `product_id + event_type` for quick lookups.

### Connecting MongoDB to MySQL
MongoDB stores **raw event stream**, MySQL stores **summaries**.

ETL job (hourly/nightly):
1. Read events from MongoDB
2. Aggregate data
3. Write to MySQL tables: `daily_product_views`, `top_search_terms`, `user_activity_summary`

### Connecting Redis to MongoDB
Redis stores session and cart info. Each frontend action uses Redis `session_id` to attach correct user info before writing events to MongoDB.

Redis is used like a fast lookup table to enrich the event before saving it.

**Example:**

User performs: "view product P12345"

Backend process:
1. Check Redis: "which user/session did this come from?"
2. Write enriched behavior event to MongoDB:

```json
{
  "user_id": "U123",
  "session_id": "S_abc123",
  "event_type": "view",
  "product_id": "P12345",
  "timestamp": "2025-11-25T16:10:00Z"
}
```

# Q10
## Queries that graph database better than relational
Graph databases can answer multi-step relationship queries much faster than relational joins. For examples, we can form a  "finding products that are often bought together" "guess what you like" graph database by studying user purchase behavior.

## Graph model design
Nodes:
- (User {user_id, name})
- (Product {product_id, name, category})
- (Category {category})

Relationships:
- (:User)-[:VIEWED]->(:Product)
- (:User)-[:ADDED_TO_CART]->(:Product)
- (:User)-[:PURCHASED]->(:Product)
- (:Product)-[:IN_CATEGORY]->(:Category)
- (:Product)-[:BOUGHT_WITH]->(:Product)


