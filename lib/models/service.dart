class Service {
  final String id;
  final String plateNumber;
  final String driverName;
  final String routeName;
  final int capacity;
  final ServiceStatus status;
  final List<String> assignedStudentIds; // Öğrenci ID'leri
  final String? notes;

  Service({
    required this.id,
    required this.plateNumber,
    required this.driverName,
    required this.routeName,
    required this.capacity,
    required this.status,
    this.assignedStudentIds = const [],
    this.notes,
  });

  int get currentStudentCount => assignedStudentIds.length;
  bool get isFull => currentStudentCount >= capacity;
  int get availableSeats => capacity - currentStudentCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'driverName': driverName,
      'routeName': routeName,
      'capacity': capacity,
      'status': status.toString().split('.').last,
      'assignedStudentIds': assignedStudentIds,
      'notes': notes,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      driverName: map['driverName'] ?? '',
      routeName: map['routeName'] ?? '',
      capacity: map['capacity'] ?? 0,
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ServiceStatus.active,
      ),
      assignedStudentIds: List<String>.from(map['assignedStudentIds'] ?? []),
      notes: map['notes'],
    );
  }

  Service copyWith({
    String? id,
    String? plateNumber,
    String? driverName,
    String? routeName,
    int? capacity,
    ServiceStatus? status,
    List<String>? assignedStudentIds,
    String? Function()? notes,
  }) {
    return Service(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      driverName: driverName ?? this.driverName,
      routeName: routeName ?? this.routeName,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      assignedStudentIds: assignedStudentIds ?? this.assignedStudentIds,
      notes: notes != null ? notes() : this.notes,
    );
  }
}

enum ServiceStatus {
  active,
  inactive,
  maintenance,
}

extension ServiceStatusExtension on ServiceStatus {
  String get displayName {
    switch (this) {
      case ServiceStatus.active:
        return 'Aktif';
      case ServiceStatus.inactive:
        return 'Pasif';
      case ServiceStatus.maintenance:
        return 'Bakımda';
    }
  }

  int get colorValue {
    switch (this) {
      case ServiceStatus.active:
        return 0xFF4CAF50; // Yeşil
      case ServiceStatus.inactive:
        return 0xFF9E9E9E; // Gri
      case ServiceStatus.maintenance:
        return 0xFFFF9800; // Turuncu
    }
  }
}

