import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/student_service.dart';
import 'student_list_screen.dart';
import 'service_list_screen.dart';
import 'driver_list_screen.dart';

class SchoolHomeScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const SchoolHomeScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  int _selectedIndex = 0;

  // Örnek veriler (gerçek uygulamada API'den gelecek)
  int totalStudents = 0;
  bool _isLoadingStudents = false;
  final int activeServices = 12;
  final int todayBoarded = 187;
  final int pendingNotifications = 3;

  @override
  void initState() {
    super.initState();
    _loadStudentCount();
  }

  Future<void> _loadStudentCount() async {
    setState(() {
      _isLoadingStudents = true;
    });
    
    try {
      final studentService = StudentService();
      final count = await studentService.getStudentCountFromFirestore();
      
      if (mounted) {
        setState(() {
          totalStudents = count;
          _isLoadingStudents = false;
        });
      }
    } catch (e) {
      print('Öğrenci sayısı yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
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
            
            // Ana içerik
            Expanded(
              child: _selectedIndex == 0
                  ? _buildDashboard()
                  : _selectedIndex == 1
                      ? _buildActivities()
                      : _buildProfile(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoş Geldiniz',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.schoolName,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0A66C2)),
                    onPressed: () {
                      // Bildirimler sayfasına git
                    },
                  ),
                  if (pendingNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$pendingNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFF0A66C2)),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                tooltip: 'Çıkış Yap',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstatistik Kartları
          _buildStatsCards(),
          
          const SizedBox(height: 24),
          
          // Hızlı Erişim Başlığı
          Text(
            'Hızlı Erişim',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hızlı Erişim Butonları
          _buildQuickAccessGrid(),
          
          const SizedBox(height: 24),
          
          // Son Aktiviteler Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aktiviteler',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                  letterSpacing: 0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0A66C2),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Son Aktiviteler Listesi
          _buildRecentActivities(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.userGroup,
                title: 'Toplam Öğrenci',
                value: _isLoadingStudents ? '...' : '$totalStudents',
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.bus,
                title: 'Aktif Servis',
                value: '$activeServices',
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.users,
                title: 'Bugün Binen',
                value: '$todayBoarded',
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.bell,
                title: 'Bildirimler',
                value: '$pendingNotifications',
                color: const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final quickAccessItems = [
      {
        'icon': FontAwesomeIcons.userGroup,
        'title': 'Öğrenci\nYönetimi',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': FontAwesomeIcons.bus,
        'title': 'Servis\nYönetimi',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': FontAwesomeIcons.userTie,
        'title': 'Şoför\nYönetimi',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': FontAwesomeIcons.route,
        'title': 'Rota\nYönetimi',
        'color': const Color(0xFF9C27B0),
      },
      {
        'icon': FontAwesomeIcons.mapLocationDot,
        'title': 'Anlık\nTakip',
        'color': const Color(0xFFF44336),
      },
      {
        'icon': FontAwesomeIcons.bullhorn,
        'title': 'Duyurular',
        'color': const Color(0xFF00BCD4),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: quickAccessItems.length,
      itemBuilder: (context, index) {
        final item = quickAccessItems[index];
        return _buildQuickAccessCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          color: item['color'] as Color,
        );
      },
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return InkWell(
      onTap: () async {
        // Öğrenci Yönetimi butonuna tıklanınca öğrenci listesi sayfasına git
        if (title.contains('Öğrenci')) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentListScreen(),
            ),
          );
          if (result == true) {
            _loadStudentCount();
          }
        } else if (title.contains('Servis')) {
          // Servis Yönetimi butonuna tıklanınca servis listesi sayfasına git
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceListScreen(),
            ),
          );
        } else if (title.contains('Şoför')) {
          // Şoför Yönetimi butonuna tıklanınca şoför listesi sayfasına git
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverListScreen(),
            ),
          );
        } else {
          // Diğer butonlar için snackbar göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title sayfası yakında eklenecek'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'icon': FontAwesomeIcons.userCheck,
        'title': 'Ahmet Yılmaz servise bindi',
        'time': '5 dakika önce',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': FontAwesomeIcons.clock,
        'title': 'Servis #5 10 dakika gecikti',
        'time': '15 dakika önce',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': FontAwesomeIcons.userXmark,
        'title': 'Ayşe Demir servisten indi',
        'time': '20 dakika önce',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': FontAwesomeIcons.bus,
        'title': 'Servis #3 okula ulaştı',
        'time': '25 dakika önce',
        'color': const Color(0xFF4CAF50),
      },
    ];

    return Column(
      children: activities.map((activity) {
        return _buildActivityItem(
          icon: activity['icon'] as IconData,
          title: activity['title'] as String,
          time: activity['time'] as String,
          color: activity['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tüm Aktiviteler',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          _buildRecentActivities(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Okul Bilgileri Başlığı
          Text(
            'Okul Bilgileri',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Okul Bilgileri Kartı
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.graduationCap,
                    color: Color(0xFF0A66C2),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.schoolName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: 'Adres',
                  value: 'Atatürk Mah. Okul Sok. No:15',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: FontAwesomeIcons.phone,
                  label: 'Telefon',
                  value: '+90 212 555 1234',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: FontAwesomeIcons.envelope,
                  label: 'E-posta',
                  value: 'info@ornekilkokulu.edu.tr',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Ayarlar Başlığı
          Text(
            'Ayarlar',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              letterSpacing: 0.3,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Ayarlar Menüsü
          _buildSettingsItem(
            icon: FontAwesomeIcons.user,
            title: 'Profil Ayarları',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil ayarları yakında eklenecek')),
              );
            },
          ),
          _buildSettingsItem(
            icon: FontAwesomeIcons.bell,
            title: 'Bildirim Ayarları',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirim ayarları yakında eklenecek')),
              );
            },
          ),
          _buildSettingsItem(
            icon: FontAwesomeIcons.shield,
            title: 'Güvenlik',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Güvenlik ayarları yakında eklenecek')),
              );
            },
          ),
          _buildSettingsItem(
            icon: FontAwesomeIcons.circleQuestion,
            title: 'Yardım & Destek',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yardım sayfası yakında eklenecek')),
              );
            },
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        FaIcon(
          icon,
          color: const Color(0xFF0A66C2),
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                icon,
                color: const Color(0xFF0A66C2),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF0A66C2),
        unselectedItemColor: const Color(0xFF999999),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Aktiviteler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
