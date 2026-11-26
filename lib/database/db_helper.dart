import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/hostel_models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database?  _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hostel_mate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentName TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE hostel_info (
        id INTEGER PRIMARY KEY,
        breakfast TEXT NOT NULL,
        lunch TEXT NOT NULL,
        dinner TEXT NOT NULL,
        noticeTitle TEXT NOT NULL,
        noticeBody TEXT NOT NULL
      )
    ''');

    // Default demo student so login works right away too
    await db.insert('students', {
      'fullName': 'Bilal Haider',
      'roomNumber': 'B-204',
      'phone': '0300-1234567',
      'email': 'bilal@greenview.pk',
      'password': '123',
    });

    // Default Mess Menu & Notice
    await db.insert('hostel_info', {
      'id': 1,
      'breakfast': 'Paratha & Omelette • 7:30–9:00 AM',
      'lunch': 'Daal Chawal • 1:00–2:30 PM',
      'dinner': 'Chicken Karahi • 8:00–9:30 PM',
      'noticeTitle': 'Water Tank Cleaning',
      'noticeBody':
      'Supply will be paused on Saturday from 10:00 AM to 12:00 PM for overhead tank maintenance.',
    });

    // Initial sample complaints matching the Complaints design
    await db.insert('complaints', {
      'studentName': 'Bilal Haider',
      'roomNumber': 'B-204',
      'category': 'Electrical',
      'description':
      'Ceiling fan regulator is sparking at speed 3 and needs replacement.',
      'status': 'Pending',
      'createdAt': 'Today, 11:20 AM',
    });

    await db.insert('complaints', {
      'studentName': 'Hamza Tariq',
      'roomNumber': 'B-204',
      'category': 'Wi-Fi',
      'description':
      '2nd floor router restarted and signal strength restored in B-wing.',
      'status': 'Resolved',
      'createdAt': 'Yesterday, 6:45 PM',
    });
  }

  // --- Student Auth Methods ---
  Future<int> registerStudent(StudentUser student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<StudentUser?> loginStudent({
    required String identifier,
    required String password,
  }) async {
    final db = await database;
    final cleanId = identifier.trim();
    final cleanPass = password.trim();

    final rows = await db.query(
      'students',
      where: '(LOWER(email) = LOWER(?) OR LOWER(roomNumber) = LOWER(?)) AND password = ?',
      whereArgs: [cleanId, cleanId, cleanPass],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudentUser.fromMap(rows.first);
  }
  // Forget password
  Future<bool> resetStudentPassword({
    required String email,
    required String roomNumber,
    required String newPassword,
  }) async {
    final db = await database;
    final updatedRows = await db.update(
      'students',
      {'password': newPassword.trim()},
      where: 'LOWER(email) = LOWER(?) AND LOWER(roomNumber) = LOWER(?)',
      whereArgs: [email.trim(), roomNumber.trim()],
    );
    return updatedRows > 0;
  }

  // --- Hostel Info (Mess & Notice) ---
  Future<HostelInfo> getHostelInfo() async {
    final db = await database;
    final rows = await db.query(
      'hostel_info',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) {
      return HostelInfo(
        breakfast: 'Paratha & Omelette • 7:30–9:00 AM',
        lunch: 'Daal Chawal • 1:00–2:30 PM',
        dinner: 'Chicken Karahi • 8:00–9:30 PM',
        noticeTitle: 'Water Tank Cleaning',
        noticeBody:
        'Supply will be paused on Saturday from 10:00 AM to 12:00 PM for overhead tank maintenance.',
      );
    }
    return HostelInfo.fromMap(rows.first);
  }

  Future<int> updateHostelInfo(HostelInfo info) async {
    final db = await database;
    return await db.update(
      'hostel_info',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // --- Complaints CRUD ---
  Future<int> insertComplaint(ComplaintItem item) async {
    final db = await database;
    return await db.insert('complaints', item.toMap());
  }

  Future<List<ComplaintItem>> getComplaints({String filter = 'All'}) async {
    final db = await database;
    List<Map<String, dynamic>> rows;
    if (filter == 'Pending' || filter == 'Resolved') {
      rows = await db.query(
        'complaints',
        where: 'status = ?',
        whereArgs: [filter],
        orderBy: 'id DESC',
      );
    } else {
      rows = await db.query('complaints', orderBy: 'id DESC');
    }
    return rows.map((e) => ComplaintItem.fromMap(e)).toList();
  }


  Future<int> updateComplaintStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'complaints',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}