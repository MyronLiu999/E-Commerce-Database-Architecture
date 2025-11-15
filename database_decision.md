# Q1 Function Database Decision

## Relational (MySQL)

### User
- **Database:** MySQL
- **Type:** Relational
- **Reason:** User profiles, addresses, and payment methods follow a fixed schema and require strong consistency and foreign key relationships.

### Order
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Orders, order items, payments, and shipping require ACID transactions to prevent partial or inconsistent states.

### Shipping
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Structured shipping methods, rates, and delivery tracking.

### Inventory
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Stock levels need strong consistency to prevent overselling and ensure accurate quantity updates.

### Payment
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Financial transactions require strict ACID guarantees and transaction rollbacks.

### Return
- **Database:** MySQL
- **Type:** Relational
- **Reason:** Refunds link tightly to original orders and payment transactions, requiring consistent joins and transactional integrity.

## Non-Relational

### Product Catalog
- **Database:** MongoDB
- **Type:** Document Store (Non-relational)
- **Reason:** Different product types have flexible and evolving attributes that fit better in JSON documents than rigid relational schemas.

### Shopping Cart
- **Database:** Redis
- **Type:** Key-Value Store (Non-relational)
- **Reason:** Carts require extremely fast reads/writes, TTL expiration, and simple key-based lookup.

### Session
- **Database:** Redis
- **Type:** Key-Value Store (Non-relational)
- **Reason:** Session data is temporary and frequently accessed, benefiting from in-memory speed and automatic expiration.

### User Behavior
- **Database:** MongoDB
- **Type:** Document Store
- **Reason:** Behavior events are high-volume, append-only, and timestamped, better suited for flexible storage.