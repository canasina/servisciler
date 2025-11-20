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
  Future<String?> addStudentToFirestore(Student student) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add({
        'studentNo': student.studentNumber,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'className': student.className,
        'password': '123456', // Varsayılan şifre
        'email': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Öğrenci ekleme hatası: $e');
      return null;
    }
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
