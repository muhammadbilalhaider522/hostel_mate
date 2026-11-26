class StudentUser {
  final int? id;
  final String fullName;
  final String roomNumber;
  final String phone;
  final String email;
  final String password;

  StudentUser({
    this.id,
    required this.fullName,
    required this.roomNumber,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'roomNumber': roomNumber,
    'phone': phone,
    'email': email,
    'password': password,
  };

  factory StudentUser.fromMap(Map<String, dynamic> map) => StudentUser(
    id: map['id'] as int?,
    fullName: map['fullName'] as String,
    roomNumber: map['roomNumber'] as String,
    phone: map['phone'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
  );
}

class ComplaintItem {
  final int? id;
  final String studentName;
  final String roomNumber;
  final String category;
  final String description;
  final String status;
  final String createdAt;

  ComplaintItem({
    this.id,
    required this.studentName,
    required this.roomNumber,
    required this.category,
    required this.description,
    this.status = 'Pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentName': studentName,
    'roomNumber': roomNumber,
    'category': category,
    'description': description,
    'status': status,
    'createdAt': createdAt,
  };

  factory ComplaintItem.fromMap(Map<String, dynamic> map) => ComplaintItem(
    id: map['id'] as int?,
    studentName: map['studentName'] as String,
    roomNumber: map['roomNumber'] as String,
    category: map['category'] as String,
    description: map['description'] as String,
    status: map['status'] as String,
    createdAt: map['createdAt'] as String,
  );
}

class HostelInfo {
  final String breakfast;
  final String lunch;
  final String dinner;
  final String noticeTitle;
  final String noticeBody;

  HostelInfo({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.noticeTitle,
    required this.noticeBody,
  });

  Map<String, dynamic> toMap() => {
    'id': 1,
    'breakfast': breakfast,
    'lunch': lunch,
    'dinner': dinner,
    'noticeTitle': noticeTitle,
    'noticeBody': noticeBody,
  };

  factory HostelInfo.fromMap(Map<String, dynamic> map) => HostelInfo(
    breakfast: map['breakfast'] as String,
    lunch: map['lunch'] as String,
    dinner: map['dinner'] as String,
    noticeTitle: map['noticeTitle'] as String,
    noticeBody: map['noticeBody'] as String,
  );
}