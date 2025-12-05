import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_list.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        price REAL,
        isPurchased INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        purchasedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_salaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        UNIQUE(year, month)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE monthly_salaries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          year INTEGER NOT NULL,
          month INTEGER NOT NULL,
          amount REAL NOT NULL,
          createdAt INTEGER NOT NULL,
          UNIQUE(year, month)
        )
      ''');
    }
  }

  Future<int> createProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'createdAt DESC');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsToBuy() async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'isPurchased = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getPurchasedProducts() async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'isPurchased = ?',
      whereArgs: [1],
      orderBy: 'purchasedAt DESC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getPurchasedProductsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'isPurchased = ? AND purchasedAt >= ? AND purchasedAt <= ?',
      whereArgs: [1, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'purchasedAt DESC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
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
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Salary methods
  Future<int> setSalary(int year, int month, double amount) async {
    final db = await database;
    return await db.insert('monthly_salaries', {
      'year': year,
      'month': month,
      'amount': amount,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double?> getSalary(int year, int month) async {
    final db = await database;
    final result = await db.query(
      'monthly_salaries',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
    if (result.isEmpty) return null;
    return result.first['amount'] as double;
  }

  Future<Map<String, double>> getAllSalaries() async {
    final db = await database;
    final result = await db.query(
      'monthly_salaries',
      orderBy: 'year DESC, month DESC',
    );
    final Map<String, double> salaries = {};
    for (var row in result) {
      final key = '${row['year']}-${row['month']}';
      salaries[key] = row['amount'] as double;
    }
    return salaries;
  }
}
