# Flask API Code
from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
import mysql.connector 
import synchronize

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

def get_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='ai_inventory'
    )

@app.route('/api/displayitems', methods=['GET'])
def GetProducts():
    synchronize.synchronize_inventory()
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        sql = """
        SELECT `ItemID`, `I_LegacyCode`, `I_Name`, `I_Discount`, `I_UnitPrice`, 
        `I_Image`, `I_Status`, `I_Stock`, `I_Description`, `I_QRCode`, 
        `I_QRPath`, `I_LastUpdate`, `I_Suggestion`, `I_SuggestedPrice` FROM `item`
        """
        cursor.execute(sql)
        
        items = cursor.fetchall()
        
        print(f"Retrieved {len(items)} items from database")
        
        # Process the data
        for item in items:
            # Handle image path from binary data
            if 'I_Image' in item and item['I_Image']:
                if isinstance(item['I_Image'], bytes):
                    try:
                        # Try to decode as URL path
                        path_string = item['I_Image'].decode('utf-8', errors='ignore')
                        
                        # Check if it contains a URL
                        if 'http://' in path_string or '/AIORINVENTORY/' in path_string:
                            # Extract the URL part - using a simple approach
                            start_idx = path_string.find('http://')
                            if start_idx == -1:
                                start_idx = path_string.find('/AIORINVENTORY/')
                            
                            if start_idx >= 0:
                                # Find the end of the URL (look for null byte or space)
                                end_idx = path_string.find('\0', start_idx)
                                if end_idx == -1:
                                    end_idx = len(path_string)
                                
                                # Extract the URL
                                url = path_string[start_idx:end_idx].strip()
                                item['I_Image'] = url
                            else:
                                # If we can't find a valid URL, use base64
                                import base64
                                item['I_Image'] = base64.b64encode(item['I_Image']).decode('utf-8')
                        else:
                            # Not a URL, convert to base64
                            import base64
                            item['I_Image'] = base64.b64encode(item['I_Image']).decode('utf-8')
                            
                    except Exception as e:
                        print(f"Error processing image for {item['I_Name']}: {e}")
                        item['I_Image'] = None

            # Process other binary fields
            for key, value in item.items():
                if key != 'I_Image' and isinstance(value, bytes):
                    try:
                        # Try to decode as string first
                        item[key] = value.decode('utf-8', errors='ignore')
                    except:
                        # Fall back to base64 if not a valid string
                        import base64
                        item[key] = base64.b64encode(value).decode('utf-8')

        return jsonify({"items": items, "status": "success"})

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()


@app.route('/api/displaypurchases', methods=['GET'])
def GetPurchase():
    synchronize.synchronize_purchase()
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        sql = "SELECT `purchaseID`,`I_Image`, `P_Date`, `P_Quantity`, `I_Name` FROM `purchaselist`"

        cursor.execute(sql)

        purchase = cursor.fetchall()

        for purchases in purchase:
            if 'I_Image' in purchases and purchases['I_Image']:
                if isinstance(purchases['I_Image'], bytes):
                    try:
                        # Try to decode as URL path
                        path_string = purchases['I_Image'].decode('utf-8', errors='ignore')
                        
                        # Check if it contains a URL
                        if 'http://' in path_string or '/AIORINVENTORY/' in path_string:
                            # Extract the URL part - using a simple approach
                            start_idx = path_string.find('http://')
                            if start_idx == -1:
                                start_idx = path_string.find('/AIORINVENTORY/')
                            
                            if start_idx >= 0:
                                # Find the end of the URL (look for null byte or space)
                                end_idx = path_string.find('\0', start_idx)
                                if end_idx == -1:
                                    end_idx = len(path_string)
                                
                                # Extract the URL
                                url = path_string[start_idx:end_idx].strip()
                                purchases['I_Image'] = url
                            else:
                                # If we can't find a valid URL, use base64
                                import base64
                                purchases['I_Image'] = base64.b64encode(purchases['I_Image']).decode('utf-8')
                        else:
                            # Not a URL, convert to base64
                            import base64
                            purchases['I_Image'] = base64.b64encode(purchases['I_Image']).decode('utf-8')
                            
                    except Exception as e:
                        print(f"Error processing image for {purchases['I_Name']}: {e}")
                        purchases['I_Image'] = None

            # Process other binary fields
            for key, value in purchases.items():
                if key != 'I_Image' and isinstance(value, bytes):
                    try:
                        # Try to decode as string first
                        purchases[key] = value.decode('utf-8', errors='ignore')
                    except:
                        # Fall back to base64 if not a valid string
                        import base64
                        purchases[key] = base64.b64encode(value).decode('utf-8')
        
        return jsonify({"purchases": purchase, "status": "success"})

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()
            
# Run the application
if __name__ == '__main__':
    app.run(debug=True)