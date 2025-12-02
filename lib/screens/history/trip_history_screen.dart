import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/trip.dart';
import '../../models/types.dart';
import '../../services/trip_service.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Completados',
    'Cancelados',
    'Este mes',
  ];

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
  }

  Future<void> _loadTripHistory() async {
    try {
      final trips = await TripService.getTripHistory();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar historial de viajes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Trip> get _filteredTrips {
    switch (_selectedFilter) {
      case 'Completados':
        return _trips
            .where((trip) => trip.status == TripStatus.completed)
            .toList();
      case 'Cancelados':
        return _trips
            .where((trip) => trip.status == TripStatus.cancelled)
            .toList();
      case 'Este mes':
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        return _trips
            .where((trip) => trip.requestTime.isAfter(firstDayOfMonth))
            .toList();
      default:
        return _trips;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Historial de Viajes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFFFD700),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey[600],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de viajes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  )
                : _filteredTrips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _filteredTrips[index];
                      return _buildTripCard(trip);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.route,
              size: 50,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay viajes para mostrar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los viajes aparecerán aquí cuando\nrealices tu primera reserva',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(trip.requestTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                _buildStatusChip(trip.status),
              ],
            ),

            const SizedBox(height: 16),

            // Ubicaciones
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A90E2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 2, height: 30, color: Colors.grey[300]),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.pickupLocation.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        trip.destinationLocation.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información del viaje
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Tipo de vehículo
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getVehicleIcon(trip.vehicleType),
                          color: const Color(0xFF1A1A2E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getVehicleName(trip.vehicleType),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duración
                  if (trip.startTime != null && trip.endTime != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF1A1A2E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(trip.startTime!, trip.endTime!),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Precio
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.dollarSign,
                        color: Color(0xFF50C878),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.finalPrice?.toStringAsFixed(2) ?? '0.00',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF50C878),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conductor (si está disponible)
            if (trip.driver != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFFFD700),
                    child: trip.driver!.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              trip.driver!.profileImageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driver!.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.driver!.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón de calificar (solo para viajes completados)
                  if (trip.status == TripStatus.completed)
                    TextButton(
                      onPressed: () {
                        _showRatingDialog(trip);
                      },
                      child: const Text(
                        'Calificar',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TripStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case TripStatus.requested:
        color = Colors.orange;
        text = 'Solicitado';
        icon = Icons.schedule;
        break;
      case TripStatus.accepted:
        color = Colors.blue;
        text = 'Aceptado';
        icon = Icons.check;
        break;
      case TripStatus.inProgress:
        color = Colors.green;
        text = 'En curso';
        icon = Icons.directions_car;
        break;
      case TripStatus.completed:
        color = Colors.green;
        text = 'Completado';
        icon = Icons.check_circle;
        break;
      case TripStatus.cancelled:
        color = Colors.red;
        text = 'Cancelado';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return FontAwesomeIcons.car;
      case VehicleType.suv:
        return FontAwesomeIcons.truck;
      case VehicleType.luxury:
        return FontAwesomeIcons.gem;
      case VehicleType.van:
        return FontAwesomeIcons.bus;
    }
  }

  String _getVehicleName(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return 'Sedán';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.luxury:
        return 'Lujo';
      case VehicleType.van:
        return 'Van';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference < 7) {
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final minutes = duration.inMinutes;

    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  void _showRatingDialog(Trip trip) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Calificar Viaje'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cómo fue tu experiencia con este viaje?'),
              const SizedBox(height: 20),

              // Estrellas de calificación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: index < rating
                          ? const Color(0xFFFFD700)
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Campo de comentario
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Comentario (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Enviar calificación
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tu calificación!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF1A1A2E),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
