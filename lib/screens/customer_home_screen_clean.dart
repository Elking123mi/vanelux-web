import 'package:flutter/material.dart';
import '../constants/vanelux_colors.dart';
import '../services/vanelux_api_service.dart';
import '../services/chatgpt_service.dart';
import 'additional_screens.dart';

// Customer Home Screen
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? currentUser;
  List<Map<String, dynamic>> vehicles = [];
  List<String> aiSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data
      currentUser = await VaneLuxApiService.getCurrentUser();

      // Load vehicles
      vehicles = await VaneLuxApiService.getVehicles();

      // Get AI suggestions
      final suggestionsRaw = await ChatGPTService.getTripSuggestions(
        from:
            (currentUser?['preferredPickup'] as String?) ??
            'Miami International Airport',
        to:
            (currentUser?['preferredDestination'] as String?) ??
            'Downtown Miami',
        preferences: 'luxury transportation in Miami',
      );

      aiSuggestions = suggestionsRaw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaneLuxColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'VaneLux Dashboard',
          style: TextStyle(color: VaneLuxColors.white),
        ),
        backgroundColor: VaneLuxColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: VaneLuxColors.gold),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: VaneLuxColors.gold))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            VaneLuxColors.primaryBlue,
                            VaneLuxColors.gold,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${currentUser?['fullName'] ?? 'User'}!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: VaneLuxColors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your luxury ride awaits',
                            style: TextStyle(
                              fontSize: 16,
                              color: VaneLuxColors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VaneLuxColors.white,
                                foregroundColor: VaneLuxColors.primaryBlue,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Book Your Ride',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Services Section
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: VaneLuxColors.textDark,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _ServiceCard(
                                  icon: Icons.directions_car,
                                  title: 'Airport Transfer',
                                  description: 'Luxury rides to/from airport',
                                  color: VaneLuxColors.success,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: _ServiceCard(
                                  icon: Icons.business,
                                  title: 'Corporate',
                                  description: 'Business meeting transport',
                                  color: VaneLuxColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _ServiceCard(
                                  icon: Icons.event,
                                  title: 'Special Events',
                                  description: 'Weddings, parties & more',
                                  color: VaneLuxColors.gold,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: _ServiceCard(
                                  icon: Icons.schedule,
                                  title: '24/7 Service',
                                  description: 'Available anytime',
                                  color: VaneLuxColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Vehicles Section
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Fleet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: VaneLuxColors.textDark,
                            ),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            height: 200,
                            child: vehicles.isEmpty
                                ? Center(
                                    child: Text(
                                      'No vehicles available',
                                      style: TextStyle(
                                        color: VaneLuxColors.textGray,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: vehicles.length,
                                    itemBuilder: (context, index) {
                                      final vehicle = vehicles[index];
                                      return Container(
                                        width: 280,
                                        margin: EdgeInsets.only(right: 15),
                                        decoration: BoxDecoration(
                                          color: VaneLuxColors.white,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: VaneLuxColors
                                                    .backgroundLight,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(15),
                                                    ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.directions_car,
                                                  size: 60,
                                                  color: VaneLuxColors.gold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    vehicle['name'] ??
                                                        'Luxury Vehicle',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: VaneLuxColors
                                                          .textDark,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '${vehicle['passengers'] ?? 4} passengers • ${vehicle['luggage'] ?? 2} luggage',
                                                    style: TextStyle(
                                                      color: VaneLuxColors
                                                          .textGray,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'From \$${vehicle['basePrice'] ?? '120'}/trip',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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

                    // AI Suggestions Section
                    if (aiSuggestions.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Recommendations',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: VaneLuxColors.textDark,
                              ),
                            ),
                            SizedBox(height: 15),
                            ...aiSuggestions.map(
                              (suggestion) => Card(
                                margin: EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.lightbulb,
                                    color: VaneLuxColors.gold,
                                  ),
                                  title: Text(suggestion),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: VaneLuxColors.gold,
        unselectedItemColor: VaneLuxColors.textGray,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TripsScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
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
  final Color color;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaneLuxColors.white,
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
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: VaneLuxColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: VaneLuxColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
