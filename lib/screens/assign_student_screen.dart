import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/student.dart';
import '../models/service.dart';
import '../services/student_service.dart';
import '../services/service_service.dart';

class AssignStudentScreen extends StatefulWidget {
  final String serviceId;

  const AssignStudentScreen({super.key, required this.serviceId});

  @override
  State<AssignStudentScreen> createState() => _AssignStudentScreenState();
}

class _AssignStudentScreenState extends State<AssignStudentScreen> {
  List<Student> _allStudents = [];
  List<Student> _availableStudents = [];
  List<String> _selectedStudentIds = [];
  final TextEditingController _searchController = TextEditingController();
  Service? _service;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    _service = ServiceService.getServiceById(widget.serviceId);
    if (_service == null) return;

    _allStudents = StudentService.getAllStudents();
    
    // Servise atanmamış öğrencileri filtrele
    _availableStudents = _allStudents.where((student) {
      return !_service!.assignedStudentIds.contains(student.id);
    }).toList();
    
    setState(() {});
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _availableStudents = _allStudents.where((student) {
          return !_service!.assignedStudentIds.contains(student.id);
        }).toList();
      } else {
        _availableStudents = _allStudents.where((student) {
          final isNotAssigned = !_service!.assignedStudentIds.contains(student.id);
          final matchesSearch = student.firstName.toLowerCase().contains(query) ||
              student.lastName.toLowerCase().contains(query) ||
              student.studentNumber.contains(query) ||
              student.className.toLowerCase().contains(query);
          return isNotAssigned && matchesSearch;
        }).toList();
      }
    });
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        // Kapasite kontrolü
        final currentCount = _service!.currentStudentCount;
        final selectedCount = _selectedStudentIds.length;
        if (currentCount + selectedCount < _service!.capacity) {
          _selectedStudentIds.add(studentId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servis kapasitesi dolu!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _assignSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir öğrenci seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kapasite kontrolü
    final currentCount = _service!.currentStudentCount;
    if (currentCount + _selectedStudentIds.length > _service!.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seçilen öğrenci sayısı servis kapasitesini aşıyor!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Öğrencileri ata
    for (final studentId in _selectedStudentIds) {
      ServiceService.assignStudentToService(widget.serviceId, studentId);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
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

    final availableSeats = _service!.availableSeats - _selectedStudentIds.length;

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
              
              // Bilgi Kartı
              _buildInfoCard(availableSeats),
              
              // Arama Çubuğu
              _buildSearchBar(),
              
              // Seçim Bilgisi
              if (_selectedStudentIds.isNotEmpty)
                _buildSelectionInfo(),
              
              // Öğrenci Listesi
              Expanded(
                child: _buildStudentList(),
              ),
              
              // Ata Butonu
              if (_selectedStudentIds.isNotEmpty)
                _buildAssignButton(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öğrenci Ata',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _service!.plateNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(int availableSeats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: FontAwesomeIcons.users,
            label: 'Mevcut',
            value: '${_service!.currentStudentCount}',
            color: const Color(0xFF2196F3),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildInfoItem(
            icon: FontAwesomeIcons.userPlus,
            label: 'Seçilen',
            value: '${_selectedStudentIds.length}',
            color: const Color(0xFFFF9800),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildInfoItem(
            icon: FontAwesomeIcons.chair,
            label: 'Boş Koltuk',
            value: '$availableSeats',
            color: availableSeats > 0 
                ? const Color(0xFF4CAF50) 
                : const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        FaIcon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Öğrenci ara...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.circleCheck,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_selectedStudentIds.length} öğrenci seçildi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStudentIds.clear();
              });
            },
            child: Text(
              'Temizle',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF9800),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_availableStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.userGroup,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Tüm öğrenciler atanmış'
                  : 'Arama sonucu bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    final remainingSeats = _service!.availableSeats - _selectedStudentIds.length;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _availableStudents.length,
      itemBuilder: (context, index) {
        final student = _availableStudents[index];
        final isSelected = _selectedStudentIds.contains(student.id);
        final canSelect = remainingSeats > 0;
        
        return _buildStudentCard(student, isSelected, canSelect);
      },
    );
  }

  Widget _buildStudentCard(Student student, bool isSelected, bool canSelect) {
    return InkWell(
      onTap: canSelect ? () => _toggleStudentSelection(student.id) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.firstName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2196F3),
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
                      color: Colors.white,
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
          ],
        ),
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

  Widget _buildAssignButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _assignSelectedStudents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${_selectedStudentIds.length} Öğrenciyi Ata',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

