from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector
from geopy.geocoders import Nominatim
from decimal import Decimal
import datetime
import osmnx as ox
import networkx as nx

app = Flask(__name__)
app.secret_key = 'amskPSG'
app.permanent_session_lifetime = datetime.timedelta(minutes=30)

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',
    'database': 'DB_name'
}

def get_db_connection():
    return mysql.connector.connect(**db_config)


def calculate_distance(lat1, lon1, lat2, lon2):

    G = ox.graph_from_point((lat1, lon1), dist=100000000, network_type='drive')
    start_node = ox.distance.nearest_nodes(G, lon1, lat1)
    end_node = ox.distance.nearest_nodes(G, lon2, lat2)
    route = nx.astar_path(G, start_node, end_node, weight='length')
    length_m = nx.path_weight(G, route, weight='length')
    return route, length_m / 1000


def calculate_transportation_cost(distance):
    distance = Decimal(str(distance))
    if distance < 25:
        return Decimal('0')
    elif distance < 100:
        return Decimal('12') * distance
    else:
        return Decimal('20') * distance

def get_products_for_dealer():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ProductID, ProductName FROM Products")
    products = cursor.fetchall()
    product_list = []
    for pid, pname in products:
        cursor.callproc('GetStockAvailability', [pid])
        stock_result = next(cursor.stored_results(), None)
        stock = stock_result.fetchone()[0] if stock_result else 0
        cursor.callproc('GetProductPrice', [pid])
        price_result = next(cursor.stored_results(), None)
        price = price_result.fetchone()[0] if price_result else Decimal('0.00')
        product_list.append((pname, price, stock, pid))
    cursor.close()
    conn.close()
    return product_list

def get_products_for_employee():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ProductID, ProductName FROM Products")
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return products

def get_centers():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CenterID, CenterName FROM DistributionCenters")
    centers = cursor.fetchall()
    cursor.close()
    conn.close()
    return centers

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/dealer')
def dealer_options():
    return render_template('dealer_options.html')

@app.route('/dealer/signup', methods=['GET', 'POST'])
def dealer_signup():
    if request.method == 'POST':
        dealer_name = request.form['dealer_name']
        address = request.form['address']
        contact_info = request.form['contact_info']
        password = request.form['password']
        
        geolocator = Nominatim(user_agent="scm_app")
        location = geolocator.geocode(address)
        if location:
            latitude = location.latitude
            longitude = location.longitude
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.callproc('AddDealer', [dealer_name, address, contact_info, latitude, longitude, password])
            conn.commit()
            cursor.close()
            conn.close()
            return render_template('dealer_signup.html', message="Signup successful! Please login.")
        else:
            return render_template('dealer_signup.html', message="Invalid address.")
    return render_template('dealer_signup.html')

@app.route('/dealer/login', methods=['GET', 'POST'])
def dealer_login():
    if request.method == 'POST':
        contact_info = request.form['contact_info']
        password = request.form['password']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DealerID, DealerName FROM Dealers WHERE ContactInfo = %s AND Password = %s", (contact_info, password))
        dealer = cursor.fetchone()
        cursor.close()
        conn.close()
        if dealer:
            session.permanent = True  
            session['dealer_id'] = dealer[0]
            session['dealer_name'] = dealer[1]
            print("Session set in dealer_login:", session)  
            return redirect(url_for('dealer_dashboard'))
        return render_template('dealer_login.html', message="Invalid credentials.")
    return render_template('dealer_login.html')

@app.route('/dealer/logout')
def dealer_logout():
    session.clear()
    print("Session cleared in dealer_logout:", session)  
    return redirect(url_for('dealer_login'))

@app.route('/dealer/dashboard')
def dealer_dashboard():
    if 'dealer_id' not in session:
        return redirect(url_for('dealer_login'))
    return render_template('dealer_dashboard.html', dealer_name=session['dealer_name'])

@app.route('/dealer/orders', methods=['GET', 'POST'])
def dealer_orders():
    print("Session in dealer_orders:", session)  
    if 'dealer_id' not in session:
        return redirect(url_for('dealer_login'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.callproc('GetDealerOrders', [session['dealer_id']])
    orders = [row for row in cursor.stored_results()][0].fetchall()
    print("Orders:", orders) 
    order_details = None
    if request.method == 'POST' and 'order_id' in request.form:
        order_id = int(request.form['order_id'])
        cursor.callproc('GetOrderDetails', [order_id])
        products = [row for row in cursor.stored_results()][0].fetchall()
        cursor.callproc('GetShipmentStatus', [order_id, datetime.date.today(), datetime.datetime.now().time()])
        shipment_status = [row for row in cursor.stored_results()][0].fetchone()[0]
        cursor.execute("SELECT Status FROM Orders WHERE OrderID = %s", (order_id,))
        order_status = cursor.fetchone()[0]
        cursor.execute("""
            SELECT dc.Location, d.Address
            FROM Orders o
            JOIN Shipments s ON o.OrderID = s.OrderID
            JOIN DeliveryRoutes dr ON s.ShipmentID = dr.ShipmentID
            JOIN DistributionCenters dc ON dr.SourceCenterID = dc.CenterID
            JOIN Dealers d ON o.DealerID = d.DealerID
            WHERE o.OrderID = %s
        """, (order_id,))
        addresses = cursor.fetchone()
        print(f"Order ID: {order_id}, Addresses: {addresses}") 
        if addresses:
            order_details = {
                'order_id': order_id,
                'products': products,
                'shipment_status': shipment_status,
                'order_status': order_status,
                'from_address': addresses[0],
                'to_address': addresses[1]
            }
        else:
            order_details = {
                'order_id': order_id,
                'products': products,
                'shipment_status': shipment_status,
                'order_status': order_status,
                'from_address': 'Not available',
                'to_address': 'Not available'
            }
    cursor.close()
    conn.close()
    return render_template('dealer_orders.html', orders=orders, order_details=order_details)

@app.route('/dealer/order/<int:order_id>', methods=['POST'])
def order_details(order_id):
    print("Session in order_details:", session) 
    if 'dealer_id' not in session:
        return redirect(url_for('dealer_login'))
    from werkzeug.datastructures import ImmutableMultiDict
    request.form = ImmutableMultiDict([('order_id', str(order_id))])
    request.method = 'POST'
    return dealer_orders()

@app.route('/dealer/products')
def list_products():
    if 'dealer_id' not in session:
        return redirect(url_for('dealer_login'))
    products = get_products_for_dealer()
    return render_template('list_products.html', products=products, total_amount=Decimal('0.00'))

@app.route('/dealer/place_order', methods=['POST'])
def place_order():
    if 'dealer_id' not in session:
        return redirect(url_for('dealer_login'))
    selected_products = request.form.getlist('selected_products')
    if not selected_products:
        return render_template('list_products.html', products=get_products_for_dealer(), message="No products selected.", total_amount=Decimal('0.00'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Latitude, Longitude FROM Dealers WHERE DealerID = %s", (session['dealer_id'],))
    dealer_loc = cursor.fetchone()
    
    orders = {}
    for pid in selected_products:
        qty = int(request.form[f'quantity_{pid}'])
        cursor.callproc('GetStockAvailability', [int(pid)])
        stock_result = next(cursor.stored_results(), None)
        stock = stock_result.fetchone()[0] if stock_result else 0
        if qty > stock:
            return render_template('list_products.html', products=get_products_for_dealer(), message=f"Not enough stock for Product ID {pid}.", total_amount=Decimal('0.00'))
        
        cursor.callproc('GetProductPrice', [int(pid)])
        price_result = next(cursor.stored_results(), None)
        price = price_result.fetchone()[0] if price_result else Decimal('0.00')
        purchase_amount = price * qty
        print(f"Product ID {pid}: qty={qty}, price={price}, purchase_amount={purchase_amount}")
        
        cursor.execute("""
        SELECT wi.CenterID, wi.StockQuantity, dc.Latitude, dc.Longitude
        FROM WarehouseInventory wi
        JOIN DistributionCenters dc ON wi.CenterID = dc.CenterID
        WHERE wi.ProductID = %s AND wi.StockQuantity > 0
        """, (pid,))
        centers = cursor.fetchall()
        centers = sorted(centers, key=lambda x: calculate_distance(dealer_loc[0], dealer_loc[1], x[2], x[3]))
        
        remaining_qty = qty
        for center in centers:
            center_id, stock_qty, lat, lon = center
            if remaining_qty <= 0:
                break
            qty_to_take = min(remaining_qty, stock_qty)
            if center_id not in orders:
                distance = calculate_distance(dealer_loc[0], dealer_loc[1], lat, lon)
                trans_cost = calculate_transportation_cost(distance)
                cursor.execute("INSERT INTO Orders (DealerID, TotalAmount, Status, OrderDate, OrderTime) VALUES (%s, 0, 'incomplete', CURDATE(), CURTIME())", (session['dealer_id'],))
                order_id = cursor.lastrowid
                orders[center_id] = {'order_id': order_id, 'items': [], 'trans_cost': trans_cost, 'distance': distance}
            order = orders[center_id]
            order['items'].append((pid, qty_to_take, price))
            remaining_qty -= qty_to_take
        
        if remaining_qty > 0:
            return render_template('list_products.html', products=get_products_for_dealer(), message=f"Not enough stock across centers for Product ID {pid}.", total_amount=Decimal('0.00'))
    
    overall_total = Decimal('0.00')
    for center_id, order in orders.items():
        order_id = order['order_id']
        purchase_cost = sum(item[1] * item[2] for item in order['items'])
        trans_cost = order['trans_cost']
        total = purchase_cost + trans_cost
        print(f"Order ID {order_id}: Purchase Cost = ${purchase_cost:.2f}, Transportation Cost = ${trans_cost:.2f}, Total Cost = ${total:.2f}")
        cursor.execute("UPDATE Orders SET TotalAmount = %s WHERE OrderID = %s", (total, order_id))
        cursor.execute("INSERT INTO Shipments (OrderID, ShipmentDate, ShipmentTime, DeliveryStatus) VALUES (%s, CURDATE(), CURTIME(), 'Packaging')", (order_id,))
        shipment_id = cursor.lastrowid
        print(f"Created Shipment: OrderID={order_id}, ShipmentID={shipment_id}")  # Debug: Confirm shipment creation
        cursor.execute("INSERT INTO DeliveryRoutes (SourceCenterID, DestinationDealerID, ShipmentID, Distance, EstimatedTime) VALUES (%s, %s, %s, %s, %s)",
                       (center_id, session['dealer_id'], shipment_id, order['distance'], 2 + (order['distance'] / 60)))
        print(f"Inserted into DeliveryRoutes: SourceCenterID={center_id}, DestinationDealerID={session['dealer_id']}, ShipmentID={shipment_id}")  # Debug: Confirm delivery route
        for pid, qty, price in order['items']:
            cursor.execute("INSERT INTO OrderDetails (OrderID, ShipmentID, ProductID, Quantity, Price) VALUES (%s, %s, %s, %s, %s)",
                           (order_id, shipment_id, pid, qty, price))
        overall_total += total
    
    conn.commit()
    cursor.close()
    conn.close()
    return render_template('list_products.html', products=get_products_for_dealer(), message="Order placed successfully!", total_amount=overall_total)


@app.route('/employee/login', methods=['GET', 'POST'])
def employee_login():
    if request.method == 'POST':
        employee_name = request.form['employee_name']
        password = request.form['password']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT EmployeeID, EmployeeName FROM Employees WHERE EmployeeName = %s AND Password = %s", (employee_name, password))
        employee = cursor.fetchone()
        cursor.close()
        conn.close()
        if employee:
            session.permanent = True 
            session['employee_id'] = employee[0]
            session['employee_name'] = employee[1]
            print("Session set for employee:", session)  
            return redirect(url_for('employee_dashboard'))
        return render_template('employee_login.html', message="Invalid credentials.")
    return render_template('employee_login.html')

@app.route('/employee/dashboard')
def employee_dashboard():
    if 'employee_id' not in session:
        return redirect(url_for('employee_login'))
    products = get_products_for_employee()
    centers = get_centers()
    return render_template('employee_dashboard.html', employee_name=session['employee_name'], products=products, centers=centers)

@app.route('/employee/restock', methods=['POST'])
def restock():
    if 'employee_id' not in session:
        return redirect(url_for('employee_login'))
    product_id = int(request.form['product_id'])
    center_id = int(request.form['center_id'])
    quantity = int(request.form['quantity'])
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.SupplierID, s.Latitude, s.Longitude 
        FROM Products p 
        JOIN Suppliers s ON p.SupplierID = s.SupplierID 
        WHERE p.ProductID = %s
    """, (product_id,))
    supplier = cursor.fetchone()
    cursor.execute("SELECT Latitude, Longitude FROM DistributionCenters WHERE CenterID = %s", (center_id,))
    center_loc = cursor.fetchone()
    
    distance = calculate_distance(supplier[1], supplier[2], center_loc[0], center_loc[1])
    trans_cost = calculate_transportation_cost(distance)
    cursor.callproc('RestockProduct', [session['employee_id'], product_id, center_id, quantity])
    conn.commit()
    cursor.close()
    conn.close()
    return render_template('employee_dashboard.html', employee_name=session['employee_name'], 
                           products=get_products_for_employee(), centers=get_centers(),
                           message=f"Restocked from Supplier ID {supplier[0]} with transportation cost ${trans_cost:.2f}")

if __name__ == '__main__':

    app.run(debug=True)
