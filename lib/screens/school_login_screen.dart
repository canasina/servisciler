import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'school_home_screen.dart';

class SchoolLoginScreen extends StatefulWidget {
  const SchoolLoginScreen({super.key});

  @override
  State<SchoolLoginScreen> createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş yap
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Firestore'dan okul bilgisini kontrol et
      final querySnapshot = await _firestore
          .collection('schools')
          .where('schoolID', isEqualTo: username)
          .where('schoolPass', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Okul bulunamadı veya şifre yanlış
        if (mounted) {
          _showErrorDialog('Giriş Hatası', 
            'Kullanıcı adı veya şifre hatalı. Lütfen tekrar deneyin.');
        }
        return;
      }

      // Okul bulundu
      final schoolDoc = querySnapshot.docs.first;
      final schoolData = schoolDoc.data();
      final schoolId = schoolDoc.id;
      final schoolName = schoolData['schoolName'] as String?;

      if (mounted) {
        // Ana sayfaya git
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolHomeScreen(
              schoolId: schoolId,
              schoolName: schoolName ?? 'Okul',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Hata', 'Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            child: Text('Tamam', style: GoogleFonts.poppins(color: const Color(0xFF0A66C2))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Geri dön butonu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0A66C2)),
                    onPressed: () => Navigator.pop(context),
                  ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // İkon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A66C2).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Color(0xFF0A66C2),
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Başlık
                      Text(
                        'Okul Girişi',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Kullanıcı adı ve şifrenizle giriş yapın',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Kullanıcı adı
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Kullanıcı Adı',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kullanıcı adı gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Şifre
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Şifre',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF666666),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre gerekli';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Giriş butonu
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A66C2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            shadowColor: const Color(0xFF0A66C2).withOpacity(0.3),
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Giriş Yap',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0A66C2),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
