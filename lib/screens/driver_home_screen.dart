import 'package:flutter/material.dart';
import '../constants/vanelux_colors.dart';
import '../services/vanelux_api_service.dart';
import '../main.dart';

// Driver Home Screen
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  List<Map<String, dynamic>> trips = [];
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  _loadTrips() async {
    try {
      final tripData = await VaneLuxApiService.getDriverTrips();
      setState(() {
        trips = tripData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading trips: $e'),
          backgroundColor: VaneLuxColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver Dashboard',
          style: TextStyle(color: VaneLuxColors.white),
        ),
        backgroundColor: VaneLuxColors.primaryBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: VaneLuxColors.gold),
            onPressed: () async {
              await VaneLuxApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: VaneLuxColors.gold))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isOnline
                              ? [VaneLuxColors.success, Color(0xFF059669)]
                              : [VaneLuxColors.textGray, Color(0xFF6B7280)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isOnline
                                        ? 'You\'re Online'
                                        : 'You\'re Offline',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: VaneLuxColors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _isOnline
                                        ? 'Ready to receive trips'
                                        : 'Go online to start receiving trips',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: VaneLuxColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isOnline,
                                onChanged: (value) {
                                  setState(() {
                                    _isOnline = value;
                                  });
                                },
                                activeThumbColor: VaneLuxColors.white,
                                activeTrackColor: VaneLuxColors.gold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Today's Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Today\'s Trips',
                            value: trips
                                .where((trip) => trip['status'] == 'completed')
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                            color: VaneLuxColors.success,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Pending',
                            value: trips
                                .where((trip) => trip['status'] == 'pending')
                                .length
                                .toString(),
                            icon: Icons.schedule,
                            color: VaneLuxColors.warning,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Assigned Trips
                    Text(
                      'Assigned Trips',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: VaneLuxColors.textDark,
                      ),
                    ),
                    SizedBox(height: 15),

                    trips.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: VaneLuxColors.backgroundLight,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.assignment,
                                  size: 60,
                                  color: VaneLuxColors.textGray,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'No trips assigned',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: VaneLuxColors.textGray,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Go online to start receiving trip requests',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: VaneLuxColors.textGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: trips.length,
                            itemBuilder: (context, index) {
                              final trip = trips[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: VaneLuxColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Trip #${trip['id']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: VaneLuxColors.textDark,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: trip['status'] == 'pending'
                                                ? VaneLuxColors.warning
                                                      .withOpacity(0.1)
                                                : VaneLuxColors.success
                                                      .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            trip['status']?.toUpperCase() ??
                                                'PENDING',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: trip['status'] == 'pending'
                                                  ? VaneLuxColors.warning
                                                  : VaneLuxColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: VaneLuxColors.success,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            trip['pickupLocation'] ??
                                                'Pickup location',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: VaneLuxColors.textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          color: VaneLuxColors.error,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            trip['dropoffLocation'] ??
                                                'Dropoff location',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: VaneLuxColors.textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: VaneLuxColors.gold,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          trip['scheduledTime'] ??
                                              'Scheduled time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: VaneLuxColors.textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    if (trip['status'] == 'pending')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Start trip functionality
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    VaneLuxColors.success,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Start Trip',
                                                style: TextStyle(
                                                  color: VaneLuxColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                // View details functionality
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: VaneLuxColors.gold,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Details',
                                                style: TextStyle(
                                                  color: VaneLuxColors.gold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VaneLuxColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: VaneLuxColors.textDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: VaneLuxColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
