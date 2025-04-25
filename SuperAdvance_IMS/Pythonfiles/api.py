# Flask API Code
from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
import mysql.connector 
import synchronize
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

def get_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='ai_inventory'
    )

# For the Display on Items
@app.route('/api/displayitems', methods=['GET'])
def GetProducts():
    synchronize.synchronize_inventory()

    sql = """
        SELECT `ItemID`, `I_LegacyCode`, `I_Name`, `I_Discount`, `I_UnitPrice`, 
        `I_Image`, `I_Status`, `I_Stock`, `I_Description`, `I_QRCode`, 
        `I_QRPath`, `I_LastUpdate`, `I_Suggestion`, `I_SuggestedPrice` FROM `item`
    """
    
    return GET(sql,"items","I_Image")

# For the Display on Purchases
@app.route('/api/displaypurchases', methods=['GET'])
def GetPurchase():
    synchronize.synchronize_purchase()
    sql = "SELECT `purchaseID`,`I_Image`, `P_Date`, `P_Quantity`, `I_Name` FROM `purchaselist`"

    return GET(sql,"purchases","I_Image")

# For the Display on Sales
@app.route('/api/displaysales', methods=['GET'])
def GetSales():
    synchronize.synchronize_sale()

    sql = """
        SELECT 
        `S_LegacyID`, `C_LFullName`, DATE_FORMAT(`S_Date`, '%M %e %Y') AS `S_Date`, `I_Name`, 
        `S_Quantity`, `S_Discount`, `S_UnitPrice`,
        ROUND((`S_UnitPrice` * `S_Quantity`) - ((`S_UnitPrice` * `S_Quantity`) * (`S_Discount` / 100)), 2) AS `TotalPrice`
        FROM 
        `salelist`
        ORDER BY `S_Date` ASC, `S_LegacyID` DESC;  
         """
    
    return GET(sql,"sales")

# For the Display on Customer
@app.route('/api/displaycustomer', methods=['GET'])
def GetCustomers():
    sql = """
          SELECT `CustomerID`, `C_LFullName`,  `C_Email`, `C_Mobile`, `C_Mobile2`,`CA_Street`, `C_status` FROM `customerlist`  
         """
    return GET(sql,"customer")

# For the Display on Vendors
@app.route('/api/displayvendors', methods=['GET'])
def GetVendors():
    sql = """
          SELECT a.VendorID, a.V_LFullName, a.V_Email, a.V_Mobile, a.V_Mobile2, a.VA_Street, a.V_status FROM `vendorlist` a
         """
    return GET(sql,"vendor")

# Function to get the datas from ai_inventory base on given statements
def GET(statement,dataname,Image=None):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        sql = statement

        cursor.execute(sql)

        output = cursor.fetchall()

        # print(output)

        #If theres an image file/path
        if Image:
         for outputs in output:
            if Image in outputs and outputs[Image]:
                if isinstance(outputs[Image], bytes):
                    try:
                        # Try to decode as URL path
                        path_string = outputs[Image].decode('utf-8', errors='ignore')
                        
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
                                outputs[Image] = url
                            else:
                                # If we can't find a valid URL, use base64
                                import base64
                                outputs[Image] = base64.b64encode(outputs[Image]).decode('utf-8')
                        else:
                            # Not a URL, convert to base64
                            import base64
                            outputs[Image] = base64.b64encode(outputs[Image]).decode('utf-8')
                            
                    except Exception as e:
                        print(f"Error processing image for {outputs['I_Name']}: {e}")
                        outputs[Image] = None

            # Process other binary fields
            for key, value in outputs.items():
                if key != Image and isinstance(value, bytes):
                    try:
                        # Try to decode as string first
                        outputs[key] = value.decode('utf-8', errors='ignore')
                    except:
                        # Fall back to base64 if not a valid string
                        import base64
                        outputs[key] = base64.b64encode(value).decode('utf-8')
        
        return jsonify({dataname : output, "status": "success"})

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()


@app.route('/api/getsales', methods=['POST'])
def InputItems():
    if request.method == 'POST':
        # Extract form data
        item_name = request.form.get('itemName')
        unit_price = request.form.get('unitPrice')
        discount = request.form.get('discount')
        status = request.form.get('status')
        stocks = request.form.get('stocks')
        description = request.form.get('description')
        
        # Handle image file if uploaded
        image_file = request.files.get('image')
        image_filename = None
        
        if image_file and image_file.filename:
            # Get secure filename and save the file
            image_filename = secure_filename(image_file.filename)
            image_path = os.path.join(app.config['UPLOAD_FOLDER'], image_filename)
            image_file.save(image_path)
        
        # Create item dictionary
        item_data = {
            'item_name': item_name,
            'unit_price': unit_price,
            'discount': discount,
            'status': status,
            'stocks': stocks,
            'description': description,
            'image': image_filename
        }
        
        print(item_data)
        
        # Here you would typically save this data to your database
        # Example: db.items.insert_one(item_data)
        
        return jsonify({'success': True, 'message': 'Item added successfully'})
    
    return jsonify({'success': False, 'message': 'Invalid request method'})



# Run the application
if __name__ == '__main__':
    app.run(debug=True)