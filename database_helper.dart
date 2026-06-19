import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'vyparsathi.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        buyingPrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        barcode TEXT
      )
    ''');

    // Bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billDate TEXT NOT NULL,
        subtotal REAL NOT NULL,
        grandTotal REAL NOT NULL
      )
    ''');

    // Bill items table
    await db.execute('''
      CREATE TABLE bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (billId) REFERENCES bills(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');
  }

  // ---------- Product CRUD ----------
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Product.fromMap(maps.first);
    return null;
  }

  // Update product quantity (for billing)
  Future<void> updateProductQuantity(int id, int newQuantity) async {
    final db = await database;
    await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Bill & Bill Items ----------
  Future<int> insertBill(Bill bill) async {
    final db = await database;
    return await db.insert('bills', bill.toMap());
  }

  Future<int> insertBillItem(BillItem item) async {
    final db = await database;
    return await db.insert('bill_items', item.toMap());
  }

  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bills');
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<BillItem>> getBillItems(int billId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_items',
      where: 'billId = ?',
      whereArgs: [billId],
    );
    return List.generate(maps.length, (i) => BillItem.fromMap(maps[i]));
  }

  // Get today's bills
  Future<List<Bill>> getTodaysBills() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'billDate >= ? AND billDate < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // ---------- Backup / Restore ----------
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'vyparsathi.db');
  }

  Future<void> backupDatabase(String destinationPath) async {
    final sourcePath = await getDatabasePath();
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destinationPath);
    } else {
      throw Exception('Database file does not exist.');
    }
  }

  Future<void> restoreDatabase(String sourcePath) async {
    final destPath = await getDatabasePath();
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destPath);
    } else {
      throw Exception('Backup file does not exist.');
    }
  }
}
