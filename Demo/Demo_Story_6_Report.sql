USE `eats`;

-- ------------------------------------------------------------------------------
-- FINAL STEP: Reportings
-- ------------------------------------------------------------------------------
-- [Explaination]: 
-- "To show how our reporting works in the real world,
-- we used a Python script with the 'Faker' library to generate a massive amount of dummy data. 
-- This allows us to simulate years of real transactions"

-- ------------------------------------------------------------------------------
-- 1. VIEW: Monthly Item Sales
-- ------------------------------------------------------------------------------
-- [Explaination]:
-- This report shows restaurant owners their best-selling items every month. 
-- It helps them decide what dishes to promote. 
-- ------------------------------------------------------------------------------
SELECT * FROM eats.vw_monthly_item_sales
ORDER BY sales_year DESC, sales_month DESC, restaurant_id, total_quantity_sold DESC;

-- [Explaination]:
-- "If an owner just wants to see their total revenue for a specific month"
-- "The SP pull data from the view above directly"
CALL sp_report_restaurant_revenue(1, 2026, 4);

-- ------------------------------------------------------------------------------
-- 2. VIEW: Peak Ordering Hours
-- ------------------------------------------------------------------------------
-- [Explaination]:
-- "By looking at the order times, we can see exactly when the app is the most busy. 
-- So restaurants can prepare for rush hours, and platform can know when to schedule more riders."
-- ------------------------------------------------------------------------------
SELECT * FROM eats.vw_peak_ordering_hours 
ORDER BY hour_of_day ASC;

-- ------------------------------------------------------------------------------
-- 3. VIEW: Restaurant Ratings
-- ------------------------------------------------------------------------------
-- [Explaination]:
-- "It calculates a real-time average of all customer reviews. 
-- for quality control — making sure the best restaurants get the most visibility on the landing page."
-- ------------------------------------------------------------------------------
SELECT * FROM eats.vw_restaurant_ratings 
ORDER BY average_rating DESC, total_reviews DESC;

-- ------------------------------------------------------------------------------
-- 4. VIEW: Rider Performance
-- ------------------------------------------------------------------------------
-- [Explaination]:
-- "This tracks how many deliveries each rider has completed. 
-- It helps management reward the hardest workers."
-- ------------------------------------------------------------------------------
SELECT * FROM eats.vw_rider_performance 
ORDER BY total_completed_deliveries DESC;

-- ------------------------------------------------------------------------------
-- 5. VIEW: VIP Customers
-- ------------------------------------------------------------------------------
-- [Explaination]:
-- "This identifies the most loyal users who spend the most money. 
-- The marketing team can use this list to send out special vouchers and keep our best customers happy."
-- ------------------------------------------------------------------------------
SELECT * FROM eats.vw_vip_customers 
ORDER BY lifetime_amount_spent DESC;