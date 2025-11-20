import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service.dart';
import '../services/service_service.dart';

class AddServiceScreen extends StatefulWidget {
  final Service? service; // Düzenleme için

  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedDriver;
  String? _selectedRoute;
  ServiceStatus _selectedStatus = ServiceStatus.active;
  bool _isLoading = false;

  final List<String> _drivers = ServiceService.getAvailableDrivers();
  final List<String> _routes = ServiceService.getAvailableRoutes();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      // Düzenleme modu
      _plateNumberController.text = widget.service!.plateNumber;
      _capacityController.text = widget.service!.capacity.toString();
      _selectedDriver = widget.service!.driverName;
      _selectedRoute = widget.service!.routeName;
      _selectedStatus = widget.service!.status;
      _notesController.text = widget.service!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final service = Service(
        id: widget.service?.id ?? 'service_${DateTime.now().millisecondsSinceEpoch}',
        plateNumber: _plateNumberController.text.trim().toUpperCase(),
        driverName: _selectedDriver!,
        routeName: _selectedRoute!,
        capacity: int.parse(_capacityController.text.trim()),
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        assignedStudentIds: widget.service?.assignedStudentIds ?? [],
      );

      if (widget.service != null) {
        ServiceService.updateService(service);
      } else {
        ServiceService.addService(service);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context, true);
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
                          widget.service != null ? 'Servis Düzenle' : 'Yeni Servis Ekle',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Servis bilgilerini giriniz',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Plaka Numarası
                        _buildTextField(
                          controller: _plateNumberController,
                          label: 'Plaka Numarası',
                          icon: FontAwesomeIcons.car,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Plaka numarası zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Şoför Seçimi
                        _buildDropdownField(
                          label: 'Şoför',
                          icon: FontAwesomeIcons.userTie,
                          value: _selectedDriver,
                          items: _drivers,
                          onChanged: (value) {
                            setState(() {
                              _selectedDriver = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şoför seçimi zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Rota Seçimi
                        _buildDropdownField(
                          label: 'Rota',
                          icon: FontAwesomeIcons.route,
                          value: _selectedRoute,
                          items: _routes,
                          onChanged: (value) {
                            setState(() {
                              _selectedRoute = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rota seçimi zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Kapasite
                        _buildTextField(
                          controller: _capacityController,
                          label: 'Kapasite (Maksimum Öğrenci Sayısı)',
                          icon: FontAwesomeIcons.users,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Kapasite zorunludur';
                            }
                            final capacity = int.tryParse(value.trim());
                            if (capacity == null || capacity <= 0) {
                              return 'Geçerli bir kapasite giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Durum
                        _buildStatusSelector(),
                        const SizedBox(height: 20),
                        
                        // Notlar
                        _buildTextField(
                          controller: _notesController,
                          label: 'Notlar (Opsiyonel)',
                          icon: FontAwesomeIcons.noteSticky,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                        
                        // Kaydet Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
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
                                    widget.service != null ? 'Güncelle' : 'Kaydet',
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
            widget.service != null ? 'Servis Düzenle' : 'Servis Ekle',
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
    int maxLines = 1,
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
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: FaIcon(icon, color: const Color(0xFF4CAF50)),
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
                color: Color(0xFF4CAF50),
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: FaIcon(icon, color: const Color(0xFF4CAF50)),
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
                color: Color(0xFF4CAF50),
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
          dropdownColor: const Color(0xFF37474F),
          style: GoogleFonts.poppins(color: Colors.white),
          hint: Text(
            'Seçiniz',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                ServiceStatus.active,
                'Aktif',
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusChip(
                ServiceStatus.inactive,
                'Pasif',
                const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusChip(
                ServiceStatus.maintenance,
                'Bakımda',
                const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(ServiceStatus status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

