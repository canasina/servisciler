import '../models/driver.dart';
import 'service_service.dart';

class DriverService {
  // Şimdilik local liste, ileride Firebase'den çekilecek
  static List<Driver> _drivers = _generateSampleDrivers();

  static List<Driver> _generateSampleDrivers() {
    final List<Driver> drivers = [];
    
    final List<Map<String, String>> driverData = [
      {'firstName': 'Mehmet', 'lastName': 'Yılmaz', 'phone': '0532 111 2233', 'license': 'DL-12345'},
      {'firstName': 'Ali', 'lastName': 'Demir', 'phone': '0532 222 3344', 'license': 'DL-12346'},
      {'firstName': 'Hasan', 'lastName': 'Kaya', 'phone': '0532 333 4455', 'license': 'DL-12347'},
      {'firstName': 'Mustafa', 'lastName': 'Şahin', 'phone': '0532 444 5566', 'license': 'DL-12348'},
      {'firstName': 'İbrahim', 'lastName': 'Çelik', 'phone': '0532 555 6677', 'license': 'DL-12349'},
      {'firstName': 'Osman', 'lastName': 'Yıldız', 'phone': '0532 666 7788', 'license': 'DL-12350'},
      {'firstName': 'Yusuf', 'lastName': 'Öztürk', 'phone': '0532 777 8899', 'license': 'DL-12351'},
      {'firstName': 'Emre', 'lastName': 'Aydın', 'phone': '0532 888 9900', 'license': 'DL-12352'},
      {'firstName': 'Burak', 'lastName': 'Kılıç', 'phone': '0532 999 0011', 'license': 'DL-12353'},
      {'firstName': 'Can', 'lastName': 'Aslan', 'phone': '0532 000 1122', 'license': 'DL-12354'},
      {'firstName': 'Deniz', 'lastName': 'Kurt', 'phone': '0532 111 2234', 'license': 'DL-12355'},
      {'firstName': 'Ege', 'lastName': 'Koç', 'phone': '0532 222 3345', 'license': 'DL-12356'},
      {'firstName': 'Furkan', 'lastName': 'Yıldırım', 'phone': '0532 333 4456', 'license': 'DL-12357'},
      {'firstName': 'Gökhan', 'lastName': 'Ateş', 'phone': '0532 444 5567', 'license': 'DL-12358'},
      {'firstName': 'Hakan', 'lastName': 'Bulut', 'phone': '0532 555 6678', 'license': 'DL-12359'},
      {'firstName': 'İlker', 'lastName': 'Güneş', 'phone': '0532 666 7789', 'license': 'DL-12360'},
    ];

    // Servis listesini al
    final services = ServiceService.getAllServices();

    for (int i = 0; i < driverData.length; i++) {
      final data = driverData[i];
      final status = i < 12 
          ? DriverStatus.active 
          : (i == 12 ? DriverStatus.onLeave : DriverStatus.inactive);
      
      // İlk 12 şoföre servis ata (eğer servis varsa)
      String? assignedServiceId;
      if (i < services.length && status == DriverStatus.active) {
        assignedServiceId = services[i].id;
      }

      drivers.add(Driver(
        id: 'driver_$i',
        firstName: data['firstName']!,
        lastName: data['lastName']!,
        phoneNumber: data['phone']!,
        email: i % 3 == 0 ? '${data['firstName']!.toLowerCase()}.${data['lastName']!.toLowerCase()}@email.com' : null,
        licenseNumber: data['license']!,
        status: status,
        assignedServiceId: assignedServiceId,
        notes: i == 12 ? 'Yıllık izin' : null,
      ));
    }

    return drivers;
  }

  static List<Driver> getAllDrivers() {
    return List.from(_drivers);
  }

  static List<Driver> getActiveDrivers() {
    return _drivers.where((d) => d.status == DriverStatus.active).toList();
  }

  static int getTotalDrivers() {
    return _drivers.length;
  }

  static int getActiveDriversCount() {
    return _drivers.where((d) => d.status == DriverStatus.active).length;
  }

  static int getDriversWithServiceCount() {
    return _drivers.where((d) => d.hasService && d.status == DriverStatus.active).length;
  }

  static int getDriversWithoutServiceCount() {
    return _drivers.where((d) => !d.hasService && d.status == DriverStatus.active).length;
  }

  static void addDriver(Driver driver) {
    _drivers.add(driver);
    // İleride burada Firebase'e kayıt yapılacak
  }

  static void updateDriver(Driver driver) {
    final index = _drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      _drivers[index] = driver;
      // İleride burada Firebase'de güncelleme yapılacak
    }
  }

  static void deleteDriver(String id) {
    _drivers.removeWhere((driver) => driver.id == id);
    // İleride burada Firebase'den silme yapılacak
  }

  static Driver? getDriverById(String id) {
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  static void assignServiceToDriver(String driverId, String serviceId) {
    final driver = getDriverById(driverId);
    if (driver != null) {
      // Eski servisten şoförü çıkar
      if (driver.assignedServiceId != null) {
        removeDriverFromService(driver.assignedServiceId!);
      }
      
      // Yeni servise şoförü ata
      final service = ServiceService.getServiceById(serviceId);
      if (service != null) {
        final updatedDriver = driver.copyWith(assignedServiceId: () => serviceId);
        updateDriver(updatedDriver);
        
        // Servis bilgisini güncelle (eğer servis modelinde driverId varsa)
        // Şimdilik sadece driver tarafında tutuyoruz
      }
    }
  }

  static void removeDriverFromService(String serviceId) {
    try {
      final driver = _drivers.firstWhere((d) => d.assignedServiceId == serviceId);
      final updatedDriver = driver.copyWith(assignedServiceId: () => null);
      updateDriver(updatedDriver);
    } catch (e) {
      // Şoför bulunamadı, işlem yapma
    }
  }

  static void removeServiceFromDriver(String driverId) {
    final driver = getDriverById(driverId);
    if (driver != null) {
      final updatedDriver = driver.copyWith(assignedServiceId: () => null);
      updateDriver(updatedDriver);
    }
  }

  // İleride Firebase'den veri çekmek için
  static Future<void> loadFromFirebase() async {
    // Firebase implementasyonu buraya gelecek
  }

  // İleride Firebase'e kaydetmek için
  static Future<void> saveToFirebase(Driver driver) async {
    // Firebase implementasyonu buraya gelecek
  }
}

