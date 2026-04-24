USE `eats`;
-- ==============================================================================
-- DEMO STORY 1: Restaurant Onboarding & Menu Management
-- 
-- SCENARIO: A new business owner (David) wants to join our platform. 
-- He will register an account, set up his restaurant profile, open the store, 
-- and publish his first menu items. We will also demonstrate our system's security validation.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- STEP 1: Register a New User (Role: Restaurant Owner)
-- ------------------------------------------------------------------------------
-- David downloads the app and registers as an Owner (role_id = 2)
CALL sp_register_user('David Lee', 'david.lee@davidsburger.com', '81112222', 'dummy_hash', 'dummy_salt', 2);

-- [Demo]: Show that David is successfully inserted into the user table
SELECT user_id, name, email, role.role_id, role.role_name, created_at 
FROM eats.user 
INNER JOIN role on role.role_id = user.role_id
WHERE email = 'david.lee@davidsburger.com';

-- ------------------------------------------------------------------------------
-- STEP 1b: ERROR HANDLING DEMONSTRATION (Duplicate Email)
-- ------------------------------------------------------------------------------
-- [Validation]: What if someone tries to register with David's email again?
-- EXPECTED OUTCOME: Will throw an Error "Email already registered."
CALL sp_register_user('Hacker', 'david.lee@davidsburger.com', '99999999', 'hash', 'salt', 1);

-- ------------------------------------------------------------------------------
-- STEP 2: Register the Restaurant & Address
-- ------------------------------------------------------------------------------
-- David logs in and creates his restaurant profile. 
-- The SP uses transactions to safely insert into both 'restaurant' and 'address' tables.

-- [Explaination]: Store David's newly generated user_id into a variable for the next steps
SET @david_user_id = (SELECT user_id FROM eats.user WHERE email = 'david.lee@davidsburger.com' LIMIT 1);

CALL sp_register_restaurant(
    @david_user_id, 
    'David Burger', 
    'Premium handcrafted burgers and fries', 
    '68889999', 
    '123 Kent Ridge Drive, #01-01', 
    '119260'
);

-- [Explaination]: Store the new restaurant_id for the next steps
SET @davids_restaurant_id = (SELECT restaurant_id FROM eats.restaurant WHERE owner_user_id = @david_user_id LIMIT 1);

-- [Demo]: Verify that the restaurant AND its physical address were created
SELECT r.restaurant_id, r.name AS restaurant_name, r.is_open, a.address, a.postal_code
FROM eats.restaurant r
JOIN eats.address a ON r.restaurant_id = a.restaurant_id
WHERE r.restaurant_id = @davids_restaurant_id;

-- ------------------------------------------------------------------------------
-- STEP 3: Update Restaurant Status (Go Live)
-- ------------------------------------------------------------------------------
-- David has finished setting up the physical store and switches his status to ONLINE.
CALL sp_update_restaurant(
    @davids_restaurant_id, 
    @david_user_id, 
    'David Burger Premium',  -- Upgrading the name
    'Premium handcrafted burgers and fries', 
    '68889999', 
    1  -- is_open = 1 (Online)
);

-- [Demo]: Show the updated name and that the store is now open (is_open = 1)
SELECT name, description, is_open FROM eats.restaurant WHERE restaurant_id = @davids_restaurant_id;

-- ------------------------------------------------------------------------------
-- STEP 4: Add Menu Items
-- ------------------------------------------------------------------------------
-- David starts adding his signature dishes to the menu.
CALL sp_add_menu_item(@davids_restaurant_id, @david_user_id, 'Classic Cheeseburger', '100% beef patty with cheddar cheese', 12.50);
CALL sp_add_menu_item(@davids_restaurant_id, @david_user_id, 'French Fries', 'Crispy potato fries with truffle oil', 6.50);
CALL sp_add_menu_item(@davids_restaurant_id, @david_user_id, 'Coca Cola', 'Chilled 500ml', 3.00);

-- [Demo]: Display David's full menu available for customers
SELECT menu_item_id, item_name, description, price, is_available 
FROM eats.menu_item 
WHERE restaurant_id = @davids_restaurant_id;

-- ------------------------------------------------------------------------------
-- STEP 4b: Validation (Permission Check)
-- ------------------------------------------------------------------------------
-- [Validation]: Can a normal customer (or another owner) modify David's menu?
-- Let's try to add a fake item using another user_id (e.g., user_id = 1)
-- EXPECTED OUTCOME: Will throw an Error "Permission Denied."

CALL sp_add_menu_item(@davids_restaurant_id, 1, 'Hacker Meal', 'Free food for everyone', 0.00);

-- ==============================================================================
-- END OF STORY 1
-- ==============================================================================