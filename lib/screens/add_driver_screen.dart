import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';
import '../services/service_service.dart';
import '../models/service.dart';

class AddDriverScreen extends StatefulWidget {
  final Driver? driver; // Düzenleme için

  const AddDriverScreen({super.key, this.driver});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DriverStatus _selectedStatus = DriverStatus.active;
  String? _selectedServiceId;
  bool _isLoading = false;

  List<Service> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    if (widget.driver != null) {
      // Düzenleme modu
      _firstNameController.text = widget.driver!.firstName;
      _lastNameController.text = widget.driver!.lastName;
      _phoneController.text = widget.driver!.phoneNumber;
      _emailController.text = widget.driver!.email ?? '';
      _licenseController.text = widget.driver!.licenseNumber;
      _selectedStatus = widget.driver!.status;
      _selectedServiceId = widget.driver!.assignedServiceId;
      _notesController.text = widget.driver!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadServices() {
    setState(() {
      _availableServices = ServiceService.getAllServices();
    });
  }

  Future<void> _saveDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final driver = Driver(
        id: widget.driver?.id ?? 'driver_${DateTime.now().millisecondsSinceEpoch}',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        licenseNumber: _licenseController.text.trim().toUpperCase(),
        status: _selectedStatus,
        assignedServiceId: _selectedServiceId,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.driver != null) {
        DriverService.updateDriver(driver);
        // Servis ataması varsa güncelle
        if (_selectedServiceId != null && _selectedServiceId != widget.driver!.assignedServiceId) {
          DriverService.assignServiceToDriver(driver.id, _selectedServiceId!);
        } else if (_selectedServiceId == null && widget.driver!.assignedServiceId != null) {
          DriverService.removeServiceFromDriver(driver.id);
        }
      } else {
        DriverService.addDriver(driver);
        // Servis ataması varsa yap
        if (_selectedServiceId != null) {
          DriverService.assignServiceToDriver(driver.id, _selectedServiceId!);
        }
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
                          widget.driver != null ? 'Şoför Düzenle' : 'Yeni Şoför Ekle',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000000),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Şoför bilgilerini giriniz',
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
                        
                        // Telefon
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Telefon Numarası',
                          icon: FontAwesomeIcons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Telefon numarası zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // E-posta
                        _buildTextField(
                          controller: _emailController,
                          label: 'E-posta (Opsiyonel)',
                          icon: FontAwesomeIcons.envelope,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        
                        // Lisans Numarası
                        _buildTextField(
                          controller: _licenseController,
                          label: 'Lisans Numarası',
                          icon: FontAwesomeIcons.idCard,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lisans numarası zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Durum
                        _buildStatusSelector(),
                        const SizedBox(height: 20),
                        
                        // Servis Atama
                        _buildServiceSelector(),
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
                            onPressed: _isLoading ? null : _saveDriver,
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
                                    widget.driver != null ? 'Güncelle' : 'Kaydet',
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
            widget.driver != null ? 'Şoför Düzenle' : 'Şoför Ekle',
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
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                DriverStatus.active,
                'Aktif',
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusChip(
                DriverStatus.inactive,
                'Pasif',
                const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusChip(
                DriverStatus.onLeave,
                'İzinli',
                const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(DriverStatus status, String label, Color color) {
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
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
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
                color: isSelected ? color : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servis Atama (Opsiyonel)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedServiceId,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FaIcon(
                FontAwesomeIcons.bus,
                color: const Color(0xFF0A66C2),
                size: 20,
              ),
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
          ),
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(color: const Color(0xFF000000)),
          hint: Text(
            'Servis seçiniz',
            style: GoogleFonts.poppins(
                color: const Color(0xFF999999),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Servis atanmamış'),
            ),
            ..._availableServices.map((Service service) {
              return DropdownMenuItem<String>(
                value: service.id,
                child: Text('${service.plateNumber} - ${service.routeName}'),
              );
            }),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedServiceId = value;
            });
          },
        ),
      ],
    );
  }
}

