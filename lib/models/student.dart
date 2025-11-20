class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String studentNumber;
  final String className;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.studentNumber,
    required this.className,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'studentNumber': studentNumber,
      'className': className,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      studentNumber: map['studentNumber'] ?? '',
      className: map['className'] ?? '',
    );
  }

  factory Student.fromFirestore(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      studentNumber: data['studentNo'] ?? '',
      className: data['className'] ?? '',
    );
  }

  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? studentNumber,
    String? className,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentNumber: studentNumber ?? this.studentNumber,
      className: className ?? this.className,
    );
  }
}

