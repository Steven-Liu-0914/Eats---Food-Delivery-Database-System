USE `eats`;

-- ==============================================================================
-- DEMO STORY 2: New Customer Onboarding & Discovery
-- 
-- SCENARIO: A new user (Alice) downloads the app. She registers as a customer,
-- sets up her delivery address, and starts exploring. She first checks the 
-- "Top Rated" dashboard, then searches for "Burger" to find David's new store.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- SETUP : Register Alice (The Customer) & Set Address
-- ------------------------------------------------------------------------------
-- [Explanation]: Alice creates her account (role_id = 1 for Customer)
CALL sp_register_user('Alice Wong', 'alice@test.com', '98765432', 'alice_hash', 'alice_salt', 1);

-- [System]: Capture Alice's ID for subsequent discovery and ordering steps
SET @alice_id = (SELECT user_id FROM eats.user WHERE email = 'alice@test.com' LIMIT 1);

-- [Explanation]: Alice adds her home address so she can see restaurants nearby later
INSERT INTO eats.address (user_id, address, postal_code) 
VALUES (@alice_id, '456 Clementi Ave 3, #10-05', '120456');

-- [Demo]: Alice's profile is ready.
SELECT 
    u.user_id, 
    u.name, 
    u.email, 
    r.role_name AS assigned_role, -- Joining role table to show the label
    a.address AS primary_address,
    a.postal_code
FROM eats.user u
INNER JOIN eats.role r ON u.role_id = r.role_id
INNER JOIN eats.address a ON u.user_id = a.user_id
WHERE u.user_id = @alice_id;

-- ------------------------------------------------------------------------------
-- STEP 1: Retrieve Top-Rated Restaurants (Dashboard / Leaderboard)
-- ------------------------------------------------------------------------------
-- [Explanation]: Alice opens the app home screen. The system automatically calls 
-- our SP to show the "Top 10" based on real customer reviews.
CALL sp_get_monthly_top_rated_restaurant(YEAR(CURRENT_DATE()), MONTH(CURRENT_DATE()));

-- ------------------------------------------------------------------------------
-- STEP 2: Search Restaurants (Advanced Keyword Search)
-- ------------------------------------------------------------------------------
-- [Explanation to Prof]: Alice wants to search a 'burger'. Our platform doesn't just search 
-- the Restaurant Name; it cross-references Descriptions and Menu Items to give 
-- the most accurate recommendations.

CALL sp_search_restaurant('Burger');

-- Let's double check Restaurant 66 and 77 just to prove the data is there
SELECT restaurant_id, item_name, description FROM eats.menu_item WHERE 
(restaurant_id = 66 AND item_name LIKE '%Burger%')
or (restaurant_id = 77 AND description LIKE '%Burger%');

-- ------------------------------------------------------------------------------
-- STEP 2b: EDGE CASE (Dynamic Filtering of Closed Stores)
-- ------------------------------------------------------------------------------
-- [Explanation]: What if David's store closes? Our search should be "smart" enough to hide it.
SET @davids_res_id = (SELECT restaurant_id FROM eats.restaurant WHERE name LIKE '%David Burger%' LIMIT 1);

-- [System]: David closes the shop (is_open = 0)
UPDATE eats.restaurant SET is_open = 0 WHERE restaurant_id = @davids_res_id;

-- Alice searches for "Burger" again...
CALL sp_search_restaurant('Burger');

-- [Demo]: As you can see, the store is now hidden. This prevents customers from placing orders that can't be processed.

-- [System Cleanup]: Re-open for the next Story!
UPDATE eats.restaurant SET is_open = 1 WHERE restaurant_id = @davids_res_id;

-- ==============================================================================
-- END OF STORY 2
-- ==============================================================================