import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service.dart';
import '../services/service_service.dart';
import 'add_service_screen.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<Service> _services = [];
  List<Service> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();
  ServiceStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServices() {
    setState(() {
      _services = ServiceService.getAllServices();
      _filteredServices = _services;
    });
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        final matchesSearch = query.isEmpty ||
            service.plateNumber.toLowerCase().contains(query) ||
            service.driverName.toLowerCase().contains(query) ||
            service.routeName.toLowerCase().contains(query);
        
        final matchesFilter = _selectedFilter == null || service.status == _selectedFilter;
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(ServiceStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
    _filterServices();
  }

  Future<void> _addService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddServiceScreen(),
      ),
    );

    if (result == true) {
      _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servis başarıyla eklendi'),
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
              
              // Servis Listesi
              Expanded(
                child: _buildServiceList(),
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
                'Servis Yönetimi',
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
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            onPressed: _addService,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalServices = ServiceService.getTotalServices();
    final activeServices = ServiceService.getActiveServicesCount();
    final totalCapacity = ServiceService.getTotalCapacity();
    final todayWorking = ServiceService.getTodayWorkingServices();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.bus,
                  title: 'Toplam Servis',
                  value: '$totalServices',
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.checkCircle,
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
                  title: 'Toplam Kapasite',
                  value: '$totalCapacity',
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.road,
                  title: 'Bugün Çalışan',
                  value: '$todayWorking',
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
                hintText: 'Plaka, şoför veya rota ara...',
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
          // Filtre Butonları
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', null, _selectedFilter == null),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', ServiceStatus.active, _selectedFilter == ServiceStatus.active),
                const SizedBox(width: 8),
                _buildFilterChip('Pasif', ServiceStatus.inactive, _selectedFilter == ServiceStatus.inactive),
                const SizedBox(width: 8),
                _buildFilterChip('Bakımda', ServiceStatus.maintenance, _selectedFilter == ServiceStatus.maintenance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceStatus? status, bool isSelected) {
    return InkWell(
      onTap: () {
        _onFilterChanged(isSelected ? null : status);
      },
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

  Widget _buildServiceList() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.bus,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty && _selectedFilter == null
                  ? 'Henüz servis yok'
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
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    final statusColor = Color(service.status.colorValue);
    
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(serviceId: service.id),
          ),
        );
        if (result == true) {
          _loadServices();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Plaka
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.bus,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            Text(
                              service.routeName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Durum Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    service.status.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Şoför Bilgisi
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.userTie,
                  color: Color(0xFF2196F3),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  service.driverName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Kapasite Bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.users,
                      color: Color(0xFFFF9800),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${service.currentStudentCount}/${service.capacity}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' öğrenci',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                if (service.availableSeats > 0)
                  Text(
                    '${service.availableSeats} boş koltuk',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF4CAF50),
                    ),
                  )
                else
                  Text(
                    'Dolu',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFF44336),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            // Kapasite Çubuğu
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: service.capacity > 0 ? service.currentStudentCount / service.capacity : 0,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  service.isFull ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

