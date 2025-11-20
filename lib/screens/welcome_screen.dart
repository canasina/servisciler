import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parent_login_screen.dart';
import 'driver_login_screen.dart';
import 'school_login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/anasayfa.png',
    'assets/images/anasayfa2.png',
    'assets/images/anasayfa3.png',
  ];

  @override
  void initState() {
    super.initState();
    // Otomatik sayfa değiştirme
    Future.delayed(const Duration(seconds: 3), () {
      _autoScroll();
    });
  }

  void _autoScroll() {
    if (mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_pageController.hasClients && mounted) {
          int nextPage = (_currentPage + 1) % _images.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          _autoScroll();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo üst kısımda
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 20, right: 20), // Vertical padding azaltıldı
              child: Image.asset(
                'assets/images/okulyolum.png',
                height: 75, // 1.5 kat büyütüldü (50 * 1.5 = 75)
                fit: BoxFit.contain,
              ),
            ),

            // Carousel - Resimler
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        // İlk resim (anasayfa.png) biraz büyük, diğerleri 1.2 kat büyük
                        final scale = index == 0 ? 1.15 : 1.2;
                        final horizontalPadding = index == 0 ? 25.0 : 20.0;
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Transform.scale(
                              scale: scale,
                              child: Image.asset(
                                _images[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sayfa göstergeleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF0A66C2)
                              : const Color(0xFFD0D0D0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Butonlar - LinkedIn tarzı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hoş geldiniz metni - Siyah renkli
                  Text(
                    'Okul Servis Takip Sistemi',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                      letterSpacing: 0.3,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Giriş yapmak için rolünüzü seçin',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                    // Veli butonu
                    _LinkedInStyleButton(
                      label: 'Veli Girişi',
                      icon: Icons.family_restroom,
                      isPrimary: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParentLoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Şoför butonu
                    _LinkedInStyleButton(
                      label: 'Şoför Girişi',
                      icon: Icons.local_shipping,
                      isPrimary: true, // false'dan true'ya değiştirildi - artık mavi
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DriverLoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Okul butonu
                    _LinkedInStyleButton(
                      label: 'Okul Girişi',
                      icon: Icons.school,
                      isPrimary: true, // false'dan true'ya değiştirildi - artık mavi
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SchoolLoginScreen(),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 16), // Alt boşluk
          ],
        ),
      ),
    );
  }
}

// LinkedIn tarzı buton widget'ı
class _LinkedInStyleButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _LinkedInStyleButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_LinkedInStyleButton> createState() => _LinkedInStyleButtonState();
}

class _LinkedInStyleButtonState extends State<_LinkedInStyleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? const Color(0xFF0A66C2) // LinkedIn mavisi
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFF0A66C2)
                  : const Color(0xFF0A66C2),
              width: 1.5,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.isPrimary
                          ? const Color(0xFF0A66C2).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary
                    ? Colors.white
                    : const Color(0xFF0A66C2),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary
                      ? Colors.white
                      : const Color(0xFF0A66C2),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
