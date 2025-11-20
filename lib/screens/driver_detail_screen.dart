import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver.dart';
import '../models/service.dart';
import '../services/driver_service.dart';
import '../services/service_service.dart';
import 'add_driver_screen.dart';
import 'assign_service_to_driver_screen.dart';

class DriverDetailScreen extends StatefulWidget {
  final String driverId;

  const DriverDetailScreen({super.key, required this.driverId});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  Driver? _driver;
  Service? _assignedService;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  void _loadDriver() {
    setState(() {
      _driver = DriverService.getDriverById(widget.driverId);
      if (_driver != null && _driver!.assignedServiceId != null) {
        _assignedService = ServiceService.getServiceById(_driver!.assignedServiceId!);
      }
    });
  }

  Future<void> _editDriver() async {
    if (_driver == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDriverScreen(driver: _driver),
      ),
    );

    if (result == true) {
      _loadDriver();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şoför başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteDriver() async {
    if (_driver == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF37474F),
        title: Text(
          'Şoförü Sil',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          _driver!.hasService
              ? 'Bu şoför bir serviste çalışıyor. Şoförü silmek istediğinizden emin misiniz?'
              : 'Bu şoförü silmek istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Servisten çıkar
      if (_driver!.hasService) {
        DriverService.removeServiceFromDriver(_driver!.id);
      }
      
      DriverService.deleteDriver(_driver!.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şoför başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _assignOrChangeService() async {
    if (_driver == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignServiceToDriverScreen(driverId: _driver!.id),
      ),
    );

    if (result == true) {
      _loadDriver();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servis ataması güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _removeService() {
    if (_driver == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF37474F),
        title: Text(
          'Servisten Çıkar',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Bu şoförü servisten çıkarmak istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              DriverService.removeServiceFromDriver(_driver!.id);
              Navigator.pop(context);
              _loadDriver();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şoför servisten çıkarıldı'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text(
              'Çıkar',
              style: GoogleFonts.poppins(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final statusColor = Color(_driver!.status.colorValue);

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
              
              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Şoför Bilgileri Kartı
                      _buildDriverInfoCard(statusColor),
                      
                      const SizedBox(height: 24),
                      
                      // Atanmış Servis Başlığı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Atanmış Servis',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_driver!.hasService)
                            TextButton.icon(
                              onPressed: _removeService,
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Servisten Çıkar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Servis Kartı
                      if (_assignedService != null)
                        _buildServiceCard(_assignedService!)
                      else
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.bus,
                                color: Colors.white54,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz servis atanmamış',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _assignOrChangeService,
                                icon: const Icon(Icons.add),
                                label: const Text('Servis Ata'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (!_driver!.hasService) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _assignOrChangeService,
                            icon: const Icon(Icons.add),
                            label: const Text('Servis Ata'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(width: 8),
              Text(
                'Şoför Detayı',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: _editDriver,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteDriver,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _driver!.firstName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Ad Soyad
          Text(
            _driver!.fullName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Durum Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              _driver!.status.displayName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          
          // İletişim Bilgileri
          _buildInfoRow(
            icon: FontAwesomeIcons.phone,
            label: 'Telefon',
            value: _driver!.phoneNumber,
            color: const Color(0xFF2196F3),
          ),
          
          if (_driver!.email != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: FontAwesomeIcons.envelope,
              label: 'E-posta',
              value: _driver!.email!,
              color: const Color(0xFF4CAF50),
            ),
          ],
          
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: FontAwesomeIcons.idCard,
            label: 'Lisans Numarası',
            value: _driver!.licenseNumber,
            color: const Color(0xFFFF9800),
          ),
          
          // Notlar
          if (_driver!.notes != null && _driver!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(
                  FontAwesomeIcons.noteSticky,
                  color: Color(0xFFFF9800),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _driver!.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        FaIcon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service) {
    return InkWell(
      onTap: _assignOrChangeService,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(
                FontAwesomeIcons.bus,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.plateNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.routeName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.users,
                        color: Color(0xFFFF9800),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${service.currentStudentCount}/${service.capacity} öğrenci',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

