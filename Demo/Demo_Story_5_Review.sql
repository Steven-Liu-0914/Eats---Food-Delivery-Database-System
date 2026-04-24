USE `eats`;

-- ==============================================================================
-- DEMO STORY 5: Review & Rating
-- SCENARIO: Alice wants to leave feedback. We will test the system's 
-- error handling by implementing unauthorized, invalid order status, and duplicate reviews.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- SETUP: Identifying IDs
-- ------------------------------------------------------------------------------
SET @alice_id = (SELECT user_id FROM eats.user WHERE email = 'alice@test.com' LIMIT 1);
SET @last_order_id = (SELECT order_id FROM eats.order WHERE customer_user_id = @alice_id LIMIT 1);

-- ------------------------------------------------------------------------------
-- TEST 1: Ownership Check (Security)
-- ------------------------------------------------------------------------------
-- [Validation]: Can a different user (e.g., User ID 1) review Alice's order?
-- EXPECTED RESULT: "You can only review your own orders."

CALL sp_add_review(@last_order_id, 1, 5, 'Hacker was here!');

-- ------------------------------------------------------------------------------
-- TEST 2: Status Check (Business Logic Validation)
-- ------------------------------------------------------------------------------
-- [Validation]: Our business rule states that only 'Delivered' orders can be reviewed. 
-- 1. Temporarily update the order status back to Pending
UPDATE eats.order SET order_status_id = 1 WHERE order_id = @last_order_id;

-- 2. [Action]: Try to review the "Pending" order
-- EXPECTED RESULT: Error 45000 - "Only delivered orders can be reviewed."
CALL sp_add_review(@last_order_id, @alice_id, 5, 'I bet this will be good!');

-- 3. [Revert]: Update the status back to 'Delivered' (5) so we can proceed
UPDATE eats.order SET order_status_id = 5 WHERE order_id = @last_order_id;

SELECT o.order_id, os.status_name 
FROM eats.order o 
JOIN eats.order_status os ON o.order_status_id = os.order_status_id 
WHERE o.order_id = @last_order_id;

-- ------------------------------------------------------------------------------
-- TEST 3: Successful Review
-- ------------------------------------------------------------------------------
-- [Demo]: Now Alice reviews her ACTUAL delivered order from Story 4. 
-- Since Status = 5 and she owns the order, this will succeed.

CALL sp_add_review(@last_order_id, @alice_id, 5, 'Perfect burger! Best service ever.');

-- [Verification]: See the review linked to the order.
SELECT * FROM eats.review WHERE order_id = @last_order_id;

-- ------------------------------------------------------------------------------
-- TEST 4: Duplicate Check
-- ------------------------------------------------------------------------------
-- [Validation]: Our check prevents duplicate reviews for the same order
-- EXPECTED RESULT: "Order already reviewed."
CALL sp_add_review(@last_order_id, @alice_id, 1, 'Somehow wants to review again');

