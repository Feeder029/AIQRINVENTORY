import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final String productsCollection = 'products';
  final String usersCollection = 'users';

  // --- Products Operations ---

  Future<List<Map<String, dynamic>>> getProducts() async {
    final snapshot = await _firestore.collection(productsCollection).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final doc = await _firestore.collection(productsCollection).doc(id).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    }
    return null;
  }

  Future<int> addQuantity(String id, int amount) async {
    final docRef = _firestore.collection(productsCollection).doc(id);
    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return 0;
      int currentQuantity = (snapshot.data()!['quantity'] ?? 0) as int;
      int newQuantity = currentQuantity + amount;
      transaction.update(docRef, {'quantity': newQuantity});
      return 1;
    }).then((_) => 1).catchError((_) => 0);
  }

  Future<int> deductQuantity(String id, int amount) async {
    final docRef = _firestore.collection(productsCollection).doc(id);
    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return 0;
      int currentQuantity = (snapshot.data()!['quantity'] ?? 0) as int;
      int newQuantity = currentQuantity - amount;
      if (newQuantity < 0) newQuantity = 0;
      transaction.update(docRef, {'quantity': newQuantity});
      return 1;
    }).then((_) => 1).catchError((_) => 0);
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    // CHANGED: Use the product's ID as the document ID
    String productId = product['id'] as String;
    await _firestore.collection(productsCollection).doc(productId).set(product);
    return 1;
  }

  Future<int> updateProduct(String id, Map<String, dynamic> product) async {
    await _firestore.collection(productsCollection).doc(id).update(product);
    return 1;
  }

  Future<int> deleteProduct(String id) async {
    await _firestore.collection(productsCollection).doc(id).delete();
    return 1;
  }

  // --- Users Operations ---

  Future<int> registerUser(String email, String password, {String? name}) async {
    final query = await _firestore.collection(usersCollection).where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return -1; // Email exists
    }
    await _firestore.collection(usersCollection).add({
      'email': email,
      'password': password,
      'name': name,
      'created_at': FieldValue.serverTimestamp(),
    });
    return 1;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final query = await _firestore.collection(usersCollection)
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return {'id': query.docs.first.id, ...query.docs.first.data()};
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final doc = await _firestore.collection(usersCollection).doc(id).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    }
    return null;
  }

  Future<int> updateUser(String id, Map<String, dynamic> userData) async {
    await _firestore.collection(usersCollection).doc(id).update(userData);
    return 1;
  }
}