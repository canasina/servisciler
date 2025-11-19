import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parent_login_screen.dart';
import 'driver_login_screen.dart';
import 'school_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              Color(0xFF263238), // Koyu gri
              Color(0xFF37474F), // Biraz daha açık koyu gri
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst boşluk
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Otobüs ikonu
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3), // Mavi
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Hoş Geldiniz başlığı
                    Text(
                      'Hoş Geldiniz',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Alt başlık
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Lütfen giriş yapmak için rolünüzü seçin.',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Butonlar bölümü
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Veli butonu
                      _RoleButton(
                        icon: FontAwesomeIcons.users,
                        label: 'Veli',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParentLoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Şoför butonu
                      _RoleButton(
                        icon: Icons.arrow_upward,
                        label: 'Şoför',
                        isMaterialIcon: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DriverLoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Okul butonu
                      _RoleButton(
                        icon: FontAwesomeIcons.graduationCap,
                        label: 'Okul',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchoolLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Alt linkler
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Kullanım Koşulları
                      },
                      child: Text(
                        'Kullanım Koşulları',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Gizlilik Politikası
                      },
                      child: Text(
                        'Gizlilik Politikası',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isMaterialIcon;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isMaterialIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // Mavi
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isMaterialIcon
                ? Icon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  )
                : FaIcon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
