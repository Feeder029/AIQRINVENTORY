import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import mysql.connector
import json
import ai
import api

def get_connection(database_name):
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database=database_name
    )

def Cred():
    # Check if Firebase is already initialized
    if not firebase_admin._apps:
        # Only initialize if not already done
        cred = credentials.Certificate(r"C:\xampp\htdocs\AIQRINVENTORY\SuperAdvance_IMS\Database\appdev-mobile-firebase-adminsdk-fbsvc-3ca86cad14.json")
        firebase_admin.initialize_app(cred)
    
    # Get the Firestore client from the default app
    db = firestore.client()
    return db

                
def getMobileCodes(): 
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor()
            query = """
                SELECT a.I_MobileCode 
                FROM `item` a  
                WHERE a.I_MobileCode IS NOT NULL 
                  AND TRIM(a.I_MobileCode) != '';
            """
            cursor.execute(query)
            result = cursor.fetchall()
            # Extract and return just the code strings
            return [row[0] for row in result]
      
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return []


def Info():
    try:
        with get_connection('ai_inventory') as conn:
            cursor = conn.cursor(dictionary=True)  # ensure dicts are returned
            query = """
                SELECT I_MobileCode, I_Name, I_Discount, I_UnitPrice, I_ImagePath, I_Stock, I_Description
                FROM item
                WHERE I_MobileCode IS NOT NULL
                  AND TRIM(I_MobileCode) != ''
            """
            cursor.execute(query)
            result = cursor.fetchall()
            return result
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return []


def get_price_data(item):
    suggestion = ai.scrapeprice(item)
    
    SuggestedPrice = suggestion['summary']['suggested_price']
    MinPrice = suggestion['summary']['suggested_ranges']['midrange']['min']
    MaxPrice = suggestion['summary']['suggested_ranges']['midrange']['max']

    AmazonSP = None
    EbaySP = None
    MCSP = None
    WalmartSP = None
    AmazonDetails = ""
    EbayDetails = ""
    MCDetails = ""
    WalmartDetails = ""
   
    for source, data in suggestion['detailed'].items():
        if source.upper() == 'EBAY':
            EbaySP = data['suggested_price']
            EbayDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"
        elif source.upper() == 'MICROCENTER':
            MCSP = data['suggested_price']
            MCDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"
        elif source.upper() == 'AMAZON':
            AmazonSP = data['suggested_price']
            AmazonDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"        
        elif source.upper() == 'WALMART':
            WalmartSP = data['suggested_price']
            WalmartDetails = f"Item Count: {data['count']}, Price Range: ${data['min_price']} - ${data['max_price']}, Average Price: ${data['avg_price']}, Median Price: ${data['median_price']}, Standard Deviation: ${data['std_deviation']}"        

    # Return the collected data as a dictionary
    return {
        "summary": {
            "suggested_price": SuggestedPrice,
            "min_price": MinPrice,
            "max_price": MaxPrice
        },
        "sources": {
            "amazon": {"price": AmazonSP, "details": AmazonDetails},
            "ebay": {"price": EbaySP, "details": EbayDetails},
            "microcenter": {"price": MCSP, "details": MCDetails},
            "walmart": {"price": WalmartSP, "details": WalmartDetails}
        }
    }

def Comparison(mobile):

    db = Cred()
    
    products_ref = db.collection('products')
    
    products_docs = products_ref.stream()
    
    # Create a list to store all products
    all_products = []
    
    for doc in products_docs:
     # Get document data as dictionary
     product_data = doc.to_dict()
    
     # Add document ID to the dictionary
     product_data['document_id'] = doc.id
    
     # Add to our products list
     all_products.append(product_data)
    
    # Print all products
    print(f"Total products found: {len(all_products)}")

    a = []

    for array in mobile:
        a.append(array['I_MobileCode'])

    for product in all_products:
     if product['document_id'] not in a:
      print(f"Product ID: {product['document_id']}")
      print(f"Name: {product.get('name', 'N/A')}")
      print(f"Price: {product.get('price', 'N/A')}")
      print(f"Quantity: {product.get('quantity', 'N/A')}")
      print(f"Description: {product.get('description', 'N/A')}")
      print('-' * 30)
      get_item_price(product['document_id'],product.get('name', 'N/A'),product.get('price', 'N/A'),product.get('quantity', 'N/A'),product.get('description', 'N/A'))
     else:
        print("")
        # for array in mobile:
            # Update(array['I_Name'],array['I_Discount'],array['I_Stock'],array['I_UnitPrice'],array['I_Description'],array[''])
            
                # SELECT I_MobileCode, I_Name, I_Discount, I_UnitPrice, I_ImagePath, I_Stock, I_Description

def get_item_price(MobileCode, Name, Price, Stock, Desc):
    # Get price data from the get_price_data function
    suggestion = get_price_data(Name)
    
    # Extract all the required values from the suggestion dictionary
    SuggestedPrice = suggestion['summary']['suggested_price']
    MinPrice = suggestion['summary']['min_price']
    MaxPrice = suggestion['summary']['max_price']
    
    # Source-specific information
    AmazonSP = suggestion['sources']['amazon']['price']
    AmazonDetails = suggestion['sources']['amazon']['details']
    
    EbaySP = suggestion['sources']['ebay']['price']
    EbayDetails = suggestion['sources']['ebay']['details']
    
    MCSP = suggestion['sources']['microcenter']['price']
    MCDetails = suggestion['sources']['microcenter']['details']
    
    WalmartSP = suggestion['sources']['walmart']['price']
    WalmartDetails = suggestion['sources']['walmart']['details']
    
    """Add item to AI inventory database"""
    try:
        aiconn = get_connection('ai_inventory')
        cursor = aiconn.cursor()
                        
        webquery = """
             INSERT INTO `item`(`I_MobileCode`,  `I_Name`, `I_UnitPrice`,`I_Discount`,`I_Stock`,`I_Description`,
             `I_SuggestedPrice`, `I_MaxPriceRange`, `I_MinPriceRange`, `I_EbaySuggestedPrice`, 
             `I_EbayFullInfo`, `I_MCSuggestedPrice`, `I_MCFullInfo`, `I_AmazonSuggestedPrice`, 
             `I_AmazonFullInfo`, `I_WallmartSuggestedPrice`, `I_WallmartInfo`) 
             VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        Discount = 0
     
        cursor.execute(webquery, (
            MobileCode, Name, Price, Discount, Stock, Desc,
            SuggestedPrice, MaxPrice, MinPrice, 
            EbaySP, EbayDetails, 
            MCSP, MCDetails, 
            AmazonSP, AmazonDetails, 
            WalmartSP, WalmartDetails
        ))
            
        inserted_id = cursor.lastrowid
        ItemNum = 2000 + inserted_id

        legacyconn = get_connection('shop_inventory')
        cursor2 = legacyconn.cursor()

        discount = 0

        legacyquery = """
            INSERT INTO `item`( `itemNumber`, `itemName`, `discount`, `stock`, `unitPrice`, `description`) 
            VALUES (%s,%s,%s,%s,%s,%s)
        """

        cursor2.execute(legacyquery, (
            ItemNum, Name, discount, Stock, Price, Desc
        ))

        legacy_id = cursor2.lastrowid

        updatequery = """
            UPDATE `item` SET `I_LegacyCode`= %s WHERE `ItemID`= %s
        """

        cursor.execute(updatequery, (
            ItemNum, inserted_id
        ))

        legacyconn.commit()      
        aiconn.commit()
            
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")

def newproduct(ID, Name, Desc, Price, Quantity, URL):
    try:
        db = Cred()
        product_id = f"{ID}"
        
        qr_data = {
            "id": product_id,
            "name": Name,
            "price": str(Price),
            "quantity": str(Quantity)
        }

        db.collection('products').document(product_id).set({
            'id': product_id,
            'name': Name,
            'description': Desc,
            'price': Price,
            'quantity': Quantity,
            'image_url': URL,
            'qr_data': json.dumps(qr_data)
        })
        
        return True, f"Product {Name} (ID: {product_id}) added successfully."
    
    except Exception as e:
        error_message = f"Error adding product: {str(e)}"
        print(error_message)  # Log the error
        return False, error_message

def update_product(ID, Name=None, Desc=None, Price=None, Quantity=None, URL=None):

    try:
        db = Cred()
        product_id = str(ID)
        product_ref = db.collection('products').document(product_id)

        # Fetch existing data to update only provided fields
        existing_doc = product_ref.get()
        if existing_doc.exists:
            data = existing_doc.to_dict()
        else:
            data = {'id': product_id}

        # Update fields if provided
        if Name is not None:
            data['name'] = Name
        if Desc is not None:
            data['description'] = Desc
        if Price is not None:
            data['price'] = Price
        if Quantity is not None:
            data['quantity'] = Quantity
        if URL is not None:
            data['image_url'] = URL

        # Generate qr_data based on current data
        qr_data = {
            "id": product_id,
            "name": data.get('name', ''),
            "price": str(data.get('price', '')),
            "quantity": str(data.get('quantity', ''))
        }

        # Save updated data back to firestore
        product_ref.set({
            **data,
            'qr_data': json.dumps(qr_data)
        })

        return True, f"Product {data.get('name', '')} (ID: {product_id}) updated successfully."
    except Exception as e:
        error_message = f"Error updating product: {str(e)}"
        print(error_message)  # Log the error
        return False, error_message    
 

def syncronize():
    items = Info()
    Comparison(items)

#    mobile = getMobileCodes()
#    Comparison(mobile)
   

if __name__ == "__main__":
    syncronize()

