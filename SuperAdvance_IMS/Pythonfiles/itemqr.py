from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import subprocess
import qrcode
import csv
import os
import base64
from io import BytesIO

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# ---------------------- CREATE RECEIPT QR & INPUT DATABASE ---------------------- #
# Generate QR Code
def generate_qr(ID,itemname,price,quantity,):
    # Create QR code data
    qr_data = f'{"id": {ID}, "name": {itemname}, "price": {price}, "quantity": {quantity}}'
    
    qr = qrcode.make(qr_data)
    
    # Save to file system
    qrname = f"QR_IMAGES/{itemname}.png"
    os.makedirs("QR_IMAGES", exist_ok=True)
    qr.save(qrname)
    print(f"QR code saved as {qrname}")
    
    # Also get binary data for database
    buffered = BytesIO()
    qr.save(buffered)
    qr_binary = buffered.getvalue()
    
    return qrname, qr_binary
