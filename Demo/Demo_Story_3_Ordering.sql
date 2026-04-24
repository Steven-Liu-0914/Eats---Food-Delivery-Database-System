USE `eats`;

-- ==============================================================================
-- DEMO STORY 3: Cart Management & Order Processing

-- SCENARIO: 
-- 1. [Success]: She successfully adds David's items and checkouts.
-- 2. [Verification]: The system handles payment and auto-assigns the available rider.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- SETUP: Setting the parameters
-- ------------------------------------------------------------------------------
SET @alice_id = (SELECT user_id FROM eats.user WHERE email = 'alice@test.com' LIMIT 1);
SET @davids_res_id = (SELECT restaurant_id FROM eats.restaurant WHERE name LIKE '%David Burger%' LIMIT 1);
SET @burger_id = (SELECT menu_item_id FROM eats.menu_item WHERE restaurant_id = @davids_res_id AND item_name LIKE '%Burger%' LIMIT 1);
SET @fries_id = (SELECT menu_item_id FROM eats.menu_item WHERE restaurant_id = @davids_res_id AND item_name LIKE '%Fries%' LIMIT 1);

-- ------------------------------------------------------------------------------
-- STEP 6: Retrieve Menu & Manage Cart (Conflict & Resolution)
-- ------------------------------------------------------------------------------
-- Now Alice can successfully build her order from David's restaurant.
-- We add 1 burger first, then 2 more (testing the Upsert logic), then fries.
-- total 3 burgers and 1 fries
CALL sp_upsert_cart_item(@alice_id, @davids_res_id, @burger_id, 1);
CALL sp_upsert_cart_item(@alice_id, @davids_res_id, @burger_id, 2); 
CALL sp_upsert_cart_item(@alice_id, @davids_res_id, @fries_id, 1);

-- [Verification]: Verify the cart reflects the correct data.
SELECT r.name AS restaurant, mi.item_name, ci.quantity
FROM eats.cart c
JOIN eats.restaurant r ON c.restaurant_id = r.restaurant_id
JOIN eats.cart_item ci ON c.cart_id = ci.cart_id
JOIN eats.menu_item mi ON ci.menu_item_id = mi.menu_item_id
WHERE c.user_id = @alice_id;

-- ------------------------------------------------------------------------------
-- STEP 7: Process Order
-- ------------------------------------------------------------------------------
-- [Demo]: Alice is ready to pay. This SP processes as a transaction:
-- Creating the order, Create Payment Record, Create Delivery Request, Assign Rider and Auto-Clean Cart.

SET @alice_address = (SELECT address_id FROM eats.address WHERE user_id = @alice_id LIMIT 1);
SET @current_cart_id = (SELECT cart_id FROM eats.cart WHERE user_id = @alice_id LIMIT 1);

CALL sp_process_checkout(@alice_id, @current_cart_id, @alice_address, 'Credit Card');


-- ------------------------------------------------------------------------------
-- STEP 7b: Post-Checkout Verification
-- ------------------------------------------------------------------------------
-- 1. Check Order & Payment (Note the snapshot address and total amount)
SELECT o.order_id, o.customer_address_snapshot, p.amount AS total_paid, os.status_name AS order_status
FROM eats.order o
JOIN eats.payment p ON o.order_id = p.order_id
JOIN eats.order_status os ON o.order_status_id = os.order_status_id
WHERE o.customer_user_id = @alice_id ORDER BY o.created_at DESC LIMIT 1;

-- 2. Verify Auto-Assigned Driver (Least Busy)
SELECT d.order_id, u.name AS assigned_rider, ds.status_name AS delivery_status
FROM eats.delivery d
JOIN eats.user u ON d.driver_user_id = u.user_id
JOIN eats.delivery_status ds ON d.delivery_status_id = ds.delivery_status_id
WHERE d.order_id IN (SELECT (order_id) FROM eats.order WHERE customer_user_id = @alice_id);

-- 3. Confirm Cart Cleanup
SELECT 'Items remaining in cart:' AS label, COUNT(*) FROM eats.cart_item WHERE cart_id = @current_cart_id;

-- ==============================================================================
-- END OF STORY 3
-- ==============================================================================