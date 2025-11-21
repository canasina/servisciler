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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _classOptions = [
    '1-A', '1-B', '2-A', '2-B', '3-A', '3-B', '4-A', '4-B',
    '5-A', '5-B', '6-A', '6-B', '7-A', '7-B', '8-A', '8-B'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    _classNameController.dispose();
    _passwordController.dispose();
    _parentNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Yeni öğrenci oluştur
        final newStudent = Student(
          id: '', // Firebase otomatik ID oluşturacak
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          className: _classNameController.text.trim(),
        );

        // Firebase'e öğrenciyi ekle
        final studentService = StudentService();
        final password = _passwordController.text.trim();
        
        // Öğrenciyi Firebase'e ekle
        final docId = await studentService.addStudentToFirestore(newStudent, password: password);
        
        if (docId == null) {
          // Öğrenci eklenemedi
          if (mounted) {
            _showErrorDialog('Hata', 'Öğrenci eklenirken bir hata oluştu. Lütfen tekrar deneyin.');
          }
          return;
        }
        
        // Başarılı
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Öğrenci başarıyla eklendi',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Hata durumu
        if (mounted) {
          _showErrorDialog('Hata', 'Bir hata oluştu: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam', style: GoogleFonts.poppins(color: const Color(0xFF2196F3))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
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
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000000),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Öğrenci bilgilerini giriniz',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF666666),
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
                        const SizedBox(height: 20),
                        
                        // Şifre
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        
                        // Veli Adı
                        _buildTextField(
                          controller: _parentNameController,
                          label: 'Veli Adı Soyadı',
                          icon: FontAwesomeIcons.userTie,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veli adı zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Email (Opsiyonel)
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email (Opsiyonel)',
                          icon: FontAwesomeIcons.envelope,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              // Email formatı kontrolü
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Geçerli bir email adresi giriniz';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        
                        // Kaydet Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A66C2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF0A66C2).withOpacity(0.4),
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
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Öğrenci Ekle',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
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
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(color: const Color(0xFF000000)),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FaIcon(icon, color: const Color(0xFF0A66C2), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0A66C2),
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
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _classNameController.text.isEmpty
                ? null
                : _classNameController.text,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: FaIcon(
                  FontAwesomeIcons.graduationCap,
                  color: const Color(0xFF0A66C2),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
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
                  color: Color(0xFF0A66C2),
                  width: 2,
                ),
              ),
            ),
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(color: const Color(0xFF000000)),
            hint: Text(
              'Sınıf seçiniz',
              style: GoogleFonts.poppins(
                color: const Color(0xFF999999),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şifre',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Şifre zorunludur';
            }
            if (value.length < 4) {
              return 'Şifre en az 4 karakter olmalıdır';
            }
            return null;
          },
          style: GoogleFonts.poppins(color: const Color(0xFF000000)),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FaIcon(
                FontAwesomeIcons.lock,
                color: const Color(0xFF0A66C2),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF0A66C2),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0A66C2),
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
}

