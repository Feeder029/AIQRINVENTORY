import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton constructor
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    
    // Open/create the database at a given path
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity INTEGER DEFAULT 0,
        description TEXT,
        price REAL,
        image_url TEXT
      )
    ''');
    
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Insert sample data after tables are created
    await insertSampleData();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing column if upgrading from version 1
      await db.execute('ALTER TABLE products ADD COLUMN image_url TEXT');
    }
    
    if (oldVersion < 3) {
      // Add users table if upgrading from version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          name TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }

  // User Authentication Methods
  
  // Register a new user
  Future<int> registerUser(String email, String password, {String? name}) async {
    final db = await database;
    
    // Check if email already exists
    final List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (existingUsers.isNotEmpty) {
      return -1; // Email already exists
    }
    
    // In a real app, you would hash the password before storing
    return await db.insert(
      'users',
      {
        'email': email,
        'password': password,
        'name': name,
      },
    );
  }
  
  // Authenticate user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
  
  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
  
  // Update user information
  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    final db = await database;
    
    return await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert initial sample data
  Future<void> insertSampleData() async {
    final db = await database;
    
    // Check if data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products')
    );
    
    if (count == 0) {
      // Insert sample products
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO products(id, name, quantity, description, price, image_url) VALUES(?, ?, ?, ?, ?, ?)',
          ['P001', 'Laptop', 10, 'High-performance gaming laptop', 1200.00, '']
        );
        
        await txn.rawInsert(
          'INSERT INTO products(id, name, quantity, description, price, image_url) VALUES(?, ?, ?, ?, ?, ?)',
          ['P002', 'Smartphone', 25, 'Latest model with 5G support', 800.00, '']
        );
        
        await txn.rawInsert(
          'INSERT INTO products(id, name, quantity, description, price, image_url) VALUES(?, ?, ?, ?, ?, ?)',
          ['P003', 'Headphones', 15, 'Noise-canceling wireless headphones', 250.00, '']
        );
        
        await txn.rawInsert(
          'INSERT INTO products(id, name, quantity, description, price, image_url) VALUES(?, ?, ?, ?, ?, ?)',
          ['P004', 'Tablet', 8, '10-inch tablet with stylus support', 450.00, '']
        );
        
        await txn.rawInsert(
          'INSERT INTO products(id, name, quantity, description, price, image_url) VALUES(?, ?, ?, ?, ?, ?)',
          ['P005', 'Smartwatch', 12, 'Fitness tracking and notifications', 180.00, '']
        );
      });
    }
    
    // Insert a demo user if no users exist
    final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    );
    
    if (userCount == 0) {
      await db.insert(
        'users',
        {
          'email': 'demo@example.com',
          'password': 'demo1234',
          'name': 'Demo User'
        },
      );
    }
  }

  // Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }

  // Get a single product by ID
  Future<Map<String, dynamic>?> getProductById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Add quantity to a product
  Future<int> addQuantity(String id, int amount) async {
    final db = await database;
    
    // First get current quantity
    final product = await getProductById(id);
    if (product == null) return 0;
    
    int currentQuantity = product['quantity'] as int;
    int newQuantity = currentQuantity + amount;
    
    return await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deduct quantity from a product
  Future<int> deductQuantity(String id, int amount) async {
    final db = await database;
    
    // First get current quantity
    final product = await getProductById(id);
    if (product == null) return 0;
    
    int currentQuantity = product['quantity'] as int;
    int newQuantity = currentQuantity - amount;
    
    // Prevent negative quantities
    if (newQuantity < 0) newQuantity = 0;
    
    return await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a new product
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing product
  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  // Delete a product
  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}