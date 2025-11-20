import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver.dart';
import '../models/service.dart';
import '../services/driver_service.dart';
import '../services/service_service.dart';

class AssignServiceToDriverScreen extends StatefulWidget {
  final String driverId;

  const AssignServiceToDriverScreen({super.key, required this.driverId});

  @override
  State<AssignServiceToDriverScreen> createState() => _AssignServiceToDriverScreenState();
}

class _AssignServiceToDriverScreenState extends State<AssignServiceToDriverScreen> {
  Driver? _driver;
  List<Service> _availableServices = [];
  String? _selectedServiceId;
  bool _removeOldDriver = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _driver = DriverService.getDriverById(widget.driverId);
    if (_driver == null) return;

    // Tüm servisleri al
    _availableServices = ServiceService.getAllServices();
    
    // Mevcut servis atamasını seçili yap
    _selectedServiceId = _driver!.assignedServiceId;
    
    setState(() {});
  }

  Future<void> _assignService() async {
    if (_driver == null) return;

    // Eğer aynı servis seçilmişse işlem yapma
    if (_selectedServiceId == _driver!.assignedServiceId) {
      Navigator.pop(context, false);
      return;
    }

    // Yeni servis seçilmişse
    if (_selectedServiceId != null) {
      // Eski şoförü servisten çıkar (eğer seçildiyse)
      if (_removeOldDriver) {
        final service = ServiceService.getServiceById(_selectedServiceId!);
        if (service != null) {
          // Serviste başka bir şoför varsa onu çıkar
          final oldDriver = DriverService.getAllDrivers().firstWhere(
            (d) => d.assignedServiceId == _selectedServiceId && d.id != _driver!.id,
            orElse: () => DriverService.getAllDrivers().first,
          );
          
          if (oldDriver.id != DriverService.getAllDrivers().first.id) {
            DriverService.removeServiceFromDriver(oldDriver.id);
          }
        }
      }
      
      // Şoföre servis ata
      DriverService.assignServiceToDriver(_driver!.id, _selectedServiceId!);
    } else {
      // Servis seçimi kaldırıldıysa
      DriverService.removeServiceFromDriver(_driver!.id);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
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
                      // Şoför Bilgisi
                      _buildDriverInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Servis Seçimi Başlığı
                      Text(
                        'Servis Seçiniz',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Servis Seçimi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedServiceId,
                          decoration: InputDecoration(
                            prefixIcon: const FaIcon(
                              FontAwesomeIcons.bus,
                              color: Color(0xFFFF9800),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: const Color(0xFF37474F),
                          style: GoogleFonts.poppins(color: Colors.white),
                          hint: Text(
                            'Servis seçiniz',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Servis atanmamış'),
                            ),
                            ..._availableServices.map((Service service) {
                              // Bu serviste başka bir şoför var mı kontrol et
                              final hasOtherDriver = DriverService.getAllDrivers().any(
                                (d) => d.assignedServiceId == service.id && d.id != _driver!.id,
                              );
                              
                              return DropdownMenuItem<String>(
                                value: service.id,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.plateNumber,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            service.routeName,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasOtherDriver)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Başka şoför var',
                                          style: GoogleFonts.poppins(
                                            color: Colors.orange,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedServiceId = value;
                            });
                          },
                        ),
                      ),
                      
                      // Eski şoförü çıkar seçeneği
                      if (_selectedServiceId != null &&
                          _selectedServiceId != _driver!.assignedServiceId) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _removeOldDriver,
                                onChanged: (value) {
                                  setState(() {
                                    _removeOldDriver = value ?? true;
                                  });
                                },
                                activeColor: const Color(0xFFFF9800),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Eski şoförü servisten çıkar',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Seçili serviste başka bir şoför varsa onu otomatik olarak çıkarır',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Servis Listesi
                      if (_availableServices.isNotEmpty) ...[
                        Text(
                          'Mevcut Servisler',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._availableServices.map((service) {
                          final isSelected = _selectedServiceId == service.id;
                          final hasOtherDriver = DriverService.getAllDrivers().any(
                            (d) => d.assignedServiceId == service.id && d.id != _driver!.id,
                          );
                          
                          return _buildServiceCard(service, isSelected, hasOtherDriver);
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Ata Butonu
              Container(
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
                      onPressed: _assignService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFF9800).withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _selectedServiceId != null ? 'Servisi Ata' : 'Servisi Kaldır',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servis Ata',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _driver!.fullName,
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

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _driver!.firstName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _driver!.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _driver!.phoneNumber,
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

  Widget _buildServiceCard(Service service, bool isSelected, bool hasOtherDriver) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedServiceId = isSelected ? null : service.id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9800).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9800)
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
                      ? const Color(0xFFFF9800)
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFFF9800)
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
            
            // Servis Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.plateNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (hasOtherDriver)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Başka şoför var',
                            style: GoogleFonts.poppins(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
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
                        color: Color(0xFF4CAF50),
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
          ],
        ),
      ),
    );
  }
}

