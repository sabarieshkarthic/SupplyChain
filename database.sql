CREATE DATABASE scm;
USE scm;

CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100),
    Location VARCHAR(255),
    ContactInfo VARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Weight DECIMAL(10,2),
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE DistributionCenters (
    CenterID INT AUTO_INCREMENT PRIMARY KEY,
    CenterName VARCHAR(100),
    Location VARCHAR(255),
    ContactInfo VARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

CREATE TABLE Dealers (
    DealerID INT AUTO_INCREMENT PRIMARY KEY,
    DealerName VARCHAR(100),
    Address VARCHAR(255),
    ContactInfo VARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Password VARCHAR(255)
);

CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Role VARCHAR(50),
    Password VARCHAR(255),
    CenterID INT,
    FOREIGN KEY (CenterID) REFERENCES DistributionCenters(CenterID)
);

CREATE TABLE WarehouseInventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    CenterID INT,
    ProductID INT,
    StockQuantity INT,
    FOREIGN KEY (CenterID) REFERENCES DistributionCenters(CenterID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    UNIQUE (CenterID, ProductID)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    DealerID INT,
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(20),
    OrderDate DATE,
    OrderTime TIME,
    FOREIGN KEY (DealerID) REFERENCES Dealers(DealerID)
);

CREATE TABLE Shipments (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ShipmentDate DATE,
    ShipmentTime TIME,
    DeliveryStatus VARCHAR(20),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE DeliveryRoutes (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    SourceCenterID INT,
    DestinationDealerID INT,
    ShipmentID INT,
    Distance DECIMAL(10,2),
    EstimatedTime DECIMAL(10,2),
    FOREIGN KEY (SourceCenterID) REFERENCES DistributionCenters(CenterID),
    FOREIGN KEY (DestinationDealerID) REFERENCES Dealers(DealerID),
    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ShipmentID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE RestockEvents (
    RestockID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    ProductID INT,
    CenterID INT,
    SupplierID INT,
    Quantity INT,
    RestockDate DATE,
    RestockTime TIME,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CenterID) REFERENCES DistributionCenters(CenterID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Insert sample data for Suppliers
INSERT INTO Suppliers (SupplierName, Location, ContactInfo, Latitude, Longitude) VALUES
('ElectroMart Pvt Ltd', 'Mumbai', 'contact@electromart.com', 19.0800, 72.8800),
('Tech Distributors Ltd', 'Mumbai', 'contact@techdist.com', 19.0850, 72.8850),
('Innovate Supplies', 'Delhi', 'contact@innovatesup.com', 28.7100, 77.1100),
('Alpha Wholesalers', 'Delhi', 'contact@alphawholesale.com', 28.7150, 77.1150),
('Silicon Valley Traders', 'Bangalore', 'contact@svtraders.com', 12.9750, 77.5990),
('Digital Hub Supplies', 'Bangalore', 'contact@digitalhub.com', 12.9800, 77.6040),
('Chennai Mega Supplies', 'Chennai', 'contact@chennaimega.com', 13.0900, 80.2750),
('South India Traders', 'Chennai', 'contact@southindia.com', 13.0950, 80.2800),
('Kolkata Trade Corp', 'Kolkata', 'contact@kolkatatrade.com', 22.5800, 88.3700),
('East Star Suppliers', 'Kolkata', 'contact@eaststar.com', 22.5850, 88.3750);

INSERT INTO DistributionCenters (CenterName, Location, ContactInfo, Latitude, Longitude) VALUES
('Mumbai Logistics Hub', 'Mumbai', 'contact@mumbailogistics.com', 19.1000, 72.8900),
('Delhi Cargo Point', 'Delhi', 'contact@delhicargo.com', 28.7200, 77.1200),
('Bangalore Freight Zone', 'Bangalore', 'contact@bengaluruftz.com', 12.9900, 77.6100),
('Chennai Supply Chain Hub', 'Chennai', 'contact@chennaisupply.com', 13.1050, 80.2850),
('Kolkata Distribution Point', 'Kolkata', 'contact@kolkatadist.com', 22.5950, 88.3800);

INSERT INTO Dealers (DealerName, Address, ContactInfo, Latitude, Longitude, Password) VALUES
('FastElectronics Mumbai', 'Sector 5, Mumbai', 'contact@fastelec.com', 19.1100, 72.9000, 'dealerpass1'),
('NextGen Mumbai', 'Sector 12, Mumbai', 'contact@nextgenmumbai.com', 19.1150, 72.9050, 'dealerpass2'),
('CapitalTech Delhi', 'Block C, Delhi', 'contact@capitaltech.com', 28.7300, 77.1300, 'dealerpass3'),
('UrbanTech Delhi', 'Block F, Delhi', 'contact@urbantechdelhi.com', 28.7350, 77.1350, 'dealerpass4'),
('PrimeTech Bangalore', 'MG Road, Bangalore', 'contact@primetech.com', 12.9950, 77.6150, 'dealerpass5'),
('TechExpress Bangalore', 'Whitefield, Bangalore', 'contact@techexpress.com', 13.0000, 77.6200, 'dealerpass6'),
('SouthTech Chennai', 'T Nagar, Chennai', 'contact@southtech.com', 13.1150, 80.2950, 'dealerpass7'),
('MegaStore Chennai', 'Velachery, Chennai', 'contact@megastore.com', 13.1200, 80.3000, 'dealerpass8'),
('EastElectronics Kolkata', 'Salt Lake, Kolkata', 'contact@eastelec.com', 22.6050, 88.3900, 'dealerpass9'),
('DigitalHouse Kolkata', 'Park Street, Kolkata', 'contact@digitalhouse.com', 22.6100, 88.3950, 'dealerpass10');

INSERT INTO Employees (EmployeeName, Role, Password, CenterID) VALUES
('AAA', 'Manager', 'emp123', 1),
('BBB', 'Staff', 'emp123', 1),
('CCC', 'Manager', 'emp123', 2),
('DDD', 'Staff', 'emp123', 2),
('EEE', 'Manager', 'emp123', 3),
('FFF', 'Staff', 'emp123', 3),
('GGG', 'Manager', 'emp123', 4),
('HHH', 'Staff', 'emp123', 4),
('III', 'Manager', 'emp123', 5),
('JJJ', 'Staff', 'emp123', 5);

INSERT INTO Products (ProductName, Category, Price, Weight, SupplierID) VALUES
('Laptop', 'Electronics', 1000.00, 2.5, 1),
('Smartphone', 'Electronics', 500.00, 0.3, 2),
('Tablet', 'Electronics', 300.00, 0.5, 3),
('Monitor', 'Electronics', 200.00, 5.0, 4),
('Keyboard', 'Accessories', 50.00, 0.8, 5),
('Mouse', 'Accessories', 20.00, 0.1, 6),
('Printer', 'Electronics', 150.00, 4.0, 7),
('Scanner', 'Electronics', 100.00, 3.0, 8),
('Projector', 'Electronics', 400.00, 2.0, 9),
('Speaker', 'Accessories', 80.00, 1.5, 10);

INSERT INTO WarehouseInventory (CenterID, ProductID, StockQuantity) VALUES
(1, 1, 10), (1, 2, 20), (1, 3, 15), (1, 4, 0), (1, 5, 30),
(2, 2, 25), (2, 3, 10), (2, 4, 20), (2, 5, 0), (2, 6, 15),
(3, 3, 30), (3, 4, 10), (3, 5, 20), (3, 6, 0), (3, 7, 25),
(4, 4, 15), (4, 5, 30), (4, 6, 10), (4, 7, 0), (4, 8, 20),
(5, 5, 25), (5, 6, 15), (5, 7, 30), (5, 8, 0), (5, 9, 10);

DELIMITER //

CREATE PROCEDURE GetStockAvailability(IN product_id INT)
BEGIN
    SELECT IFNULL(SUM(StockQuantity), 0) AS TotalStock
    FROM WarehouseInventory
    WHERE ProductID = product_id;
END //

CREATE PROCEDURE GetProductPrice(IN product_id INT)
BEGIN
    SELECT Price
    FROM Products
    WHERE ProductID = product_id;
END //

CREATE PROCEDURE AddDealer(
    IN dealer_name VARCHAR(100),
    IN address VARCHAR(255),
    IN contact_info VARCHAR(100),
    IN latitude DECIMAL(9,6),
    IN longitude DECIMAL(9,6),
    IN password VARCHAR(255)
)
BEGIN
    INSERT INTO Dealers (DealerName, Address, ContactInfo, Latitude, Longitude, Password)
    VALUES (dealer_name, address, contact_info, latitude, longitude, password);
END //

CREATE PROCEDURE GetDealerOrders(IN dealer_id INT)
BEGIN
    SELECT OrderID, Status FROM Orders WHERE DealerID = dealer_id;
END //

CREATE PROCEDURE GetOrderDetails(IN order_id INT)
BEGIN
    SELECT p.ProductName, od.Quantity, od.Price
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE od.OrderID = order_id;
END //

CREATE PROCEDURE GetShipmentStatus(IN order_id INT, IN `current_date` DATE, IN `current_time` TIME)
BEGIN
    DECLARE shipment_date DATE;
    DECLARE shipment_time TIME;
    DECLARE delivery_status VARCHAR(20);
    DECLARE order_date DATE;
    DECLARE order_time TIME;
    DECLARE distance DECIMAL(10,2);
    DECLARE trans_time DECIMAL(10,2);

    SELECT ShipmentDate, ShipmentTime, DeliveryStatus, o.OrderDate, o.OrderTime, dr.Distance
    INTO shipment_date, shipment_time, delivery_status, order_date, order_time, distance
    FROM Shipments s
    JOIN Orders o ON s.OrderID = o.OrderID
    JOIN DeliveryRoutes dr ON s.ShipmentID = dr.ShipmentID
    WHERE s.OrderID = order_id
    LIMIT 1;

    SET trans_time = distance / 60; 
    IF `current_date` >= order_date AND `current_time` > ADDTIME(order_time, '2:00:00') THEN
        IF `current_time` > ADDTIME(order_time, SEC_TO_TIME((2 * 3600) + (trans_time * 3600))) THEN
            SET delivery_status = 'Delivered';
            UPDATE Orders SET Status = 'completed' WHERE OrderID = order_id;
        ELSE
            SET delivery_status = 'Shipping';
        END IF;
    ELSE
        SET delivery_status = 'Packaging';
    END IF;
    UPDATE Shipments SET DeliveryStatus = delivery_status WHERE OrderID = order_id;
    SELECT delivery_status;
END //

CREATE PROCEDURE RestockProduct(
    IN employee_id INT,
    IN product_id INT,
    IN center_id INT,
    IN quantity INT
)
BEGIN
    DECLARE supplier_id INT;
    SELECT SupplierID INTO supplier_id FROM Products WHERE ProductID = product_id;
    INSERT INTO RestockEvents (EmployeeID, ProductID, CenterID, SupplierID, Quantity, RestockDate, RestockTime)
    VALUES (employee_id, product_id, center_id, supplier_id, quantity, CURDATE(), CURTIME());
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterRestockInsert AFTER INSERT ON RestockEvents
FOR EACH ROW
BEGIN
    INSERT INTO WarehouseInventory (CenterID, ProductID, StockQuantity)
    VALUES (NEW.CenterID, NEW.ProductID, NEW.Quantity)
    ON DUPLICATE KEY UPDATE StockQuantity = StockQuantity + NEW.Quantity;
END //

CREATE TRIGGER AfterOrderDetailInsert AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE center_id INT;
    SELECT SourceCenterID INTO center_id
    FROM DeliveryRoutes
    WHERE ShipmentID = NEW.ShipmentID;
    UPDATE WarehouseInventory
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE CenterID = center_id AND ProductID = NEW.ProductID;
END //

CREATE TRIGGER AfterShipmentUpdate AFTER UPDATE ON Shipments
FOR EACH ROW
BEGIN
    DECLARE all_delivered INT;
    SELECT COUNT(*) INTO all_delivered
    FROM Shipments
    WHERE OrderID = NEW.OrderID AND DeliveryStatus != 'Delivered';
    IF all_delivered = 0 THEN
        UPDATE Orders SET Status = 'completed' WHERE OrderID = NEW.OrderID;
    END IF;
END //
DELIMITER //
CREATE PROCEDURE GetDealerOrders(IN dealer_id INT)
BEGIN
    SELECT OrderID, Status, TotalAmount
    FROM Orders
    WHERE DealerID = dealer_id;
END //
DELIMITER ;
select * from OrderDetails;
SELECT * FROM Orders WHERE DealerID = 1;
