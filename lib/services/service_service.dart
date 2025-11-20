import '../models/service.dart';

class ServiceService {
  // Şimdilik local liste, ileride Firebase'den çekilecek
  static List<Service> _services = _generateSampleServices();

  static List<Service> _generateSampleServices() {
    final List<Service> services = [];
    
    final List<String> plateNumbers = [
      '34 ABC 123', '34 DEF 456', '34 GHI 789', '34 JKL 012',
      '34 MNO 345', '34 PQR 678', '34 STU 901', '34 VWX 234',
      '34 YZA 567', '34 BCD 890', '34 EFG 123', '34 HIJ 456'
    ];

    final List<String> driverNames = [
      'Mehmet Yılmaz', 'Ali Demir', 'Hasan Kaya', 'Mustafa Şahin',
      'İbrahim Çelik', 'Osman Yıldız', 'Yusuf Öztürk', 'Emre Aydın',
      'Burak Kılıç', 'Can Aslan', 'Deniz Kurt', 'Ege Koç'
    ];

    final List<String> routeNames = [
      'Merkez - Okul', 'Şehir Merkezi - Okul', 'Mahalle 1 - Okul',
      'Mahalle 2 - Okul', 'Mahalle 3 - Okul', 'Mahalle 4 - Okul',
      'Mahalle 5 - Okul', 'Mahalle 6 - Okul', 'Mahalle 7 - Okul',
      'Mahalle 8 - Okul', 'Mahalle 9 - Okul', 'Mahalle 10 - Okul'
    ];

    for (int i = 0; i < 12; i++) {
      final status = i < 10 
          ? ServiceStatus.active 
          : (i == 10 ? ServiceStatus.maintenance : ServiceStatus.inactive);
      
      // Bazı servislere örnek öğrenci ID'leri atanıyor
      final List<String> assignedIds = [];
      if (i < 8) {
        // İlk 8 servise 15-25 arası öğrenci atanıyor
        final studentCount = 15 + (i * 2);
        for (int j = 0; j < studentCount && j < 30; j++) {
          assignedIds.add('student_${i * 10 + j}');
        }
      }

      services.add(Service(
        id: 'service_$i',
        plateNumber: plateNumbers[i],
        driverName: driverNames[i],
        routeName: routeNames[i],
        capacity: 30,
        status: status,
        assignedStudentIds: assignedIds,
        notes: i == 10 ? 'Motor bakımı yapılıyor' : null,
      ));
    }

    return services;
  }

  static List<Service> getAllServices() {
    return List.from(_services);
  }

  static List<Service> getActiveServices() {
    return _services.where((s) => s.status == ServiceStatus.active).toList();
  }

  static int getTotalServices() {
    return _services.length;
  }

  static int getActiveServicesCount() {
    return _services.where((s) => s.status == ServiceStatus.active).length;
  }

  static int getTotalCapacity() {
    return _services.fold(0, (sum, service) => sum + service.capacity);
  }

  static int getTodayWorkingServices() {
    return _services.where((s) => s.status == ServiceStatus.active).length;
  }

  static void addService(Service service) {
    _services.add(service);
    // İleride burada Firebase'e kayıt yapılacak
  }

  static void updateService(Service service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
      // İleride burada Firebase'de güncelleme yapılacak
    }
  }

  static void deleteService(String id) {
    _services.removeWhere((service) => service.id == id);
    // İleride burada Firebase'den silme yapılacak
  }

  static Service? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  static void assignStudentToService(String serviceId, String studentId) {
    final service = getServiceById(serviceId);
    if (service != null && !service.isFull) {
      if (!service.assignedStudentIds.contains(studentId)) {
        final updatedService = service.copyWith(
          assignedStudentIds: [...service.assignedStudentIds, studentId],
        );
        updateService(updatedService);
      }
    }
  }

  static void removeStudentFromService(String serviceId, String studentId) {
    final service = getServiceById(serviceId);
    if (service != null) {
      final updatedIds = service.assignedStudentIds.where((id) => id != studentId).toList();
      final updatedService = service.copyWith(
        assignedStudentIds: updatedIds,
      );
      updateService(updatedService);
    }
  }

  // İleride Firebase'den veri çekmek için
  static Future<void> loadFromFirebase() async {
    // Firebase implementasyonu buraya gelecek
  }

  // İleride Firebase'e kaydetmek için
  static Future<void> saveToFirebase(Service service) async {
    // Firebase implementasyonu buraya gelecek
  }

  // Şoför listesi (ileride Firebase'den çekilecek)
  static List<String> getAvailableDrivers() {
    return [
      'Mehmet Yılmaz', 'Ali Demir', 'Hasan Kaya', 'Mustafa Şahin',
      'İbrahim Çelik', 'Osman Yıldız', 'Yusuf Öztürk', 'Emre Aydın',
      'Burak Kılıç', 'Can Aslan', 'Deniz Kurt', 'Ege Koç',
      'Furkan Yıldırım', 'Gökhan Ateş', 'Hakan Bulut', 'İlker Güneş'
    ];
  }

  // Rota listesi (ileride Firebase'den çekilecek)
  static List<String> getAvailableRoutes() {
    return [
      'Merkez - Okul', 'Şehir Merkezi - Okul', 'Mahalle 1 - Okul',
      'Mahalle 2 - Okul', 'Mahalle 3 - Okul', 'Mahalle 4 - Okul',
      'Mahalle 5 - Okul', 'Mahalle 6 - Okul', 'Mahalle 7 - Okul',
      'Mahalle 8 - Okul', 'Mahalle 9 - Okul', 'Mahalle 10 - Okul',
      'Mahalle 11 - Okul', 'Mahalle 12 - Okul', 'Mahalle 13 - Okul'
    ];
  }
}

