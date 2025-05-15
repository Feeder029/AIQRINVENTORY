# Flask API Code
from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
import mysql.connector 
import synchronize
from werkzeug.utils import secure_filename
import os
import itemqr
import base64
import ai
import firebaseconnection


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
    firebaseconnection.syncronize()

    sql = """
    SELECT 
    `ItemID`, `I_LegacyCode`, `I_MobileCode`, `I_Name`, `I_Discount`, `I_UnitPrice`, 
    `I_Image`, `I_ImagePath`, `I_Status`, `I_Stock`, `I_Description`, `I_QRCode`,
    `I_QRPath`, `I_LastUpdate`, `I_SuggestedPrice`, `I_MaxPriceRange`, `I_MinPriceRange`, 
    `I_EbaySuggestedPrice`, `I_EbayFullInfo`, `I_MCSuggestedPrice`, `I_MCFullInfo`, 
    `I_AmazonSuggestedPrice`, `I_AmazonFullInfo`, `I_WallmartSuggestedPrice`, `I_WallmartInfo`,
    
    CASE 
        WHEN `I_UnitPrice` < `I_MinPriceRange` THEN 'Underprice'
        WHEN `I_UnitPrice` > `I_MaxPriceRange` THEN 'Overprice'
        ELSE 'Fit'
    END AS `PriceStatus`

    FROM `item`
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
    `I_ImagePath`,
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
    synchronize.synchronize_customer()

    
    sql = """
          SELECT `CustomerID`, `C_LFullName`,  `C_Email`, `C_Mobile`, `C_Mobile2`,`CA_Street`, `C_status` FROM `customerlist`  
         """
    return GET(sql,"customer")

# For the Display on Vendors
@app.route('/api/displayvendors', methods=['GET'])
def GetVendors():
    synchronize.synchronize_vendor()
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


def POST(conn, statement, inputs):
    cursor = conn.cursor(dictionary=True)
    cursor.execute(statement, inputs)
    ID = cursor.lastrowid
    conn.commit()
    return ID  # Return just the ID, not the cursor and ID

def ImageHandler(Image, ItemName):
    # Save the image to a folder
    relative_path = None
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
    else:
        print("No image provided")  # Fixed indentation
    
    return relative_path


@app.route('/api/insertitems', methods=['POST'])
def AddNewItem():
    conn = None
    try:
        conn = get_connection()
        conn2 = get_connection2() 

        data = request.json
        ItemName = data.get("Name")
        ItemDescription = data.get("Desc")
        ItemQuantity = data.get("Quantity")
        ItemUnitPrice = data.get("UnitPrice")
        ItemDiscount = data.get("Discount")
        Image = data.get("Img")  # This should be base64 encoded image data
        SuggestedPrice = data.get("SP")
        MaxRange = data.get("Max")
        MinRange = data.get("Min")
        EbaySP = data.get("EbaySP")
        EbayInfo = data.get("EbayInfo")
        MCSPs = data.get("MCSPs")
        MCInfo = data.get("MCInfo")
        AmazonSP = data.get("AmazonSP")
        AmazonInfo = data.get("AmazonInfo")
        WalmartSP = data.get("WalmartSP")
        WalmartInfo = data.get("WalmartInfo")

        I_Status = "Active"


        # Process image
        relative_path = ImageHandler(Image, ItemName)  # Fixed missing ItemName parameter

        query = """
        INSERT INTO `item`(`I_Name`, `I_Discount`, `I_UnitPrice`, `I_Status`, `I_Stock`, `I_Description`, `I_ImagePath`, `I_Image`, `I_SuggestedPrice`, `I_MaxPriceRange`, `I_MinPriceRange`, `I_EbaySuggestedPrice`, `I_EbayFullInfo`, `I_MCSuggestedPrice`, `I_MCFullInfo`, `I_AmazonSuggestedPrice`, `I_AmazonFullInfo`, `I_WallmartSuggestedPrice`, `I_WallmartInfo`) 
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """
        
        inputs = (ItemName, ItemDiscount, ItemUnitPrice, I_Status,
            ItemQuantity, ItemDescription, relative_path, Image,
            SuggestedPrice, MaxRange, MinRange, EbaySP, EbayInfo, MCSPs, MCInfo, 
            AmazonSP, AmazonInfo, WalmartSP, WalmartInfo)
            
        # Execute the query
        AIID = POST(conn, query, inputs)
        
        # Calculate ItemNumber for legacy system
        ItemNumber = AIID + 1000

        # Fixed legacyquery with correct number of placeholders
        legacyquery = """
        INSERT INTO `item`(`itemNumber`, `itemName`, `discount`, `stock`, `unitPrice`,`imageURL`,`status`, `description`)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """

        # Adjust legacy inputs to match parameters
        legacyinputs = (
            ItemNumber, ItemName, ItemDiscount, ItemQuantity, ItemUnitPrice, 
            relative_path, I_Status, ItemDescription          
        )

        # Insert into legacy database
        LID = POST(conn2, legacyquery, legacyinputs)  # Using conn2 for legacy database

        # Generate WebID
        WebID = f"W{AIID}"

        qrpath, qrcode = itemqr.generate_qr(WebID,ItemName,ItemUnitPrice,ItemQuantity)

        # Update the main record with codes
        updatequery = """
        UPDATE `item` SET `I_LegacyCode`= %s,`I_MobileCode`= %s,`I_QRCode`=%s, `I_QRPath`=%s WHERE `ItemID`= %s           
        """

        updateinput = (
            LID, WebID, qrcode, qrpath, AIID
        )
        
        # Execute update query
        cursor = conn.cursor()
        cursor.execute(updatequery, updateinput)
        conn.commit()

        firebaseconnection.newproduct(WebID,ItemName,ItemDescription,ItemUnitPrice,ItemQuantity,relative_path)

        # Return success response
        return jsonify({"status": "success", "message": "Item added successfully"}), 200
    

    except mysql.connector.Error as err:
        if conn:
            conn.rollback()
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/itemupdate', methods=['POST'])
def ItemUpdate():
    conn = None
    conn2 = None
    try:
        conn = get_connection()
        conn2 = get_connection2()

        data = request.json
        ItemID = data.get("ID")
        ItemName = data.get("Name")
        ItemDescription = data.get("Desc")
        ItemQuantity = data.get("Quantity")
        ItemUnitPrice = data.get("UnitPrice")
        ItemDiscount = data.get("Discount")
        Image = data.get("IMG")  

        # Use the ImageHandler function for image processing
        relative_path = ImageHandler(Image, ItemName)

        # Update in legacy database
        legacy_query = """
        UPDATE `item` SET `itemName`= %s,`discount`= %s,`stock`= %s,`unitPrice`= %s,`description`= %s 
        WHERE `productID`= %s
        """

        # Using traditional execution since POST is for INSERT operations
        cursor2 = conn2.cursor()
        cursor2.execute(legacy_query, (
            ItemName,
            ItemDiscount,
            ItemQuantity,
            ItemUnitPrice,
            ItemDescription,
            ItemID
        ))
        conn2.commit()

        # Update in main database
        query = """
        UPDATE `item` SET `I_Name`= %s, `I_Discount`= %s, `I_UnitPrice`= %s,
        `I_Stock`= %s, `I_Description`= %s WHERE `I_LegacyCode`= %s
        """

        cursor = conn.cursor()
        cursor.execute(query, (
            ItemName,
            ItemDiscount,
            ItemUnitPrice,
            ItemQuantity,
            ItemDescription,
            ItemID
        ))

        # Update image path if available
        if relative_path is not None:
            imgquery = """
            UPDATE `item` SET `I_ImagePath` = %s, `I_Image` = %s WHERE `I_LegacyCode` = %s
            """

            cursor.execute(imgquery, (
                relative_path, Image, ItemID
            ))

        # Commit changes
        conn.commit()
        print(f"{ItemID} Successfully Updated")

        # Update firebase (if needed)
        # Add firebaseconnection.updateproduct call here if needed

        return jsonify({
            "status": "success",
            "message": "Item updated successfully."
        })

    except mysql.connector.Error as err:
        if conn:
            conn.rollback()
        if conn2:
            conn2.rollback()
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    except Exception as e:
        if conn:
            conn.rollback()
        if conn2:
            conn2.rollback()
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'cursor2' in locals() and cursor2:
            cursor2.close()
        if conn and conn.is_connected():
            conn.close()
        if conn2 and conn2.is_connected():
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

@app.route('/api/getrecommendedprice', methods=['POST'])
def GetPrice():
    print("working")
    
    # Get JSON data instead of form data
    data = request.get_json()
    
    if not data or 'itemName' not in data:
        return jsonify({'success': False, 'message': 'Item name is required'})
        
    item_name = data['itemName']
    
    try:
     # Get the complete results
     results = ai.scrapeprice(item_name)
    
     # Format the detailed results for response
     formatted_detailed = {}
     for source, data in results["detailed"].items():
         formatted_detailed[source] = {
             "count": data["count"],
             "SuggestedPrice": data["suggested_price"],
             "price_range": {
                 "min": data["min_price"],
                 "max": data["max_price"]
             },
             "avg_price": data["avg_price"],
             "median_price": data["median_price"],
             "std_deviation": data["std_deviation"],
             "prices": data["prices"]
         }
    
     # Prepare the response with all available information
     response_data = {
         'success': True, 
         'message': 'Item price analysis completed',
         'suggestedPrice': results["summary"]["suggested_price"],
         'priceRange': {
             'min': results["summary"]["price_range"]["min"],
             'max': results["summary"]["price_range"]["max"]
         },
         'confidence': results["summary"]["confidence"],
         'totalPricesFound': results["summary"]["total_prices_found"],
         'pricesAfterFiltering': results["summary"]["prices_after_filtering"],
         'detailedResults': formatted_detailed,
         'sourceCounts': results["summary"]["source_counts"]
      }
    
     # Add price range suggestions if available
     if "suggested_ranges" in results["summary"]:
         response_data['suggestedRanges'] = {
             'budget': {
                 'min': results["summary"]["suggested_ranges"]["budget"]["min"],
                 'max': results["summary"]["suggested_ranges"]["budget"]["max"]
             },
             'midrange': {
                 'min': results["summary"]["suggested_ranges"]["midrange"]["min"],
                 'max': results["summary"]["suggested_ranges"]["midrange"]["max"]
             },
             'premium': {
                 'min': results["summary"]["suggested_ranges"]["premium"]["min"],
                 'max': results["summary"]["suggested_ranges"]["premium"]["max"]
             }
         }
    
     # Return the complete response
     return jsonify(response_data)
    
    except Exception as e:
    # Log the exception for debugging
     logging.error(f"Error in price analysis: {str(e)}", exc_info=True)
    
    return jsonify({'success': False, 'message': str(e)})




# Run the application
if __name__ == '__main__':
    app.run(debug=True)