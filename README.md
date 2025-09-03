# Supply Chain Management System

This is a Flask-based logistics platform enabling dealers to sign up, browse stock, place multi-item orders, and track shipments, while employees manage real-time restocking. Designed a 15-table MySQL schema with stored procedures and triggers to automate inventory, orders, shipments, and delivery routes. Integrated geospatial distance calculations with the 
A* Algorithm, a tiered transportation pricing model, and optimized order-splitting logic to minimize costs.

## Features

- **Dealer Features**:
  - Secure signup with geolocation-based address validation.
  - Browse products with real-time stock levels and pricing.
  - Place multi-item orders, automatically assigned to the nearest distribution center with available inventory.
  - Track order history, shipment status, and delivery routes.

- **Employee Features**:
  - Secure login and role-based access.
  - Manage warehouse inventory and record restocking events.
  - Calculate transportation costs dynamically based on distance tiers.
  - View and manage distribution centers and product availability.

- **Geospatial Integration**:
  - Address geocoding powered by `geopy`.
  - Driving distances and shortest paths computed using the `A* algorithm` on OpenStreetMap road networks.
  - Order allocation optimized to reduce transportation costs and delivery times.

- **Database**:
  - MySQL database with stored procedures and triggers for managing orders, shipments, and inventory.
  - Supports complex queries for order details and shipment status.



## Database Schema

The database (`scm`) includes the following tables:
- **Suppliers**: Stores supplier details (name, location, contact, coordinates).
- **Products**: Stores product details (name, category, price, weight, supplier).
- **DistributionCenters**: Stores distribution center details (name, location, contact, coordinates).
- **Dealers**: Stores dealer details (name, address, contact, coordinates, password).
- **Employees**: Stores employee details (name, role, password, center).
- **WarehouseInventory**: Tracks product stock at distribution centers.
- **Orders**: Stores order details (dealer, total amount, status, date, time).
- **Shipments**: Tracks shipment details (order, date, time, delivery status).
- **DeliveryRoutes**: Stores route details (source center, destination dealer, shipment, distance, estimated time).
- **OrderDetails**: Stores order item details (order, shipment, product, quantity, price).
- **RestockEvents**: Logs restocking events (employee, product, center, supplier, quantity, date, time).

Stored procedures and triggers handle tasks like adding dealers, retrieving order details, updating shipment status, and managing inventory.


## Notes

- **Geospatial Calculations**:
  - The application uses OpenStreetMap data via `osmnx` to calculate driving distances, which may require an internet connection.
  - Transportation costs are calculated based on distance: free for <25 km, $12/km for 25-100 km, and $20/km for >100 km.

- **Sample Data**:
  - The database includes sample suppliers, distribution centers, dealers, employees, products, and inventory for testing.

## Prerequisites

- Python 3.8+
- MySQL Server
- Required Python libraries (install via `pip`):
  ```bash
  pip install flask mysql-connector-python geopy osmnx networkx
  ```

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. **Set Up MySQL Database**:
   - Create a database named `scm` and execute the SQL script provided in the code to create tables, insert sample data, and define stored procedures and triggers.
   - Update the `db_config` dictionary in the Flask application with your MySQL credentials:
     ```python
     db_config = {
         'host': 'localhost',
         'user': 'your_username',
         'password': 'your_password',
         'database': 'scm'
     }
     ```

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the Application**:
   ```bash
   python app.py
   ```
   The application will run in debug mode at `http://127.0.0.1:5000`.

   
   ## Usage

1. **Access the Application**:
   - Open `http://127.0.0.1:5000` in a browser.
   - Navigate to `/dealer` for dealer options or `/employee/login` for employee access.

2. **Dealer Workflow**:
   - **Signup**: Provide name, address, contact info, and password at `/dealer/signup`.
   - **Login**: Use contact info and password at `/dealer/login`.
   - **Dashboard**: View options at `/dealer/dashboard`.
   - **Products**: Browse and select products at `/dealer/products`.
   - **Place Order**: Submit order with quantities; the system assigns distribution centers based on proximity and stock.
   - **Orders**: View order history and details at `/dealer/orders`.

3. **Employee Workflow**:
   - **Login**: Use name and password at `/employee/login`.
   - **Dashboard**: View products and centers at `/employee/dashboard`.
   - **Restock**: Select product, center, and quantity to restock, with calculated transportation costs.
