import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'services/student_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase başarıyla başlatıldı!');
    
    // Test verileri ekle (sadece geliştirme için)
    final studentService = StudentService();
    await studentService.addTestStudent();
    await _addTestDriver();
    await _addTestSchool();
  } catch (e) {
    print('❌ Firebase başlatma hatası: $e');
  }
  
  runApp(const MyApp());
}

// Test şoför verisi ekle
Future<void> _addTestDriver() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Test şoförü var mı kontrol et
    final querySnapshot = await firestore
        .collection('drivers')
        .where('username', isEqualTo: 'driver123')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Test şoförü yoksa ekle
      await firestore.collection('drivers').add({
        'username': 'driver123',
        'password': '123456',
        'driverName': 'Mehmet Şoför',
        'licensePlate': '34 ABC 123',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Test şoförü eklendi (Username: driver123, Şifre: 123456)');
    } else {
      print('ℹ️ Test şoförü zaten mevcut');
    }
  } catch (e) {
    print('❌ Test şoförü eklenirken hata: $e');
  }
}

// Test okul verisi ekle
Future<void> _addTestSchool() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Test okulu var mı kontrol et
    final querySnapshot = await firestore
        .collection('schools')
        .where('username', isEqualTo: 'school123')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Test okulu yoksa ekle
      await firestore.collection('schools').add({
        'username': 'school123',
        'password': '123456',
        'schoolName': 'Atatürk İlkokulu',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Test okulu eklendi (Username: school123, Şifre: 123456)');
    } else {
      print('ℹ️ Test okulu zaten mevcut');
    }
  } catch (e) {
    print('❌ Test okulu eklenirken hata: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servis Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
