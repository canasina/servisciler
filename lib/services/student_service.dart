import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'students';

  // Singleton instance
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  // Mock data (geçici - Firebase olmadan çalışması için)
  static final List<Student> _mockStudents = [
    Student(
      id: '1',
      firstName: 'Ahmet',
      lastName: 'Yılmaz',
      studentNumber: '12345',
      className: '5-A',
    ),
    Student(
      id: '2',
      firstName: 'Ayşe',
      lastName: 'Demir',
      studentNumber: '12346',
      className: '5-B',
    ),
    Student(
      id: '3',
      firstName: 'Mehmet',
      lastName: 'Kaya',
      studentNumber: '12347',
      className: '6-A',
    ),
  ];

  // ========== STATIC METODLAR (ESKİ SİSTEM İÇİN) ==========
  
  static List<Student> getAllStudents() {
    return List.from(_mockStudents);
  }

  static int getStudentCount() {
    return _mockStudents.length;
  }

  static void addStudent(Student student) {
    _mockStudents.add(student);
  }

  static void updateStudent(int index, Student student) {
    if (index >= 0 && index < _mockStudents.length) {
      _mockStudents[index] = student;
    }
  }

  static void deleteStudent(int index) {
    if (index >= 0 && index < _mockStudents.length) {
      _mockStudents.removeAt(index);
    }
  }

  static Student? getStudentByIndex(int index) {
    if (index >= 0 && index < _mockStudents.length) {
      return _mockStudents[index];
    }
    return null;
  }

  // ========== INSTANCE METODLAR (YENİ FİREBASE SİSTEMİ İÇİN) ==========

  // Test verisi ekle (sadece geliştirme için)
  Future<void> addTestStudent() async {
    try {
      // Test öğrencisi var mı kontrol et
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('studentNo', isEqualTo: '12345')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Test öğrencisi yoksa ekle
        await _firestore.collection(_collectionName).add({
          'studentNo': '12345',
          'password': '123456',
          'firstName': 'Ahmet',
          'lastName': 'Yılmaz',
          'className': '5-A',
          'email': null, // İlk giriş için email yok
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Test öğrencisi eklendi (No: 12345, Şifre: 123456)');
      } else {
        print('ℹ️ Test öğrencisi zaten mevcut');
      }
    } catch (e) {
      print('❌ Test öğrencisi eklenirken hata: $e');
    }
  }

  // Tüm öğrencileri getir (Stream)
  Stream<List<Student>> getAllStudentsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('studentNo')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Tüm öğrencileri getir (Future)
  Future<List<Student>> getAllStudentsFuture() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('studentNo')
          .get();
      
      return snapshot.docs
          .map((doc) => Student.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Öğrenciler getirme hatası: $e');
      return [];
    }
  }

  // ID'ye göre öğrenci getir
  Future<Student?> getStudentById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Student.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Öğrenci getirme hatası: $e');
      return null;
    }
  }

  // Öğrenci ekle (Firestore)
  Future<String?> addStudentToFirestore(Student student, {String? password}) async {
    try {
      // Document ID oluştur: isimsoyisimnumara (küçük harf, boşluksuz, Türkçe karakterler düzeltilmiş)
      final firstName = _normalizeTurkishChars(student.firstName.toLowerCase().trim());
      final lastName = _normalizeTurkishChars(student.lastName.toLowerCase().trim());
      final studentNo = student.studentNumber.trim();
      final docId = '$firstName$lastName$studentNo';
      
      // Bu ID'ye sahip öğrenci var mı kontrol et
      final existingDoc = await _firestore.collection(_collectionName).doc(docId).get();
      if (existingDoc.exists) {
        // Eğer aynı ID'ye sahip öğrenci varsa, numara ile çakışma olabilir
        throw Exception('Bu öğrenci zaten kayıtlı! (${student.firstName} ${student.lastName} - $studentNo)');
      }
      
      // Belirli ID ile kayıt yap
      await _firestore.collection(_collectionName).doc(docId).set({
        'studentNo': student.studentNumber,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'className': student.className,
        'password': password ?? '123456', // Şifre parametresi veya varsayılan şifre
        'email': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return docId;
    } catch (e) {
      print('Öğrenci ekleme hatası: $e');
      return null;
    }
  }

  // Veli ekle (Firestore - parents koleksiyonu)
  Future<String?> addParentToFirestore({
    required String parentName,
    required String studentName,
    required String studentNumber,
    required String password,
    String? email,
  }) async {
    try {
      print('🔄 Veli kaydı oluşturuluyor...');
      print('  Veli Adı: "$parentName"');
      print('  Öğrenci: "$studentName"');
      print('  Numara: "$studentNumber"');
      
      // Document ID oluştur: veliadisoyadiogrencinumarası
      // Veli adındaki tüm boşlukları kaldır ve normalize et
      final trimmedParentName = parentName.trim();
      final normalizedParentName = _normalizeTurkishChars(trimmedParentName.toLowerCase());
      final studentNo = studentNumber.trim();
      final docId = '$normalizedParentName$studentNo';
      
      print('  Veli adı (trimmed): "$trimmedParentName"');
      print('  Veli adı (normalized): "$normalizedParentName"');
      print('  Öğrenci numarası: "$studentNo"');
      print('  Oluşturulan Document ID: "$docId"');
      
      // Veli kaydı oluştur
      final parentData = <String, dynamic>{
        'parentName': trimmedParentName,
        'studentName': studentName.trim(),
        'schoolNumber': studentNo,
        'password': password.trim(),
      };
      
      // Email varsa ekle
      if (email != null && email.trim().isNotEmpty) {
        parentData['email'] = email.trim();
        parentData['emailAddedAt'] = FieldValue.serverTimestamp();
      }
      
      print('  Kaydedilecek veriler: $parentData');
      print('  Firestore collection: parents');
      print('  Firestore document ID: $docId');
      
      await _firestore.collection('parents').doc(docId).set(parentData);
      
      print('✅ Firestore set() işlemi tamamlandı');
      print('✅ Veli kaydı başarıyla oluşturuldu: $docId');
      
      // Kaydın gerçekten oluşturulduğunu doğrula
      final verifyDoc = await _firestore.collection('parents').doc(docId).get();
      if (verifyDoc.exists) {
        print('✅ Veli kaydı doğrulandı: $docId mevcut');
        print('   Veriler: ${verifyDoc.data()}');
      } else {
        print('⚠️ UYARI: Veli kaydı oluşturuldu ama doğrulama sırasında bulunamadı!');
      }
      
      return docId;
    } on FirebaseException catch (e) {
      print('❌ Firebase Exception:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Stack: ${e.stackTrace}');
      return null;
    } catch (e, stackTrace) {
      print('❌ Genel Exception:');
      print('   Hata: $e');
      print('   Tip: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  // Türkçe karakterleri İngilizce karşılıklarına çevir
  String _normalizeTurkishChars(String text) {
    return text
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('Ç', 'c')
        .replaceAll('Ğ', 'g')
        .replaceAll('İ', 'i')
        .replaceAll('Ö', 'o')
        .replaceAll('Ş', 's')
        .replaceAll('Ü', 'u')
        .replaceAll(' ', ''); // Boşlukları kaldır
  }

  // Öğrenci güncelle
  Future<bool> updateStudentInFirestore(String id, Student student) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'studentNo': student.studentNumber,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'className': student.className,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Öğrenci güncelleme hatası: $e');
      return false;
    }
  }

  // Öğrenci sil
  Future<bool> deleteStudentFromFirestore(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      print('Öğrenci silme hatası: $e');
      return false;
    }
  }

  // Öğrenci sayısını getir (Firestore)
  Future<int> getStudentCountFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Öğrenci sayısı getirme hatası: $e');
      return 0;
    }
  }
}
