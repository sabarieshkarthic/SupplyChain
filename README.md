Supply Chain Management System
Overview
This project implements a supply chain management system using MySQL as the database backend, Flask with Python for the application logic, and HTML/CSS for the frontend. The system supports dealer and employee functionalities, including dealer signups, order placements, stock management, and shipment tracking.
Features

Dealer Module: Allows dealers to sign up with address-based latitude/longitude, view products with stock availability, place orders, and track shipments.
Employee Module: Enables employees to log in and restock products by selecting suppliers and distribution centers.
Order Processing: Calculates total purchase amount, assigns nearest distribution centers based on stock, and updates inventory.
Shipment Tracking: Updates delivery status based on packaging and transportation times.

Technologies Used

Backend: Python (Flask), MySQL
Frontend: HTML, CSS
Libraries: networkx for A* shortest path algorithm, geopy for geolocation

Implementation Details

A Algorithm for Shortest Distance: The A algorithm is utilized to determine the shortest path between dealers, distribution centers, and suppliers. This is implemented using the networkx library (nx.astar_path) to calculate optimal routes based on latitude and longitude coordinates, ensuring efficient assignment of the nearest location for order fulfillment and restocking.
Database Design: Includes tables for Suppliers, Products, DistributionCenters, Employees, Dealers, WarehouseInventory, Orders, Shipment, and DeliveryRoutes with appropriate relationships.
Stored Procedures and Triggers: MySQL stored procedures handle dealer signups and order placements, while triggers manage shipment status and stock updates.

Setup Instructions

Install required Python libraries: pip install flask mysql-connector-python networkx geopy.
Set up the MySQL database and run the provided SQL script to create tables and insert sample data.
Configure the Flask application with database credentials.
Run the Flask app: python app.py.

Usage

Access the web interface and choose between Dealer or Employee options.
Dealers can sign up, log in, place orders, and view shipment details.
Employees can log in and restock products by selecting suppliers and distribution centers.


