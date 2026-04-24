# Eats - Database Project Scripts

## Overview
This repository is created for the NTU Course IN6205 (Database Systems) group project. It serves as the central storage for all our database SQL scripts, including the initial environment setup and the final presentation demo scripts.

## How to Reproduce the Demo
To fully replicate our database environment and run the presentation demo, please follow these steps exactly in order:

### Step 1: Environment Setup
* Run `Eats_setup.sql` first. 
* *What this does:* This script will automatically create the database schema, build all necessary tables, configure pre-setup constraints, and inject realistic dummy data for testing.

### Step 2: Run the Demo Stories
* Once the setup is complete, execute our Demo SQL scripts. 
* *What this does:* These scripts will walk you through the complete business logic, following our 6 core business flows.

---

## The 6 Demo Stories: Step-by-Step Walkthrough

**1️⃣ Story 1: Restaurant Onboarding & Menu Management**
* **The Story:** David registers as a business partner, sets up his restaurant "David Burger", and manages his menu.
* **Tech Highlights:**
  * **Role Assignment:** Linking David strictly to the "Restaurant Owner" role.
  * **Menu Upserting:** Using stored procedures to safely insert and update menu items and descriptions.

**2️⃣ Story 2: New Customer Onboarding & Discovery**
* **The Story:** Alice downloads the app, registers as a Customer, and searches for something to eat.
* **Tech Highlights:**
  * **RBAC Verification:** Joining `user`, `role`, and `address` tables to prove Alice's profile completeness.
  * **Advanced Relational Search:** Running a live injection test to prove our search engine uses `LEFT JOIN` to catch keywords across both `restaurant` descriptions and `menu_item` details, not just restaurant names.

**3️⃣ Story 3: Cart Management & Order Processing**
* **The Story:** Alice builds her cart, encounters a business rule conflict, resolves it, and checks out.
* **Tech Highlights:**
  * **Business Rule Constraints:** The database actively blocks Alice from mixing items from different restaurants (Error 45000).
  * **The Master Transaction:** Executing `sp_process_checkout`—a single atomic network call that creates the order, snapshots prices, processes payment, and auto-assigns the least busy rider.

**4️⃣ Story 4: The Order and Delivery Lifecycle**
* **The Story:** The restaurant prepares the food, and the assigned rider completes the delivery.
* **Tech Highlights:**
  * **Composite Index Optimization:** Utilizing custom indexes (e.g., `idx_order_restaurant_status` and `idx_delivery_driver_status`) to prevent full-table scans and ensure lightning-fast dashboard loading for both the Restaurant and the Rider.
  * **State Transitions:** Safely updating statuses from 'Assigned' to 'Picked Up' and 'Delivered'.

**5️⃣ Story 5: Review & Rating**
* **The Story:** Alice leaves a review for her delivered meal.
* **Tech Highlights:**
  * **Database Firewalls:** Demonstrating `sp_add_review` to prove the system actively rejects reviews if the user doesn't own the order, or if the order hasn't been officially 'Delivered'.

**6️⃣ Story 6: Reports**
* **The Story:** The platform management team reviews business intelligence dashboards.
* **Tech Highlights:**
  * **Dynamic Time-Sync:** Running our dynamic utility script to instantly shift historical baseline data to the exact current execution month.
  * **Business Intelligence Views:** Querying pre-compiled Views (Monthly Sales, Peak Hours, VIP Customers) to showcase how we encapsulate complex multi-table JOINs at the database level.
