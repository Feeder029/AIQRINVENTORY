# Flask API Code
from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
import mysql.connector 
import synchronize
from werkzeug.utils import secure_filename
import os
import itemqr
import base64


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

def get_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='ai_inventory'
    )

def get_connection2():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='shop_inventory'
    )

# For the Display on Items
@app.route('/api/displayitems', methods=['GET'])
def GetProducts():
    synchronize.synchronize_inventory()

    sql = """
        SELECT `ItemID`, `I_LegacyCode`, `I_Name`, `I_Discount`, `I_UnitPrice`, 
        `I_Image`,`I_ImagePath`,`I_Status`, `I_Stock`, `I_Description`, `I_QRCode`, 
        `I_QRPath`, `I_LastUpdate`, `I_Suggestion`, `I_SuggestedPrice` FROM `item`
    """
    
    return GET(sql,"items","I_Image")

# For the Display on Purchases
@app.route('/api/displaypurchases', methods=['GET'])
def GetPurchase():
    synchronize.synchronize_purchase()
    sql = """
    SELECT 
    `purchaseID`, 
    `I_Image`, 
    `P_Date`,
    `P_Quantity`, 
    `I_Name`,
    CASE 
        WHEN DATEDIFF(CURDATE(), `P_Date`) = 0 THEN 'Today'
        WHEN DATEDIFF(CURDATE(), `P_Date`) = 1 THEN '1 day ago'
        WHEN DATEDIFF(CURDATE(), `P_Date`) > 1 AND DATEDIFF(CURDATE(), `P_Date`) <= 6 
            THEN CONCAT(DATEDIFF(CURDATE(), `P_Date`), ' days ago')
        ELSE DATE_FORMAT(`P_Date`, '%M %e, %Y')
    END AS `Date`
    FROM `purchaselist`
    ORDER BY `P_Date` DESC
    """

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

@app.route('/api/insertitems', methods=['POST'])
def AddItem():
    try:
        conn = get_connection()
        conn2 = get_connection2()

        cursor = conn.cursor(dictionary=True)
        cursor2 = conn2.cursor(dictionary=True)

        data = request.json
        ItemName = data.get("Name")
        ItemDescription = data.get("Desc")
        ItemQuantity = data.get("Quantity")
        ItemUnitPrice = data.get("UnitPrice")
        ItemDiscount = data.get("Discount")
        Image = data.get("Img")  # This should be base64 encoded image data
        I_Status = "Active"

        # Generate QR code
        qrpath, qrcode = itemqr.generate_qr(ItemName)

        # Save the image to a folder
        if Image:
            # Create uploads directory if it doesn't exist
            upload_folder = "SuperAdvance_IMS/Images/data"
            os.makedirs(upload_folder, exist_ok=True)
            
            # Create a safe filename from ItemName
            safe_item_name = ''.join(c if c.isalnum() or c in ['-', '_'] else '_' for c in ItemName)
            filename = f"{safe_item_name}.png"
            
            # Full path to save the image
            image_path = os.path.join(upload_folder, filename)
            
            # Decode base64 image and save it
            try:
                # Remove the base64 header if present
                if "," in Image:
                    Image = Image.split(",")[1]
                
                # Decode and save the image
                with open(image_path, "wb") as img_file:
                    img_file.write(base64.b64decode(Image))
                
                # Get relative path to store in database
                relative_path = os.path.join("http://localhost/AIQRINVENTORY/SuperAdvance_IMS/Images/data/", filename)
                print(f"Image saved at: {image_path}")
            except Exception as img_err:
                print(f"Error saving image: {img_err}")
                relative_path = None
        else:
            relative_path = None
            print("No image provided")

        # First insert into ai_inventory database
        query = """
        INSERT INTO `item`(`I_Name`, `I_Discount`, `I_UnitPrice`, `I_Status`, `I_Stock`, `I_Description`, `I_QRCode`, `I_QRPath`, `I_ImagePath`, `I_Image`) 
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """

        cursor.execute(query, (
            ItemName, ItemDiscount, ItemUnitPrice, I_Status,
            ItemQuantity, ItemDescription, qrcode, qrpath, relative_path, Image
        ))

        AID = cursor.lastrowid
        ItemNumber = AID + 1000
        
        # Use the saved image path for the second database too
        Path = relative_path if relative_path else "null"

        # Try to insert into shop_inventory database
        try:
            lquery = """
            INSERT INTO `item`(`itemNumber`, `itemName`, `discount`, `stock`, `unitPrice`,`imageURL`,`status`, `description`)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """
            cursor2.execute(lquery, (
                ItemNumber, ItemName, ItemDiscount, ItemQuantity, ItemUnitPrice, Path, I_Status, ItemDescription
            ))
            
            LID = cursor2.lastrowid
            
            # Update the first database with the legacy ID
            update = """
            UPDATE `item` SET `I_LegacyCode`= %s WHERE `ItemID`= %s      
            """
            cursor.execute(update, (
                LID, AID
            ))
            
            conn.commit()
            conn2.commit()  # Make sure to commit the second connection too
            
            return jsonify({
                "status": "success", 
                "message": "Item added successfully to both databases.",
                "image_path": relative_path
            })
            
        except mysql.connector.Error as err2:
            # If second insert fails, rollback first insert
            conn.rollback()
            print(f"Second Database Error: {err2}")
            return jsonify({"status": "error", "message": f"First database insert succeeded, but second failed: {str(err2)}"}), 500
        
    except mysql.connector.Error as err:
        print(f"First Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()
        if 'conn2' in locals() and conn2.is_connected():
            cursor2.close()
            conn2.close()


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