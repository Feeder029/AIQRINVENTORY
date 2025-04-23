from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import itemqr
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Database connections
def get_connection(database_name):
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database=database_name
    )

def fetch_records(conn, query):
    """Execute query and return results as list of dictionaries"""
    cursor = conn.cursor()
    cursor.execute(query)
    columns = [column[0] for column in cursor.description]
    results = [dict(zip(columns, row)) for row in cursor.fetchall()]
    cursor.close()
    return results

def get_image_path(item_number, image_url):
    """Generate the local file path for the image"""
    # Extract filename from URL if it exists
    if image_url:
        filename = os.path.basename(image_url)
    else:
        filename = "default.jpg"  # Default filename if URL is empty
        
    # Format the path according to the specified structure
    return f"http://localhost/AIQRINVENTORY/Advance_IMS/data/item_images/{item_number}/{filename}"

def add_item(item, qrpath, qrcode):
    """Add item to AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            # Generate the image path
            image_path = get_image_path(item['itemNumber'], item['imageURL'])
            
            query = """
                INSERT INTO item (
                    I_LegacyCode, I_Name, I_Discount, I_UnitPrice, 
                    I_Status, I_Stock, I_Description, `I_QRCode`, `I_QRPath`, `I_Image`
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            cursor.execute(query, (
                item['productID'], item['itemName'], item['discount'], 
                item['unitPrice'], item['status'], item['stock'], 
                item['description'], qrcode, qrpath, image_path
            ))
            
            conn.commit()
            print(f"Item {item['productID']} successfully inserted")
            
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def update_item(item, legacy_code):
    """Update existing item in AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            # Generate the image path
            image_path = get_image_path(item['itemNumber'], item['imageURL'])
            
            query = """
                UPDATE item 
                SET I_Name = %s,
                    I_Discount = %s,
                    I_UnitPrice = %s,
                    I_Status = %s,
                    I_Stock = %s,
                    I_Description = %s,
                    I_Image = %s,
                    I_LastUpdate = CURRENT_TIMESTAMP
                WHERE I_LegacyCode = %s
            """
            
            cursor.execute(query, (
                item['itemName'], 
                item['discount'], 
                item['unitPrice'], 
                item['status'], 
                item['stock'], 
                item['description'],
                image_path,
                legacy_code
            ))
            
            conn.commit()
            print(f"Item {legacy_code} successfully updated")
            
    except mysql.connector.Error as err:
        print(f"Update Error: {err}")

def synchronize_inventory():
    """Synchronize items from legacy database to AI inventory"""
    try:
        # Get legacy items
        legacy_conn = get_connection('shop_inventory')
        legacy_query = """
            SELECT productID, itemNumber, itemName, discount, stock, 
                   unitPrice, imageURL, status, description 
            FROM item
        """
        legacy_items = fetch_records(legacy_conn, legacy_query)
        legacy_conn.close()
        
        # Get current AI inventory items
        ai_conn = get_connection('ai_inventory')
        ai_query = """
            SELECT ItemID, I_LegacyCode, I_Name, I_Discount, I_UnitPrice, I_Status, 
                   I_Stock, I_Description, I_QRCode, I_QRPath, I_LastUpdate, 
                   I_Suggestion, I_SuggestedPrice 
            FROM item
        """
        ai_items = fetch_records(ai_conn, ai_query)
        ai_conn.close()
        
        # Convert AI items to a dictionary for easy access
        ai_items_dict = {str(item["I_LegacyCode"]): item for item in ai_items}
        
        items_added = 0
        items_updated = 0
        
        # Process all legacy items
        for legacy_item in legacy_items:
            legacy_code = str(legacy_item["productID"])
            
            if legacy_code not in ai_items_dict:
                # Item doesn't exist in AI inventory - add it
                qrpath, qrcode = itemqr.generate_qr(legacy_item["itemName"])
                add_item(legacy_item, qrpath, qrcode)
                items_added += 1
            else:
                # Item exists - check if it needs updating
                ai_item = ai_items_dict[legacy_code]
                
                # Check if any fields have changed
                needs_update = (
                    legacy_item["itemName"] != ai_item["I_Name"] or
                    float(legacy_item["discount"]) != float(ai_item["I_Discount"]) or
                    float(legacy_item["unitPrice"]) != float(ai_item["I_UnitPrice"]) or
                    legacy_item["status"] != ai_item["I_Status"] or
                    int(legacy_item["stock"]) != int(ai_item["I_Stock"]) or
                    legacy_item["description"] != ai_item["I_Description"]
                )
                
                if needs_update:
                    update_item(legacy_item, legacy_code)
                    items_updated += 1
        
        print(f"Synchronization completed: {items_added} items added, {items_updated} items updated")
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

def synchronize_customer():
    """Synchronize customers from legacy database to AI inventory"""
    try:
        # Get legacy customers
        legacy_conn = get_connection('shop_inventory')
        legacy_query = """
            SELECT `customerID`, `fullName`, `email`, `mobile`, `phone2`, `address`, `address2`, 
              `city`, `district`, `status`, `createdOn` 
            FROM `customer`
        """
        legacy_customer = fetch_records(legacy_conn, legacy_query)
        legacy_conn.close()
        
        # Get current AI inventory customers
        ai_conn = get_connection('ai_inventory')
        ai_query = """
            SELECT `CustomerID`, `CNNameID`, `CustomerAddressID`, `C_Email`, `C_Mobile`, `C_Mobile2`, `C_district`, 
              `C_status`, `C_LegacyID`, `CA_Street`, `CA_Barangay`, `CA_District`, 
              `CA_City`, `CA_Province`, `CN_FirstName`, `CN_LastName`, `CN_MiddleName`, `CN_Suffix`,
              `C_LFullName` 
            FROM `customerlist` 
        """
        ai_customer = fetch_records(ai_conn, ai_query)
        ai_conn.close()

        # Convert AI items to a dictionary for easy access
        ai_customer_dict = {str(customer["C_LegacyID"]): customer for customer in ai_customer}
        
        customer_added = 0
        customer_updated = 0
        customer_unchanged = 0

        for L_Customer in legacy_customer:
            legacy_code = str(L_Customer["customerID"])

            if legacy_code not in ai_customer_dict:
                add_customer(L_Customer)
                customer_added += 1
            else:
                # Update existing customer only if needed
                was_updated = update_customer(L_Customer, ai_customer_dict[legacy_code])
                if was_updated:
                    customer_updated += 1
                else:
                    customer_unchanged += 1

        print(f"Customers added: {customer_added}")
        print(f"Customers updated: {customer_updated}")
        print(f"Customers unchanged: {customer_unchanged}")
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

def update_customer(legacy_customer, ai_customer):
    """Update existing customer in AI inventory database only if data has changed"""
    try:
        conn = get_connection('ai_inventory')
        cursor = conn.cursor()
        updates_made = []
        
        # Check and update customer name if changed
        if legacy_customer["fullName"] != ai_customer["C_LFullName"]:
            name_query = """
                UPDATE `customername` 
                SET `C_LFullName` = %s
                WHERE `CNNameID` = %s
            """
            cursor.execute(name_query, (legacy_customer["fullName"], ai_customer["CNNameID"]))
            updates_made.append("name")
        
        # Check and update customer address if any field changed
        address_changed = (
            legacy_customer["address"] != ai_customer["CA_Street"] or
            legacy_customer["district"] != ai_customer["CA_District"] or
            legacy_customer["city"] != ai_customer["CA_City"]
        )
        
        if address_changed:
            address_query = """
                UPDATE `customeraddress` 
                SET `CA_Street` = %s, `CA_District` = %s, `CA_City` = %s
                WHERE `CustomerAddressID` = %s
            """
            cursor.execute(address_query, (
                legacy_customer["address"],
                legacy_customer["district"],
                legacy_customer["city"],
                ai_customer["CustomerAddressID"]
            ))
            updates_made.append("address")
        
        # Check and update customer details if any field changed
        details_changed = (
            legacy_customer["email"] != ai_customer["C_Email"] or
            legacy_customer["mobile"] != ai_customer["C_Mobile"] or
            legacy_customer["phone2"] != ai_customer["C_Mobile2"] or
            legacy_customer["status"] != ai_customer["C_status"]
        )
        
        if details_changed:
            customer_query = """
                UPDATE `customer` 
                SET `C_Email` = %s, `C_Mobile` = %s, `C_Mobile2` = %s, `C_status` = %s
                WHERE `CustomerID` = %s
            """
            cursor.execute(customer_query, (
                legacy_customer["email"],
                legacy_customer["mobile"],
                legacy_customer["phone2"],
                legacy_customer["status"],
                ai_customer["CustomerID"]
            ))
            updates_made.append("details")
        
        # Only commit if any changes were made
        if updates_made:
            conn.commit()
            print(f"Updated customer {legacy_customer['customerID']}: {', '.join(updates_made)}")
        
        conn.close()
        return len(updates_made) > 0  # Return True if any updates were made
            
    except mysql.connector.Error as err:
        print(f"Update Error: {err}")
        return False
    
def add_customer(customers): 
    """Add customers to AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            Nquery = """
              INSERT INTO `customername`(`C_LFullName`) VALUES (%s)
            """
            cursor.execute(Nquery, (customers["fullName"],))

            customername_id = cursor.lastrowid  # Get the auto-generated primary key
            
            conn.commit()

            Aquery = """
            INSERT INTO `customeraddress`(`CA_Street`,`CA_District`, `CA_City`) VALUES (%s,%s,%s)        
            """
            cursor.execute(Aquery, (customers["address"],customers["district"],customers["city"]))

            customeraddress = cursor.lastrowid  # Get the auto-generated primary key

            conn.commit()

            Cquery = """
            INSERT INTO `customer`(`CNNameID`, `CustomerAddressID`, `C_Email`, `C_Mobile`, `C_Mobile2`, `C_status`, `C_LegacyID`) 
            VALUES (%s,%s,%s,%s,%s,%s,%s)
            """

            cursor.execute(Cquery, (customername_id,customeraddress,customers["email"],customers["mobile"],customers["phone2"],customers["status"],customers["customerID"]))

            conn.commit()

            print(f"Customer successfully inserted")
            
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")



# @app.route('/sync', methods=['GET'])
# def sync_route():
#     """API endpoint to trigger synchronization"""
#     try:
#         synchronize_inventory()
#         return jsonify({"status": "success", "message": "Inventory synchronized successfully"})
#     except Exception as e:
#         return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    synchronize_inventory()
    synchronize_customer()
    # app.run(debug=True, port=5000)  # Running on Port 5000