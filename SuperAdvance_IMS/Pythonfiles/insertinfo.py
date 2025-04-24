from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import itemqr
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

def get_connection(database_name):
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database=database_name
    )

def inputLegacySale():
    try:
        conn = get_connection('shop_inventory')
        cursor = conn.cursor

        sql = """
        INSERT INTO `item`(`itemNumber`, `itemName`, `discount`, `stock`, `unitPrice`, `imageURL`, `status`, `description`) 
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """; 

        cursor.execute(sql,{
        })
        
        conn.commit();
    

    
    

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return jsonify({"status": "error", "message": str(err)}), 500
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()


