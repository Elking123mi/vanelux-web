import 'package:flutter/material.dart';
import '../constants/vanelux_colors.dart';
import '../services/vanelux_api_service.dart';
import '../services/chatgpt_service.dart';
import '../services/google_maps_service.dart';
import 'additional_screens.dart';

// Customer Home Screen
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Map<String, dynamic>> vehicles = [];
  bool _isLoading = true;
  Map<String, dynamic>? currentUser;
  String? _aiSuggestion;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    try {
      print('🔄 Cargando datos del dashboard...');
      
      // Cargar vehículos
      print('📋 Obteniendo lista de vehículos...');
      final vehicleData = await VaneLuxApiService.getVehicles();
      print('✅ Vehículos obtenidos: ${vehicleData.length} vehículos');
      
      // Cargar datos del usuario
      print('👤 Obteniendo datos del usuario...');
      final userData = await VaneLuxApiService.getCurrentUser();
      print('✅ Datos del usuario obtenidos: ${userData['username'] ?? 'No username'}');
      
      // Obtener sugerencia de IA
      print('🤖 Obteniendo sugerencias de IA...');
      try {
        final suggestion = await ChatGPTService.getTripSuggestions(
          from: 'Su ubicación actual',
          to: 'Destino deseado',
          preferences: 'Servicio de lujo premium',
        );
        setState(() {
          _aiSuggestion = suggestion;
        });
      } catch (e) {
        print('⚠️ Error obteniendo sugerencia de IA: $e');
      }
      
      setState(() {
        vehicles = vehicleData;
        currentUser = userData;
        _isLoading = false;
      });
      
      print('🎉 Dashboard cargado exitosamente!');
    } catch (e) {
      print('❌ Error cargando dashboard: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando datos: $e'),
          backgroundColor: VaneLuxColors.error,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: VaneLuxColors.primaryBlue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: VaneLuxColors.gold),
              SizedBox(height: 20),
              Text(
                'Cargando tu experiencia VaneLux...',
                style: TextStyle(
                  color: VaneLuxColors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('VaneLux', style: TextStyle(color: VaneLuxColors.white, fontWeight: FontWeight.bold)),
        backgroundColor: VaneLuxColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: VaneLuxColors.gold),
            onPressed: () {
              // Implementar notificaciones
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: VaneLuxColors.white),
            onPressed: () {
              // Implementar perfil de usuario
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo personalizado
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [VaneLuxColors.primaryBlue, VaneLuxColors.primaryBlue.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${currentUser?['fullName'] ?? currentUser?['username'] ?? 'Usuario'}',
                      style: TextStyle(
                        color: VaneLuxColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tu experiencia de lujo te espera',
                      style: TextStyle(
                        color: VaneLuxColors.gold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sugerencia de IA
              if (_aiSuggestion != null)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VaneLuxColors.gold.withOpacity(0.1),
                    border: Border.all(color: VaneLuxColors.gold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: VaneLuxColors.gold),
                          SizedBox(width: 8),
                          Text(
                            'Sugerencia del Asistente IA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: VaneLuxColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _aiSuggestion!,
                        style: TextStyle(
                          color: VaneLuxColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Acción rápida - Reservar ahora
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar reserva rápida
                    _showQuickBookingDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VaneLuxColors.gold,
                    foregroundColor: VaneLuxColors.primaryBlue,
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_road, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Reservar Viaje Ahora',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Flota de vehículos
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Nuestra Flota de Lujo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VaneLuxColors.primaryBlue,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Lista de vehículos
              if (vehicles.isEmpty)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: VaneLuxColors.error.withOpacity(0.1),
                    border: Border.all(color: VaneLuxColors.error),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: VaneLuxColors.error, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'No se pudieron cargar los vehículos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VaneLuxColors.error,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tira hacia abajo para actualizar',
                        style: TextStyle(color: VaneLuxColors.textDark),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Container(
                        width: 280,
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del vehículo
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: vehicle['image'] != null
                                  ? Image.network(
                                      vehicle['image'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 48,
                                          color: VaneLuxColors.primaryBlue,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 120,
                                      color: VaneLuxColors.primaryBlue.withOpacity(0.1),
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 48,
                                        color: VaneLuxColors.primaryBlue,
                                      ),
                                    ),
                            ),
                            
                            // Detalles del vehículo
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle['name'] ?? 'Vehículo de Lujo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: VaneLuxColors.primaryBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    vehicle['description'] ?? 'Experiencia de lujo premium',
                                    style: TextStyle(
                                      color: VaneLuxColors.textDark,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              SizedBox(height: 20),
              
              // Servicios adicionales
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Servicios Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VaneLuxColors.primaryBlue,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Grid de servicios
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildServiceCard(
                      'Aeropuerto',
                      Icons.flight,
                      'Traslados de lujo',
                      () => _openServiceDetail('Aeropuerto'),
                    ),
                    _buildServiceCard(
                      'Eventos',
                      Icons.event,
                      'Ocasiones especiales',
                      () => _openServiceDetail('Eventos'),
                    ),
                    _buildServiceCard(
                      'Empresarial',
                      Icons.business,
                      'Transporte ejecutivo',
                      () => _openServiceDetail('Empresarial'),
                    ),
                    _buildServiceCard(
                      'City Tours',
                      Icons.location_city,
                      'Recorridos personalizados',
                      () => _openServiceDetail('City Tours'),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAIAssistant();
        },
        backgroundColor: VaneLuxColors.gold,
        foregroundColor: VaneLuxColors.primaryBlue,
        icon: Icon(Icons.chat),
        label: Text('Asistente IA'),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: VaneLuxColors.primaryBlue,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: VaneLuxColors.primaryBlue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: VaneLuxColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reserva Rápida'),
          content: Text('¿Deseas crear una nueva reserva?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar navegación a pantalla de reserva
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _openServiceDetail(String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Servicio $service seleccionado'),
        backgroundColor: VaneLuxColors.primaryBlue,
      ),
    );
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VaneLuxColors.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat, color: VaneLuxColors.gold),
                    SizedBox(width: 12),
                    Text(
                      'Asistente VaneLux IA',
                      style: TextStyle(
                        color: VaneLuxColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Próximamente: Chat en tiempo real con nuestro asistente de IA para ayudarte con reservas, sugerencias de rutas y más.',
                    style: TextStyle(fontSize: 16),
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
          IconButton(
            icon = const Icon(Icons.person, color: VaneLuxColors.gold),
            onPressed = () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child = CircularProgressIndicator(color: VaneLuxColors.gold))
          : SingleChildScrollView(
              child = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [VaneLuxColors.primaryBlue, Color(0xFF1E3A5F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${currentUser?['fullName'] ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: VaneLuxColors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Where would you like to go today?',
                          style: TextStyle(
                            fontSize: 16,
                            color: VaneLuxColors.gold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Book a Ride Button
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [VaneLuxColors.gold, Color(0xFFB8860B)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: VaneLuxColors.gold.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BookingScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_taxi, color: VaneLuxColors.primaryBlue),
                                SizedBox(width: 10),
                                Text(
                                  'Book a Ride',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: VaneLuxColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Services Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Services',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: VaneLuxColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _ServiceCard(
                                icon: Icons.flight_takeoff,
                                title: 'Airport Transfer',
                                description: 'Reliable airport pickups',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _ServiceCard(
                                icon: Icons.location_on,
                                title: 'Point to Point',
                                description: 'Direct city transfers',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _ServiceCard(
                                icon: Icons.schedule,
                                title: 'Hourly Service',
                                description: 'Book by the hour',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _ServiceCard(
                                icon: Icons.event,
                                title: 'Events',
                                description: 'Special occasions',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Vehicle Fleet Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Luxury Fleet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: VaneLuxColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = vehicles[index];
                              return Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  color: VaneLuxColors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                        color: VaneLuxColors.backgroundLight,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 60,
                                          color: VaneLuxColors.gold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vehicle['name'] ?? 'Luxury Vehicle',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: VaneLuxColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${vehicle['passengers'] ?? 4} passengers • ${vehicle['luggage'] ?? 2} luggage',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: VaneLuxColors.textGray,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'From \$${vehicle['basePrice'] ?? '120'}/trip',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: VaneLuxColors.gold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type = BottomNavigationBarType.fixed,
        selectedItemColor = VaneLuxColors.gold,
        unselectedItemColor = VaneLuxColors.textGray,
        items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap = (index) {
          switch (index) {
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => TripsScreen()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              break;
          }
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: VaneLuxColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: VaneLuxColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: VaneLuxColors.gold,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: VaneLuxColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: VaneLuxColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}