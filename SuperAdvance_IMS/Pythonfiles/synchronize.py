from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import itemqr
import os
import ai
import firebaseconnection

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

def add_item(item, qrpath, qrcode,SuggestedPrice,MaxPrice,MinPrice,EbaySP,EbayDetails,MCSPs,MCDetails,AmazonSPs,AmazonDetails,WallmartSP,WallmartDetails):
   

    """Add item to AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            # Generate the image path
            image_path = get_image_path(item['itemNumber'], item['imageURL'])
            
            query = """
             INSERT INTO item (
              I_LegacyCode, `I_MobileCode`, I_Name, I_Discount, I_UnitPrice, 
              I_Status, I_Stock, I_Description, `I_QRCode`, 
              `I_QRPath`, `I_ImagePath`, `I_SuggestedPrice`, `I_MaxPriceRange`, 
              `I_MinPriceRange`, `I_EbaySuggestedPrice`, `I_EbayFullInfo`, `I_MCSuggestedPrice`, 
              `I_MCFullInfo`, `I_AmazonSuggestedPrice`, `I_AmazonFullInfo`, `I_WallmartSuggestedPrice`, `I_WallmartInfo`
             ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """

            MobileID = f"L{item['productID']}"

            cursor.execute(query, (
                item['productID'],MobileID,item['itemName'], item['discount'], item['unitPrice'], 
                item['status'], item['stock'], item['description'], qrcode, 
                qrpath,image_path,SuggestedPrice,MaxPrice,
                MinPrice,EbaySP,EbayDetails,MCSPs,
                MCDetails,AmazonSPs,AmazonDetails, WallmartSP, WallmartDetails
            ))
            
            conn.commit()

            print(f"Item {item['productID']} successfully inserted")
        
        MobileID = f"L{item['productID']}"
        firebaseconnection.newproduct(MobileID,item['itemName'],item['description'],item['unitPrice'],item['stock'],image_path)

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
                   I_SuggestedPrice 
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
                LegacyID = f"L{legacy_code}"
                qrpath, qrcode = itemqr.generate_qr(LegacyID,legacy_item["itemName"],legacy_item["unitPrice"],legacy_item["stock"])
                suggestion = ai.scrapeprice(legacy_item["itemName"])

                SuggestedPrice = suggestion['summary']['suggested_price']
                MinPrice = suggestion['summary']['suggested_ranges']['midrange']['min']
                MaxPrice = suggestion['summary']['suggested_ranges']['midrange']['max']


                AmazonSPs = None
                EbaySP = None
                MCSPs = None
                WallmartSP = None
                AmazonDetails = ""
                EbayDetails = ""
                MCDetails = ""
                WallmartDetails = ""
   
                for source, data in suggestion['detailed'].items():
                  if source.upper() == 'EBAY':
                   EbaySP = data['suggested_price']
                   EbayDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"
                  elif source.upper() == 'MICROCENTER':
                   MCSPs = data['suggested_price']
                   MCDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"
                  elif source.upper() == 'AMAZON':
                   AmazonSPs = data['suggested_price']
                   AmazonDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"        
                  elif source.upper() == 'WALMART':
                   WallmartSP = data['suggested_price']
                   WallmartDetails  = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"        

                 
                print(f"{source.upper()}: ${data['suggested_price']}")

                add_item(legacy_item, qrpath, qrcode,SuggestedPrice,MaxPrice,MinPrice,EbaySP,EbayDetails,MCSPs,MCDetails,AmazonSPs,AmazonDetails,WallmartSP,WallmartDetails)


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

def synchronize_vendor():
    """Synchronize vendors from legacy database to AI inventory"""
    try:
        # Get legacy vendors
        legacy_conn = get_connection('shop_inventory')
        legacy_query = """
            SELECT `vendorID`, `fullName`, `email`, `mobile`, `phone2`, `address`, `address2`, 
              `city`, `district`, `status`, `createdOn` 
            FROM `vendor`
        """
        legacy_vendor = fetch_records(legacy_conn, legacy_query)
        legacy_conn.close()
        
        # Get current AI inventory vendors
        ai_conn = get_connection('ai_inventory')
        ai_query = """
            SELECT `VendorID`, `VNameID`, `VendorAddressID`, `V_Email`, `V_Mobile`, `V_Mobile2`, `V_district`, 
              `V_status`, `V_LegacyID`, `VA_Street`, `VA_Barangay`, `VA_District`, 
              `VA_City`, `VA_Province`, `VN_FirstName`, `VN_LastName`, `VN_MiddleName`, `VN_Suffix`,
              `V_LFullName` 
            FROM `vendorlist` 
        """
        ai_vendor = fetch_records(ai_conn, ai_query)
        ai_conn.close()

        # Convert AI items to a dictionary for easy access
        ai_vendor_dict = {str(vendor["V_LegacyID"]): vendor for vendor in ai_vendor}
        
        vendor_added = 0
        vendor_updated = 0
        vendor_unchanged = 0

        for L_Vendor in legacy_vendor:
            legacy_code = str(L_Vendor["vendorID"])

            if legacy_code not in ai_vendor_dict:
                add_vendor(L_Vendor)
                vendor_added += 1
            else:
                # Update existing vendor only if needed
                was_updated = update_vendor(L_Vendor, ai_vendor_dict[legacy_code])
                if was_updated:
                    vendor_updated += 1
                else:
                    vendor_unchanged += 1

        print(f"Vendors added: {vendor_added}")
        print(f"Vendors updated: {vendor_updated}")
        print(f"Vendors unchanged: {vendor_unchanged}")
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

def update_vendor(legacy_vendor, ai_vendor):
    """Update existing vendor in AI inventory database only if data has changed"""
    try:
        conn = get_connection('ai_inventory')
        cursor = conn.cursor()
        updates_made = []
        
        # Check and update vendor name if changed
        if legacy_vendor["fullName"] != ai_vendor["V_LFullName"]:
            name_query = """
                UPDATE `vendorname` 
                SET `V_LFullName` = %s
                WHERE `VNameID` = %s
            """
            cursor.execute(name_query, (legacy_vendor["fullName"], ai_vendor["VNameID"]))
            updates_made.append("name")
        
        # Check and update vendor address if any field changed
        address_changed = (
            legacy_vendor["address"] != ai_vendor["VA_Street"] or
            legacy_vendor["district"] != ai_vendor["VA_District"] or
            legacy_vendor["city"] != ai_vendor["VA_City"]
        )
        
        if address_changed:
            address_query = """
                UPDATE `vendoraddress` 
                SET `VA_Street` = %s, `VA_District` = %s, `VA_City` = %s
                WHERE `VendorAddressID` = %s
            """
            cursor.execute(address_query, (
                legacy_vendor["address"],
                legacy_vendor["district"],
                legacy_vendor["city"],
                ai_vendor["VendorAddressID"]
            ))
            updates_made.append("address")
        
        # Check and update vendor details if any field changed
        details_changed = (
            legacy_vendor["email"] != ai_vendor["V_Email"] or
            legacy_vendor["mobile"] != ai_vendor["V_Mobile"] or
            legacy_vendor["phone2"] != ai_vendor["V_Mobile2"] or
            legacy_vendor["status"] != ai_vendor["V_status"]
        )
        
        if details_changed:
            vendor_query = """
                UPDATE `vendor` 
                SET `V_Email` = %s, `V_Mobile` = %s, `V_Mobile2` = %s, `V_status` = %s
                WHERE `VendorID` = %s
            """
            cursor.execute(vendor_query, (
                legacy_vendor["email"],
                legacy_vendor["mobile"],
                legacy_vendor["phone2"],
                legacy_vendor["status"],
                ai_vendor["VendorID"]
            ))
            updates_made.append("details")
        
        # Only commit if any changes were made
        if updates_made:
            conn.commit()
            print(f"Updated vendor {legacy_vendor['vendorID']}: {', '.join(updates_made)}")
        
        conn.close()
        return len(updates_made) > 0  # Return True if any updates were made
            
    except mysql.connector.Error as err:
        print(f"Update Error: {err}")
        return False
    
def add_vendor(vendors): 
    """Add vendors to AI inventory database"""
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            Nquery = """
              INSERT INTO `vendorname`(`V_LFullName`) VALUES (%s)
            """
            cursor.execute(Nquery, (vendors["fullName"],))

            vendorname_id = cursor.lastrowid  # Get the auto-generated primary key
            
            conn.commit()

            Aquery = """
            INSERT INTO `vendoraddress`(`VA_Street`,`VA_District`, `VA_City`) VALUES (%s,%s,%s)        
            """
            cursor.execute(Aquery, (vendors["address"],vendors["district"],vendors["city"]))

            vendoraddress = cursor.lastrowid  # Get the auto-generated primary key

            conn.commit()

            Vquery = """
            INSERT INTO `vendor`(`VNameID`, `VendorAddressID`, `V_Email`, `V_Mobile`, `V_Mobile2`, `V_status`, `V_LegacyID`) 
            VALUES (%s,%s,%s,%s,%s,%s,%s)
            """

            cursor.execute(Vquery, (vendorname_id,vendoraddress,vendors["email"],vendors["mobile"],vendors["phone2"],vendors["status"],vendors["vendorID"]))

            conn.commit()

            print(f"Vendor successfully inserted")
            
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def synchronize_purchase():
    """Synchronize purchase from legacy database to AI inventory"""
    try:
        # Get legacy purchase
        legacy_conn = get_connection('shop_inventory')
        legacy_query = """
          SELECT a.purchaseID, b.productID, a.itemNumber, c.vendorID, a.quantity, purchaseDate, a.unitPrice, (a.unitPrice * a.quantity) AS 'cost' FROM purchase a
          JOIN item b ON a.itemNumber = b.itemNumber
          JOIN vendor c ON a.vendorID = c.vendorID;
        """
        legacy_purchase = fetch_records(legacy_conn, legacy_query)
        legacy_conn.close()
        
        # Get current AI inventory purchase
        ai_conn = get_connection('ai_inventory')
        ai_query = """
            SELECT purchaseID, ItemID, VendorID, P_Date, P_Quantity, P_LegacyID, `P_Price`, `P_Cost` FROM purchase 
        """
        ai_purchase = fetch_records(ai_conn, ai_query)
        
        # Convert AI items to a dictionary for easy access
        ai_purchase_dict = {str(purchase["P_LegacyID"]): purchase for purchase in ai_purchase}
       
        purchase_added = 0
        purchase_updated = 0
        purchase_relation_changed = 0
        
        # Process all legacy items
        for legacy_purchases in legacy_purchase:
            legacy_code = str(legacy_purchases["purchaseID"])
            
            # Get needed foreign keys
            Pid = legacy_purchases["productID"]
            Vid = legacy_purchases["vendorID"]
            
            itemIDquery = f"SELECT ItemID FROM item WHERE I_LegacyCode = '{Pid}'"
            vendorIDquery = f"SELECT VendorID FROM vendor WHERE V_LegacyID = '{Vid}'"
 
            ProductID_result = fetch_records(ai_conn, itemIDquery)
            VendorID_result = fetch_records(ai_conn, vendorIDquery)

            # Extract the actual ID values from the query results
            # Check if results exist and extract the first item's ItemID/VendorID
            if ProductID_result and len(ProductID_result) > 0:
                ProductID = ProductID_result[0]["ItemID"]
            else:
                print(f"No matching product found for legacy code: {Pid}")
                continue
                
            if VendorID_result and len(VendorID_result) > 0:
                VendorID = VendorID_result[0]["VendorID"]
            else:
                print(f"No matching vendor found for legacy ID: {Vid}")
                continue

            if legacy_code not in ai_purchase_dict:
                # Add new purchase
                add_purchase(legacy_purchases, ProductID, VendorID)
                purchase_added += 1
            else:
                # Update existing purchase if data differs
                ai_purchase_record = ai_purchase_dict[legacy_code]
                needs_update = False
                
                # Check if any data has changed
                if (ai_purchase_record["P_Quantity"] != legacy_purchases["quantity"] or 
                    ai_purchase_record["P_Date"] != legacy_purchases["purchaseDate"] or
                    ai_purchase_record["P_Price"] != legacy_purchases["unitPrice"] or
                    ai_purchase_record["P_Cost"] != legacy_purchases["cost"]):
                    needs_update = True
                
                # Check if relationships have changed
                if (ai_purchase_record["ItemID"] != ProductID or
                    ai_purchase_record["VendorID"] != VendorID):
                    needs_update = True
                    purchase_relation_changed += 1
                    print(f"Relationship changed for purchase ID: {legacy_code}")
                
                if needs_update:
                    update_purchase(legacy_purchases, ProductID, VendorID, ai_purchase_record["purchaseID"])
                    purchase_updated += 1

        print(f"Synchronization completed: {purchase_added} items added, {purchase_updated} items updated, {purchase_relation_changed} relationship changes")
        ai_conn.close()
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

def add_purchase(purchase, ProductID, VendorID):
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
            INSERT INTO purchase(ItemID, VendorID, P_Date, P_Quantity, P_LegacyID, P_Price, P_Cost) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """

            cursor.execute(query, (
                ProductID, VendorID, purchase['purchaseDate'], purchase['quantity'], 
                purchase['purchaseID'], purchase['unitPrice'], purchase['cost']
            ))
            
            conn.commit()
            print(f"Successfully inserted purchase with legacy ID: {purchase['purchaseID']}")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def update_purchase(purchase, ProductID, VendorID, purchaseID):
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
            UPDATE purchase 
            SET ItemID = %s, VendorID = %s, P_Date = %s, P_Quantity = %s, P_Price = %s, P_Cost = %s
            WHERE purchaseID = %s
            """

            cursor.execute(query, (
                ProductID, VendorID, purchase['purchaseDate'], purchase['quantity'],
                purchase['unitPrice'], purchase['cost'], purchaseID
            ))
            
            conn.commit()
            print(f"Successfully updated purchase with legacy ID: {purchase['purchaseID']}")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
            UPDATE purchase SET ItemID = %s, VendorID = %s, P_Date = %s, P_Quantity = %s 
            WHERE purchaseID = %s
            """

            cursor.execute(query, (
                ProductID, VendorID, purchase['purchaseDate'], purchase['quantity'], purchaseID
            ))
            
            conn.commit()
            print(f"Successfully updated purchase with legacy ID: {purchase['purchaseID']}")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def synchronize_sale():
    """Synchronize sales from legacy database to AI inventory"""
    try:
        # Get legacy sales
        legacy_conn = get_connection('shop_inventory')
        legacy_query = """
          SELECT a.saleID, a.itemNumber, b.productID, c.customerID, a.saleDate, a.quantity,a.discount,a.unitPrice FROM `sale` a
          JOIN item b ON a.itemNumber = b.itemNumber
          JOIN customer c ON a.customerID = c.customerID;
        """
        legacy_sale = fetch_records(legacy_conn, legacy_query)
        legacy_conn.close()
        
        # Get current AI inventory sales
        ai_conn = get_connection('ai_inventory')
        ai_query = """ 
           SELECT `saleID`, `ItemID`, `customerID`, `S_Date`, `S_Quantity`, `S_LegacyID`, `S_Discount`, `S_UnitPrice` FROM `sale`
        """
        ai_sale = fetch_records(ai_conn, ai_query)
        
        # Convert AI items to a dictionary for easy access
        ai_sale_dict = {str(sale["S_LegacyID"]): sale for sale in ai_sale}
       
        sale_added = 0
        sale_updated = 0
        sale_relation_changed = 0
        
        # Process all legacy items
        for legacy_sales in legacy_sale:
            legacy_code = str(legacy_sales["saleID"])
            
            # Get needed foreign keys
            Pid = legacy_sales["productID"]
            Cid = legacy_sales["customerID"]
            
            itemIDquery = f"SELECT ItemID FROM item WHERE I_LegacyCode = '{Pid}'"
            customerIDquery = f"SELECT `CustomerID` FROM `customer` WHERE `C_LegacyID` = '{Cid}'"
 
            ProductID_result = fetch_records(ai_conn, itemIDquery)
            CustomerID_result = fetch_records(ai_conn, customerIDquery)

            # Extract the actual ID values from the query results
            if ProductID_result and len(ProductID_result) > 0:
                ProductID = ProductID_result[0]["ItemID"]
            else:
                print(f"No matching product found for legacy code: {Pid}")
                continue
                
            if CustomerID_result and len(CustomerID_result) > 0:
                CustomerID = CustomerID_result[0]["CustomerID"]
            else:
                print(f"No matching customer found for legacy ID: {Cid}")
                continue

            if legacy_code not in ai_sale_dict:
                # Add new sale
                add_sale(legacy_sales, ProductID, CustomerID)
                sale_added += 1
            else:
                # Update existing sale if data differs
                ai_sale_record = ai_sale_dict[legacy_code]
                needs_update = False
                
                # Check if any data has changed
                if (ai_sale_record["S_Quantity"] != legacy_sales["quantity"] or 
                    ai_sale_record["S_Date"] != legacy_sales["saleDate"] or
                    ai_sale_record["S_Discount"] != legacy_sales["discount"] or
                    ai_sale_record["S_UnitPrice"] != legacy_sales["unitPrice"]                   
                    ):
                    needs_update = True
                
                # Check if relationships have changed
                if (ai_sale_record["ItemID"] != ProductID or
                    ai_sale_record["customerID"] != CustomerID):
                    needs_update = True
                    sale_relation_changed += 1
                    print(f"Relationship changed for sale ID: {legacy_code}")
                
                if needs_update:
                    update_sale(legacy_sales, ProductID, CustomerID, ai_sale_record["saleID"])
                    sale_updated += 1

        print(f"Synchronization completed: {sale_added} items added, {sale_updated} items updated, {sale_relation_changed} relationship changes")
        ai_conn.close()
            
    except mysql.connector.Error as err:
        print(f"Synchronization Error: {err}")

def add_sale(sale, ProductID, CustomerID):
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
            INSERT INTO `sale`(`ItemID`, `customerID`, `S_Date`, `S_Quantity`, `S_LegacyID`, `S_Discount`, `S_UnitPrice`) VALUES (%s,%s,%s,%s,%s,%s,%s)
            """

            cursor.execute(query, (
                ProductID, CustomerID, sale['saleDate'], sale['quantity'], sale['saleID'], sale['discount'], sale['unitPrice']
            ))
            
            conn.commit()
            print(f"Successfully inserted sale with legacy ID: {sale['saleID']}")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def update_sale(sale, ProductID, CustomerID, saleID):
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            
            query = """
            UPDATE `sale` SET `ItemID` = %s, `customerID` = %s, `S_Date` = %s, `S_Quantity` = %s, `S_Discount` = %s, `S_UnitPrice` = %s
            WHERE `saleID` = %s
            """

            cursor.execute(query, (
                ProductID, CustomerID, sale['saleDate'], sale['quantity'], sale['discount'], sale['unitPrice'], saleID
            ))
            
            conn.commit()
            print(f"Successfully updated sale with legacy ID: {sale['saleID']}")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

if __name__ == "__main__":
    print("start")

    # synchronize_sale()
    # synchronize_purchase()
    # synchronize_vendor()
    # synchronize_inventory()
    # synchronize_customer()
    # app.run(debug=True, port=5000)  # Running on Port 5000