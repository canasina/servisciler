class Driver {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String licenseNumber;
  final DriverStatus status;
  final String? assignedServiceId; // Atanmış servis ID'si
  final String? notes;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    required this.licenseNumber,
    required this.status,
    this.assignedServiceId,
    this.notes,
  });

  String get fullName => '$firstName $lastName';
  bool get hasService => assignedServiceId != null && assignedServiceId!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'licenseNumber': licenseNumber,
      'status': status.toString().split('.').last,
      'assignedServiceId': assignedServiceId,
      'notes': notes,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      licenseNumber: map['licenseNumber'] ?? '',
      status: DriverStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => DriverStatus.active,
      ),
      assignedServiceId: map['assignedServiceId'],
      notes: map['notes'],
    );
  }

  Driver copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? Function()? email,
    String? licenseNumber,
    DriverStatus? status,
    String? Function()? assignedServiceId,
    String? Function()? notes,
  }) {
    return Driver(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email != null ? email() : this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      status: status ?? this.status,
      assignedServiceId: assignedServiceId != null ? assignedServiceId() : this.assignedServiceId,
      notes: notes != null ? notes() : this.notes,
    );
  }
}

enum DriverStatus {
  active,
  inactive,
  onLeave,
}

extension DriverStatusExtension on DriverStatus {
  String get displayName {
    switch (this) {
      case DriverStatus.active:
        return 'Aktif';
      case DriverStatus.inactive:
        return 'Pasif';
      case DriverStatus.onLeave:
        return 'İzinli';
    }
  }

  int get colorValue {
    switch (this) {
      case DriverStatus.active:
        return 0xFF4CAF50; // Yeşil
      case DriverStatus.inactive:
        return 0xFF9E9E9E; // Gri
      case DriverStatus.onLeave:
        return 0xFFFF9800; // Turuncu
    }
  }
}

