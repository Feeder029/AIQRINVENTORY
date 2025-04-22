from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import itemqr

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

def add_item(item, qrpath, qrcode):
    """Add item to AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
                INSERT INTO item (
                    I_LegacyCode, I_Name, I_Discount, I_UnitPrice, 
                    I_Status, I_Stock, I_Description, `I_QRCode`, `I_QRPath`
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            cursor.execute(query, (
                item['productID'], item['itemName'], item['discount'], 
                item['unitPrice'], item['status'], item['stock'], 
                item['description'], qrcode, qrpath
            ))
            
            conn.commit()
            print(f"Item {item['productID']} successfully inserted")
            
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

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
            SELECT ItemID, I_LegacyCode, I_Name, I_Discount, I_UnitPrice, I_Image, 
                   I_Status, I_Stock, I_Description, I_QRCode, I_LastUpdate, 
                   I_Suggestion, I_SuggestedPrice 
            FROM item
        """
        ai_items = fetch_records(ai_conn, ai_query)
        ai_conn.close()
        
        # Extract existing legacy codes for comparison
        existing_legacy_codes = {str(item["I_LegacyCode"]) for item in ai_items}
        
        # Add items that don't exist in AI inventory
        for item in legacy_items:
            if str(item["productID"]) not in existing_legacy_codes:
                qrpath, qrcode = itemqr.generate_qr(item["itemName"])
                add_item(item,qrpath, qrcode)
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

if __name__ == "__main__":
    synchronize_inventory()
    # app.run(debug=True, port=5000)  # Running on Port 5000