import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../models/student.dart';
import '../services/student_service.dart';

enum RideStatus { waiting, onboard, dropped }

extension RideStatusX on RideStatus {
  String get label {
    switch (this) {
      case RideStatus.waiting:
        return 'Bekliyor';
      case RideStatus.onboard:
        return 'Serviste';
      case RideStatus.dropped:
        return 'Evde';
    }
  }

  Color get color {
    switch (this) {
      case RideStatus.waiting:
        return Colors.black45;
      case RideStatus.onboard:
        return const Color(0xFF7DD321);
      case RideStatus.dropped:
        return const Color(0xFF64B5F6);
    }
  }
}

class DriverHomeScreen extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String licensePlate;

  const DriverHomeScreen({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.licensePlate,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final MapController _mapController = MapController();
  final LatLng _driverLocation = const LatLng(40.1950, 29.0600);
  final double _defaultZoom = 13;
  bool _isTrackingActive = false;
  final List<_StudentStop> _students = [];
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    final List<Student> students = StudentService.getAllStudents();
    final List<_StudentStop> prepared =
        students.map((student) => _StudentStop.fromStudent(student)).toList();
    if (prepared.isNotEmpty) {
      prepared[0] = prepared[0].copyWith(status: RideStatus.onboard);
    }
    setState(() {
      _students
        ..clear()
        ..addAll(prepared);
      _isLoadingStudents = false;
    });
  }

  void _recenterOnDriver() {
    _mapController.move(_driverLocation, _defaultZoom);
  }

  void _markStudentPickedUp(int index) {
    if (index >= _students.length) return;
    final student = _students[index];
    if (student.status != RideStatus.waiting) {
      _showStatusSnack('${student.name} zaten serviste.', Colors.orange);
      return;
    }
    setState(() {
      _students[index] = student.copyWith(status: RideStatus.onboard);
    });
    _showStatusSnack('${student.name} servise bindi.', Colors.green);
  }

  void _markStudentDropped(int index) {
    if (index >= _students.length) return;
    final student = _students[index];
    if (student.status == RideStatus.waiting) {
      _showStatusSnack(
        '${student.name} için önce servise bindiği işaretlenmeli.',
        Colors.orange,
      );
      return;
    }
    if (student.status == RideStatus.dropped) {
      _showStatusSnack(
        '${student.name} zaten eve bırakıldı.',
        Colors.orange,
      );
      return;
    }
    setState(() {
      _students[index] = student.copyWith(status: RideStatus.dropped);
    });
    _showStatusSnack(
      '${student.name} eve bırakıldı.',
      const Color(0xFF64B5F6),
    );
  }

  void _showStatusSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleServiceTracking() {
    setState(() {
      _isTrackingActive = !_isTrackingActive;
    });
    final message = _isTrackingActive
        ? 'Servis takibi başlatıldı.'
        : 'Servis takibi durduruldu.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isTrackingActive ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openFullStudentList() async {
    if (_isLoadingStudents) return;
    final result = await Navigator.push<List<_StudentStop>>(
      context,
      MaterialPageRoute(
        builder: (_) => DriverStudentListScreen(
          students: List<_StudentStop>.from(_students),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _students
          ..clear()
          ..addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Colors.white;
    const Color panelColor = Color(0xFFF4F6FB);
    const Color accent = Color(0xFF2196F3);
    final double mapHeight = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home_filled, color: Colors.black87),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.driverName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.licensePlate,
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: mapHeight,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _driverLocation,
                            initialZoom: _defaultZoom,
                            interactionOptions: const InteractionOptions(
                              flags:
                                  InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.servisciler',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _driverLocation,
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isTrackingActive
                                          ? accent
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isTrackingActive
                                                  ? accent
                                                  : Colors.grey)
                                              .withOpacity(0.4),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.navigation,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Bursa',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.fullscreen,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.black.withOpacity(0.6),
                            foregroundColor: Colors.white,
                            onPressed: _recenterOnDriver,
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleServiceTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isTrackingActive ? const Color(0xFF1B5E20) : accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                  icon: Icon(
                    _isTrackingActive ? Icons.stop_circle : Icons.play_arrow,
                  ),
                  label: Text(
                    _isTrackingActive
                        ? 'Servis Takibini Durdur'
                        : 'Servisi Başlat',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sonraki Durak: Ayşe Yılmaz',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Çiçek Sokak No: 5',
                      style: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tahmini varış: 3 dakika',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0D47A1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Geç Kalacağım'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Birazdan Oradayım'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sıradaki Öğrenciler',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isLoadingStudents ? null : _openFullStudentList,
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                    ),
                    icon: Icon(Icons.list_alt, color: accent),
                    label: const Text('Tüm Liste'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isLoadingStudents
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _students.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Henüz öğrenci tanımlı değil',
                                style: GoogleFonts.poppins(
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 360,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: _students.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.black.withOpacity(0.05),
                                height: 0,
                              ),
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return StudentActionCard(
                                  order: index + 1,
                                  student: student,
                                  onPickup: () => _markStudentPickedUp(index),
                                  onDrop: () => _markStudentDropped(index),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentStop {
  final String id;
  final String name;
  final String className;
  final RideStatus status;

  _StudentStop({
    required this.id,
    required this.name,
    this.className = '',
    RideStatus? status,
  }) : status = _rideStatusFrom(status);

  factory _StudentStop.fromStudent(Student student) {
    return _StudentStop(
      id: student.id,
      name: student.fullName,
      className: student.className,
      status: RideStatus.waiting,
    );
  }

  _StudentStop copyWith({
    String? id,
    String? name,
    String? className,
    dynamic status,
  }) {
    return _StudentStop(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      status: status != null ? _rideStatusFrom(status) : this.status,
    );
  }
}

RideStatus _rideStatusFrom(dynamic value) {
  if (value is RideStatus) return value;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'serviste':
      case 'onboard':
        return RideStatus.onboard;
      case 'evde':
      case 'dropped':
        return RideStatus.dropped;
      case 'bekliyor':
      case 'waiting':
      default:
        return RideStatus.waiting;
    }
  }
  return RideStatus.waiting;
}

class StudentActionCard extends StatelessWidget {
  final int order;
  final _StudentStop student;
  final VoidCallback? onPickup;
  final VoidCallback? onDrop;

  const StudentActionCard({
    super.key,
    required this.order,
    required this.student,
    required this.onPickup,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    const Color badgeColor = Color(0xFF1F344F);
    const Color pickupColor = Color(0xFF2E7D32);
    const Color dropColor = Color(0xFF1565C0);

    ButtonStyle buttonStyle(Color color) => ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return color.withOpacity(0.35);
            }
            return color;
          }),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: badgeColor,
                child: Text(
                  order.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.className} • ${student.status.label}',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: student.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student.status.label,
                  style: GoogleFonts.poppins(
                    color: student.status.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickup,
                  icon: const Icon(Icons.directions_bus),
                  label: const Text('Servise Bindi'),
                  style: buttonStyle(pickupColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDrop,
                  icon: const Icon(Icons.home_filled),
                  label: const Text('Eve Bırakıldı'),
                  style: buttonStyle(dropColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DriverStudentListScreen extends StatefulWidget {
  final List<_StudentStop> students;

  const DriverStudentListScreen({
    super.key,
    required this.students,
  });

  @override
  State<DriverStudentListScreen> createState() =>
      _DriverStudentListScreenState();
}

class _DriverStudentListScreenState extends State<DriverStudentListScreen> {
  late List<_StudentStop> _students;

  @override
  void initState() {
    super.initState();
    _students = List<_StudentStop>.from(widget.students);
  }

  void _markStudentPickedUp(int index) {
    if (index >= _students.length) return;
    final student = _students[index];
    if (student.status != RideStatus.waiting) {
      _showSnack('${student.name} zaten serviste.', Colors.orange);
      return;
    }
    setState(() {
      _students[index] = student.copyWith(status: RideStatus.onboard);
    });
    _showSnack('${student.name} servise bindi.', Colors.green);
  }

  void _markStudentDropped(int index) {
    if (index >= _students.length) return;
    final student = _students[index];
    if (student.status == RideStatus.waiting) {
      _showSnack(
        '${student.name} için önce servise bindiği işaretlenmeli.',
        Colors.orange,
      );
      return;
    }
    if (student.status == RideStatus.dropped) {
      _showSnack('${student.name} zaten eve bırakıldı.', Colors.orange);
      return;
    }
    setState(() {
      _students[index] = student.copyWith(status: RideStatus.dropped);
    });
    _showSnack('${student.name} eve bırakıldı.', const Color(0xFF64B5F6));
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _handlePop() async {
    Navigator.pop(context, _students);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Colors.white;
    const Color panelColor = Color(0xFFF4F6FB);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          Navigator.pop(context, _students);
        }
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context, _students),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    Text(
                      'Tüm Öğrenciler',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48), // Placeholder for symmetry
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: StudentActionCard(
                        order: index + 1,
                        student: student,
                        onPickup: () => _markStudentPickedUp(index),
                        onDrop: () => _markStudentDropped(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
