# Supply Chain Management System

This is a Flask-based web application for managing a supply chain, allowing dealers to place orders and employees to manage inventory restocking. The application integrates with a MySQL database and uses geospatial data for distance calculations and transportation cost estimation.

## Features

- **Dealer Features**:
  - Signup with geolocation-based address validation.
  - Login and session management.
  - View available products with stock and pricing.
  - Place orders with automatic distribution center assignment based on proximity.
  - View order history and detailed order status, including shipment tracking.

- **Employee Features**:
  - Login and session management.
  - Restock products at distribution centers with transportation cost calculation.
  - View available products and distribution centers.

- **Geospatial Integration**:
  - Uses `geopy` for address geocoding.
  - Uses `osmnx` and `networkx` for calculating driving distances between locations.

- **Database**:
  - MySQL database with stored procedures and triggers for managing orders, shipments, and inventory.
  - Supports complex queries for order details and shipment status.

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

## Notes

- **Geospatial Calculations**:
  - The application uses OpenStreetMap data via `osmnx` to calculate driving distances, which may require an internet connection.
  - Transportation costs are calculated based on distance: free for <25 km, $12/km for 25-100 km, and $20/km for >100 km.

- **Security**:
  - Passwords are stored as plain text in the sample database for simplicity. In a production environment, use proper hashing (e.g., `bcrypt`).
  - Session management uses Flask’s built-in session with a 30-minute timeout.

- **Sample Data**:
  - The database includes sample suppliers, distribution centers, dealers, employees, products, and inventory for testing.

## Limitations

- **Geocoding**: Relies on Nominatim for address validation, which may fail for imprecise addresses.
- **Scalability**: The current setup is designed for small-scale use. For production, optimize database queries and add caching for geospatial data.
- **Error Handling**: Basic error messages are implemented; enhance for production use.

## Future Improvements

- Add input validation and sanitization.
- Implement secure password hashing.
- Add real-time shipment tracking with maps.
- Optimize geospatial queries with caching.
- Add user roles and permissions for finer access control.
