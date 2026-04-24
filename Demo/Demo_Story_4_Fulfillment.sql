USE `eats`;

-- ==============================================================================
-- DEMO STORY 4: The Order and Delivery Lifecycle
-- 
-- SCENARIO: 
-- 1. [Restaurant]: David checks his dashboard and prepares Alice's burger.
-- 2. [Customer]: Alice tracks the status of her order in real-time.
-- 3. [Rider]: The Rider picks up the food and completes the delivery.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- SETUP: Get IDs from the previous story
-- ------------------------------------------------------------------------------
SET @alice_id = (SELECT user_id FROM eats.user WHERE email = 'alice@test.com' LIMIT 1);
SET @order_id = (SELECT MAX(order_id) FROM eats.order WHERE customer_user_id = @alice_id);
SET @davids_res_id = (SELECT restaurant_id FROM eats.restaurant WHERE name LIKE '%David Burger%' LIMIT 1);
SET @assigned_rider_id = (SELECT driver_user_id FROM eats.delivery WHERE order_id = @order_id);

-- ------------------------------------------------------------------------------
-- STEP 8: Order Status Tracking (Restaurant & Customer View)
-- ------------------------------------------------------------------------------

-- [David's View]: David retrieves all "Pending" or "Preparing" orders for his shop.
-- This shows your "Retrieve Restaurant Pending Orders" SP.
CALL sp_retrieve_restaurant_pending_orders(@davids_res_id);

-- [Alice's View]
CALL sp_retrieve_customer_orders(@alice_id);

-- [David's Action]: David finishes cooking and marks the order as "Ready for Pickup" (Status 3).
CALL sp_update_order_status(@order_id, 3);

-- [Alice's View]: Alice refreshes her page and retrieves her order latest status.
-- [Demo]: Notice the status has changed from 'Preparing' to 'Ready for Pickup'.
CALL sp_retrieve_customer_orders(@alice_id);

-- ------------------------------------------------------------------------------
-- STEP 9: Delivery Tracking & Automatic Sync
-- ------------------------------------------------------------------------------
-- [Rider's Action]: The rider picks up the food.
-- Our SP is designed to automatically sync the Order status based on delivery status.

-- Before Updates
SELECT 
    o.order_id, 
    os.status_name AS order_state, 
    ds.status_name AS delivery_state
FROM eats.order o
JOIN eats.order_status os ON o.order_status_id = os.order_status_id
JOIN eats.delivery d ON o.order_id = d.order_id
JOIN eats.delivery_status ds ON d.delivery_status_id = ds.delivery_status_id
WHERE o.order_id = @order_id;

-- Update Status -> In Transit
CALL sp_update_delivery_status(@order_id, 2);

-- [Verification]: Prove that both tables are now in sync.
SELECT 
    o.order_id, 
    os.status_name AS order_state, 
    ds.status_name AS delivery_state
FROM eats.order o
JOIN eats.order_status os ON o.order_status_id = os.order_status_id
JOIN eats.delivery d ON o.order_id = d.order_id
JOIN eats.delivery_status ds ON d.delivery_status_id = ds.delivery_status_id
WHERE o.order_id = @order_id;


-- [Final Action]: Rider arrives and marks as 'Delivered' (Status 3).
CALL sp_update_delivery_status(@order_id, 3);

-- [Verification]: The order lifecycle is now complete.
SELECT 
    o.order_id, 
    os.status_name AS order_state, 
    ds.status_name AS delivery_state
FROM eats.order o
JOIN eats.order_status os ON o.order_status_id = os.order_status_id
JOIN eats.delivery d ON o.order_id = d.order_id
JOIN eats.delivery_status ds ON d.delivery_status_id = ds.delivery_status_id
WHERE o.order_id = @order_id;


-- ==============================================================================
-- END OF DEMO STORY 4
-- ==============================================================================