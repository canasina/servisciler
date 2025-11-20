import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/student.dart';
import '../services/student_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studentNumberController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  bool _isLoading = false;

  final List<String> _classOptions = [
    '1-A', '1-B', '2-A', '2-B', '3-A', '3-B', '4-A', '4-B'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Yeni öğrenci ID'si oluştur
      final studentCount = StudentService.getStudentCount();
      final newStudent = Student(
        id: 'student_$studentCount',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        studentNumber: _studentNumberController.text.trim(),
        className: _classNameController.text.trim(),
      );

      // Öğrenciyi ekle
      StudentService.addStudent(newStudent);

      // İleride Firebase'e kayıt yapılacak
      // await StudentService.saveToFirebase(newStudent);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context, true); // Başarılı olduğunu belirt
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF263238),
              Color(0xFF37474F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Text(
                          'Yeni Öğrenci Ekle',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Öğrenci bilgilerini giriniz',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Ad
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'Ad',
                          icon: FontAwesomeIcons.user,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ad alanı zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Soyad
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Soyad',
                          icon: FontAwesomeIcons.user,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Soyad alanı zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Öğrenci Numarası
                        _buildTextField(
                          controller: _studentNumberController,
                          label: 'Öğrenci Numarası',
                          icon: FontAwesomeIcons.hashtag,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Öğrenci numarası zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Sınıf
                        _buildDropdownField(),
                        const SizedBox(height: 40),
                        
                        // Kaydet Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Kaydet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Öğrenci Ekle',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: FaIcon(icon, color: const Color(0xFF2196F3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF2196F3),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            errorStyle: GoogleFonts.poppins(color: Colors.red[300]),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sınıf',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _classNameController.text.isEmpty
                ? null
                : _classNameController.text,
            decoration: InputDecoration(
              prefixIcon: const FaIcon(
                FontAwesomeIcons.graduationCap,
                color: Color(0xFF2196F3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF2196F3),
                  width: 2,
                ),
              ),
            ),
            dropdownColor: const Color(0xFF37474F),
            style: GoogleFonts.poppins(color: Colors.white),
            hint: Text(
              'Sınıf seçiniz',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            items: _classOptions.map((String className) {
              return DropdownMenuItem<String>(
                value: className,
                child: Text(className),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _classNameController.text = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Sınıf seçimi zorunludur';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

