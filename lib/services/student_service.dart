import '../models/student.dart';

class StudentService {
  // Şimdilik local liste, ileride Firebase'den çekilecek
  static List<Student> _students = _generateSampleStudents();

  static List<Student> _generateSampleStudents() {
    final List<Student> students = [];
    final List<String> firstNames = [
      'Ahmet', 'Mehmet', 'Ali', 'Mustafa', 'Hasan', 'Hüseyin', 'İbrahim', 'Osman',
      'Yusuf', 'Emre', 'Burak', 'Can', 'Deniz', 'Ege', 'Kaan', 'Arda', 'Berk',
      'Cem', 'Doruk', 'Efe', 'Furkan', 'Gökhan', 'Hakan', 'İlker', 'Kemal',
      'Ayşe', 'Fatma', 'Zeynep', 'Elif', 'Merve', 'Selin', 'Dilara', 'Büşra',
      'Ceren', 'Derya', 'Esra', 'Gizem', 'Hande', 'İrem', 'Kübra', 'Leyla',
      'Melis', 'Nazlı', 'Özge', 'Pınar', 'Seda', 'Tuğba', 'Yasemin', 'Zehra',
      'Ada', 'Aylin', 'Beren', 'Ceylin', 'Defne', 'Ece', 'Fulya', 'Gamze',
      'Hazal', 'İpek', 'Jale', 'Kiraz', 'Lara', 'Mina', 'Nisa', 'Öykü',
      'Pelin', 'Rana', 'Selin', 'Tuba', 'Umay', 'Vildan', 'Yaren', 'Zara'
    ];

    final List<String> lastNames = [
      'Yılmaz', 'Kaya', 'Demir', 'Şahin', 'Çelik', 'Yıldız', 'Yıldırım', 'Öztürk',
      'Aydın', 'Özdemir', 'Arslan', 'Doğan', 'Kılıç', 'Aslan', 'Çetin', 'Kara',
      'Koç', 'Kurt', 'Özkan', 'Şimşek', 'Polat', 'Öz', 'Yücel', 'Erdoğan',
      'Ateş', 'Bulut', 'Güneş', 'Taş', 'Toprak', 'Su', 'Deniz', 'Göl',
      'Dağ', 'Orman', 'Çiçek', 'Gül', 'Yıldız', 'Ay', 'Güneş', 'Yıldırım'
    ];

    final List<String> classes = ['1-A', '1-B', '2-A', '2-B', '3-A', '3-B', '4-A', '4-B'];

    for (int i = 0; i < 75; i++) {
      final firstName = firstNames[i % firstNames.length];
      final lastName = lastNames[i % lastNames.length];
      final className = classes[i % classes.length];
      final studentNumber = '${1000 + i}';

      students.add(Student(
        id: 'student_$i',
        firstName: firstName,
        lastName: lastName,
        studentNumber: studentNumber,
        className: className,
      ));
    }

    return students;
  }

  static List<Student> getAllStudents() {
    return List.from(_students);
  }

  static int getStudentCount() {
    return _students.length;
  }

  static void addStudent(Student student) {
    _students.add(student);
    // İleride burada Firebase'e kayıt yapılacak
  }

  static void deleteStudent(String id) {
    _students.removeWhere((student) => student.id == id);
    // İleride burada Firebase'den silme yapılacak
  }

  // İleride Firebase'den veri çekmek için
  static Future<void> loadFromFirebase() async {
    // Firebase implementasyonu buraya gelecek
  }

  // İleride Firebase'e kaydetmek için
  static Future<void> saveToFirebase(Student student) async {
    // Firebase implementasyonu buraya gelecek
  }
}

