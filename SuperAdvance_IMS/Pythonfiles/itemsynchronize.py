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

@app.route('/sync', methods=['GET'])
def sync_route():
    """API endpoint to trigger synchronization"""
    try:
        synchronize_inventory()
        return jsonify({"status": "success", "message": "Inventory synchronized successfully"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    synchronize_inventory()
    # app.run(debug=True, port=5000)  # Running on Port 5000