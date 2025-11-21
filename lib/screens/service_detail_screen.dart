import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service.dart';
import '../models/student.dart';
import '../services/service_service.dart';
import '../services/student_service.dart';
import 'add_service_screen.dart';
import 'assign_student_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Service? _service;
  List<Student> _assignedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  void _loadService() {
    setState(() {
      _service = ServiceService.getServiceById(widget.serviceId);
      if (_service != null) {
        _loadAssignedStudents();
      }
    });
  }

  void _loadAssignedStudents() {
    if (_service == null) return;
    
    final allStudents = StudentService.getAllStudents();
    _assignedStudents = allStudents.where((student) {
      return _service!.assignedStudentIds.contains(student.id);
    }).toList();
  }

  Future<void> _editService() async {
    if (_service == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServiceScreen(service: _service),
      ),
    );

    if (result == true) {
      _loadService();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servis başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteService() async {
    if (_service == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Servisi Sil',
          style: GoogleFonts.poppins(color: const Color(0xFF000000)),
        ),
        content: Text(
          'Bu servisi silmek istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(color: const Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: const Color(0xFF666666)),
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
      ServiceService.deleteService(_service!.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servis başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _assignStudent() async {
    if (_service == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignStudentScreen(serviceId: _service!.id),
      ),
    );

    if (result == true) {
      _loadService();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla atandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _removeStudent(String studentId) {
    if (_service == null) return;

    ServiceService.removeStudentFromService(_service!.id, studentId);
    _loadService();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğrenci servisten çıkarıldı'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0A66C2),
          ),
        ),
      );
    }

    final statusColor = Color(_service!.status.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
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
                      // Servis Bilgileri Kartı
                      _buildServiceInfoCard(statusColor),
                      
                      const SizedBox(height: 24),
                      
                      // Atanmış Öğrenciler Başlığı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Atanmış Öğrenciler',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF000000),
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (!_service!.isFull)
                            ElevatedButton.icon(
                              onPressed: _assignStudent,
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                'Öğrenci Ata',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Öğrenci Listesi
                      if (_assignedStudents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
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
                              const FaIcon(
                                FontAwesomeIcons.userGroup,
                                color: Color(0xFF999999),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz öğrenci atanmamış',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              if (!_service!.isFull) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _assignStudent,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Öğrenci Ata'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        ..._assignedStudents.map((student) {
                          return _buildStudentCard(student);
                        }),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(width: 8),
              Text(
                'Servis Detayı',
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
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0A66C2)),
                onPressed: _editService,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteService,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plaka ve Durum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service!.plateNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      Text(
                        _service!.routeName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  _service!.status.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Şoför Bilgisi
          _buildInfoRow(
            icon: FontAwesomeIcons.userTie,
            label: 'Şoför',
            value: _service!.driverName,
            color: const Color(0xFF2196F3),
          ),
          
          const SizedBox(height: 16),
          
          // Kapasite Bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(
                icon: FontAwesomeIcons.users,
                label: 'Kapasite',
                value: '${_service!.currentStudentCount}/${_service!.capacity}',
                color: const Color(0xFFFF9800),
              ),
              if (_service!.availableSeats > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_service!.availableSeats} boş koltuk',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Dolu',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFF44336),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          // Kapasite Çubuğu
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _service!.capacity > 0 
                  ? _service!.currentStudentCount / _service!.capacity 
                  : 0,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                _service!.isFull ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
              ),
              minHeight: 8,
            ),
          ),
          
          // Notlar
          if (_service!.notes != null && _service!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE0E0E0)),
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
                    _service!.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF000000),
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
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000000),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
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
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0A66C2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.firstName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A66C2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Öğrenci Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: FontAwesomeIcons.hashtag,
                      text: student.studentNumber,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: FontAwesomeIcons.graduationCap,
                      text: student.className,
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Çıkar Butonu
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeStudent(student.id),
            tooltip: 'Servisten Çıkar',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

