import 'package:flutter/material.dart';

import '../../services/local_booking_service.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  List<Map<String, dynamic>> _bookings = const [];
  bool _isLoading = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    final data = await LocalBookingService.getBookings();
    if (!mounted) {
      return;
    }

    setState(() {
      _bookings = data;
      _isLoading = false;
    });
  }

  Future<void> _clearBookings() async {
    setState(() {
      _isClearing = true;
    });

    await LocalBookingService.clearBookings();

    if (!mounted) {
      return;
    }

    setState(() {
      _bookings = const [];
      _isClearing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF1A1A2E),
        actions: [
          if (_bookings.isNotEmpty)
            IconButton(
              onPressed: _isClearing ? null : _clearBookings,
              tooltip: 'Eliminar historial',
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
            ? const Center(child: Text('Aún no tienes reservas guardadas.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return _BookingCard(booking: booking);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _bookings.length,
              ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final createdAtString = booking['createdAt'] as String?;
    final createdAt = createdAtString != null
        ? DateTime.tryParse(createdAtString)
        : null;
    final scheduledAtString = booking['scheduledAt'] as String?;
    final scheduledAt = scheduledAtString != null
        ? DateTime.tryParse(scheduledAtString)
        : null;
    final price = (booking['price'] as num?)?.toDouble();
    final distanceLabel = booking['distanceText'] as String? ?? '';
    final durationLabel = booking['durationText'] as String? ?? '';
    final isScheduled = booking['isScheduled'] == true;

    String _formatDate(DateTime? date) {
      if (date == null) {
        return 'Fecha no disponible';
      }
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year • $hour:$minute';
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['pickupAddress'] as String? ?? 'Sin origen',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking['destinationAddress'] as String? ??
                                  'Sin destino',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (price != null)
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (distanceLabel.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.straighten, size: 16),
                    label: Text(distanceLabel),
                  ),
                if (durationLabel.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: Text(durationLabel),
                  ),
                Chip(
                  avatar: const Icon(Icons.local_taxi, size: 16),
                  label: Text(booking['vehicleName'] as String? ?? 'Vehículo'),
                ),
                Chip(
                  avatar: const Icon(Icons.local_offer, size: 16),
                  label: Text(
                    (booking['serviceType'] as String? ?? 'servicio')
                        .toUpperCase(),
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isScheduled ? Icons.calendar_today : Icons.bolt,
                    size: 16,
                  ),
                  label: Text(isScheduled ? 'Programado' : 'Inmediato'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Creada: ${_formatDate(createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (scheduledAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Programada para: ${_formatDate(scheduledAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

