import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';
import 'add_driver_screen.dart';
import 'driver_detail_screen.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];
  final TextEditingController _searchController = TextEditingController();
  DriverStatus? _selectedStatusFilter;
  bool? _hasServiceFilter; // null = tümü, true = serviste olanlar, false = serviste olmayanlar

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _searchController.addListener(_filterDrivers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDrivers() {
    setState(() {
      _drivers = DriverService.getAllDrivers();
      _filteredDrivers = _drivers;
    });
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDrivers = _drivers.where((driver) {
        final matchesSearch = query.isEmpty ||
            driver.firstName.toLowerCase().contains(query) ||
            driver.lastName.toLowerCase().contains(query) ||
            driver.phoneNumber.contains(query) ||
            driver.licenseNumber.toLowerCase().contains(query);
        
        final matchesStatus = _selectedStatusFilter == null || driver.status == _selectedStatusFilter;
        
        final matchesService = _hasServiceFilter == null ||
            (_hasServiceFilter == true && driver.hasService) ||
            (_hasServiceFilter == false && !driver.hasService);
        
        return matchesSearch && matchesStatus && matchesService;
      }).toList();
    });
  }

  void _onStatusFilterChanged(DriverStatus? status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    _filterDrivers();
  }

  void _onServiceFilterChanged(bool? hasService) {
    setState(() {
      _hasServiceFilter = hasService;
    });
    _filterDrivers();
  }

  Future<void> _addDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDriverScreen(),
      ),
    );

    if (result == true) {
      _loadDrivers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şoför başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
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
              
              // İstatistikler
              _buildStatsCards(),
              
              // Arama ve Filtreler
              _buildSearchAndFilters(),
              
              // Şoför Listesi
              Expanded(
                child: _buildDriverList(),
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
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Şoför Yönetimi',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            onPressed: _addDriver,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalDrivers = DriverService.getTotalDrivers();
    final activeDrivers = DriverService.getActiveDriversCount();
    final withService = DriverService.getDriversWithServiceCount();
    final withoutService = DriverService.getDriversWithoutServiceCount();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.userTie,
                  title: 'Toplam Şoför',
                  value: '$totalDrivers',
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.checkCircle,
                  title: 'Aktif Şoför',
                  value: '$activeDrivers',
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
                  icon: FontAwesomeIcons.bus,
                  title: 'Serviste Çalışan',
                  value: '$withService',
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.userXmark,
                  title: 'Serviste Olmayan',
                  value: '$withoutService',
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Arama Çubuğu
          Container(
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
                hintText: 'Ad, soyad, telefon veya lisans ara...',
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
          ),
          const SizedBox(height: 12),
          // Filtre Butonları - Durum
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', null, _selectedStatusFilter == null, () {
                  _onStatusFilterChanged(null);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', DriverStatus.active, _selectedStatusFilter == DriverStatus.active, () {
                  _onStatusFilterChanged(DriverStatus.active);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Pasif', DriverStatus.inactive, _selectedStatusFilter == DriverStatus.inactive, () {
                  _onStatusFilterChanged(DriverStatus.inactive);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('İzinli', DriverStatus.onLeave, _selectedStatusFilter == DriverStatus.onLeave, () {
                  _onStatusFilterChanged(DriverStatus.onLeave);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Filtre Butonları - Servis
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildServiceFilterChip('Tümü', null, _hasServiceFilter == null, () {
                  _onServiceFilterChanged(null);
                }),
                const SizedBox(width: 8),
                _buildServiceFilterChip('Serviste Olanlar', true, _hasServiceFilter == true, () {
                  _onServiceFilterChanged(true);
                }),
                const SizedBox(width: 8),
                _buildServiceFilterChip('Serviste Olmayanlar', false, _hasServiceFilter == false, () {
                  _onServiceFilterChanged(false);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DriverStatus? status, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF9800) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF9800) 
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceFilterChip(String label, bool? hasService, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF2196F3) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2196F3) 
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    if (_filteredDrivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.userTie,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty && _selectedStatusFilter == null && _hasServiceFilter == null
                  ? 'Henüz şoför yok'
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredDrivers.length,
      itemBuilder: (context, index) {
        final driver = _filteredDrivers[index];
        return _buildDriverCard(driver);
      },
    );
  }

  Widget _buildDriverCard(Driver driver) {
    final statusColor = Color(driver.status.colorValue);
    
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailScreen(driverId: driver.id),
          ),
        );
        if (result == true) {
          _loadDrivers();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  driver.firstName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Şoför Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          driver.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Durum Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          driver.status.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.phone,
                        color: Color(0xFF2196F3),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        driver.phoneNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.idCard,
                        color: Color(0xFF4CAF50),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        driver.licenseNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Servis Bilgisi
                  if (driver.hasService)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.bus,
                            color: Color(0xFF4CAF50),
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Servis atanmış',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.circleXmark,
                            color: Colors.white54,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Servis atanmamış',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
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

