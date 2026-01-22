import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'fleet_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceType;

  const ServiceDetailScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          userName = user.name;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Map<String, dynamic> _getServiceInfo() {
    switch (widget.serviceType) {
      case 'Airport Transfer':
        return {
          'title': 'Airport Transfer',
          'subtitle': 'Premium Transportation to All Major Airports',
          'icon': Icons.flight_takeoff,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/all airports.jpg',
          'description':
              'Travel in style and comfort with our premium airport transfer service. We provide reliable, punctual transportation to and from all major airports in the area.',
          'detailedInfo': [
            {
              'icon': Icons.schedule,
              'title': 'Flight Tracking',
              'description': 'Real-time monitoring of your flight status to ensure on-time pickup',
            },
            {
              'icon': Icons.people,
              'title': 'Meet & Greet',
              'description': 'Professional chauffeur waiting at arrivals with your name sign',
            },
            {
              'icon': Icons.luggage,
              'title': 'Luggage Assistance',
              'description': 'Complete baggage handling from terminal to vehicle',
            },
          ],
          'packages': [
            {
              'name': 'Basic Package',
              'description': 'Perfect for solo travelers or couples. Includes standard sedan service.',
              'duration': '1-Way',
              'price': '\$85',
            },
            {
              'name': 'Standard Package',
              'description': 'Ideal for families. Includes SUV with luggage space.',
              'duration': 'Round Trip',
              'price': '\$150',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Premium Package',
              'description': 'Luxury sedan with VIP treatment. Perfect for business travelers.',
              'duration': 'Round Trip',
              'price': '\$300',
            },
          ],
          'features': [
            'Real-time flight tracking',
            'Meet & Greet service',
            'Luggage assistance',
            'Free waiting time (60 min domestic, 90 min international)',
            'Premium vehicles with Wi-Fi',
            'Professional chauffeurs',
          ],
          'offers': [
            {
              'title': 'Early Bird Special',
              'discount': '15% OFF',
              'description': 'Book 7 days in advance',
              'code': 'EARLY15',
            },
            {
              'title': 'Round Trip Discount',
              'discount': '20% OFF',
              'description': 'Book round trip and save',
              'code': 'ROUND20',
            },
            {
              'title': 'Corporate Rate',
              'discount': '25% OFF',
              'description': 'For business accounts',
              'code': 'CORP25',
            },
          ],
          'pricing': {
            'Sedan': '\$85 - \$120',
            'SUV': '\$110 - \$150',
            'Luxury Sedan': '\$150 - \$200',
            'Van': '\$130 - \$180',
          },
        };

      case 'Point to Point':
        return {
          'title': 'Point to Point',
          'subtitle': 'Direct Luxury Transportation Anywhere',
          'icon': Icons.location_on,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/point to point.jpg',
          'description':
              'Experience hassle-free direct transportation from any location to your destination. Perfect for business meetings, special occasions, or daily commutes.',
          'detailedInfo': [
            {
              'icon': Icons.maps_home_work,
              'title': 'Door-to-Door',
              'description': 'Direct pickup from your location to your exact destination',
            },
            {
              'icon': Icons.gps_fixed,
              'title': 'Live Tracking',
              'description': 'Track your ride in real-time with GPS monitoring',
            },
            {
              'icon': Icons.schedule_outlined,
              'title': 'Flexible Timing',
              'description': 'Schedule rides anytime, 24/7 availability',
            },
          ],
          'packages': [
            {
              'name': 'Single Trip',
              'description': 'One-time ride within city limits. Perfect for appointments.',
              'duration': 'One-Way',
              'price': '\$45',
            },
            {
              'name': 'Round Trip',
              'description': 'Go and return service with waiting time included.',
              'duration': 'Round Trip',
              'price': '\$85',
              'badge': 'SAVE 15%',
            },
            {
              'name': 'Weekly Pass',
              'description': 'Unlimited city rides for one week. Best for commuters.',
              'duration': '7 Days',
              'price': '\$299',
            },
          ],
          'features': [
            'Door-to-door service',
            'Real-time GPS tracking',
            'Flexible scheduling',
            'Multiple stops available',
            'Premium comfort vehicles',
            'Professional drivers',
          ],
          'offers': [
            {
              'title': 'First Ride',
              'discount': '10% OFF',
              'description': 'Welcome discount for new customers',
              'code': 'FIRST10',
            },
            {
              'title': 'Weekly Package',
              'discount': '30% OFF',
              'description': '5 or more rides per week',
              'code': 'WEEKLY30',
            },
            {
              'title': 'Monthly Unlimited',
              'discount': '\$999/mo',
              'description': 'Unlimited city rides',
              'code': 'MONTHLY',
            },
          ],
          'pricing': {
            'Within City': '\$45 - \$85',
            'Nearby Cities': '\$100 - \$180',
            'Long Distance': '\$200+',
            'Luxury Option': '+35%',
          },
        };

      case 'Hourly Service':
        return {
          'title': 'Hourly Service',
          'subtitle': 'Your Personal Chauffeur By The Hour',
          'icon': Icons.access_time,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/hourly service.jpg',
          'description':
              'Have a personal chauffeur at your disposal for as long as you need. Perfect for business days, shopping trips, or touring the city at your own pace.',
          'detailedInfo': [
            {
              'icon': Icons.timer,
              'title': 'Flexible Duration',
              'description': 'Book for as little as 2 hours or for a full day',
            },
            {
              'icon': Icons.map,
              'title': 'Multiple Destinations',
              'description': 'Visit as many locations as you want during your rental period',
            },
            {
              'icon': Icons.attach_money,
              'title': 'All-Inclusive Pricing',
              'description': 'No hidden fees, all taxes and tolls included',
            },
          ],
          'packages': [
            {
              'name': 'Basic Package',
              'description': 'Perfect for business meetings or short shopping trips. Includes 2 hours of service.',
              'duration': '2 Hours',
              'price': '\$120',
            },
            {
              'name': 'Standard Package',
              'description': 'Ideal for half-day sightseeing or shopping. Includes 4 hours of service.',
              'duration': '4 Hours',
              'price': '\$220',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Premium Package',
              'description': 'Full-day service for extensive tours or business needs. Includes 8 hours.',
              'duration': '8 Hours',
              'price': '\$400',
            },
          ],
          'features': [
            'Flexible hourly rates',
            'No hidden fees',
            'Multiple destinations',
            'Wait time included',
            'Premium vehicles',
            'Experienced chauffeurs',
          ],
          'offers': [
            {
              'title': '4 Hours Package',
              'discount': '\$199',
              'description': 'Save \$50 compared to standard rate',
              'code': '4HOUR',
            },
            {
              'title': '8 Hours Package',
              'discount': '\$379',
              'description': 'Full day service - Best Value',
              'code': '8HOUR',
            },
            {
              'title': 'Extended Day',
              'discount': '\$549',
              'description': '12 hours of luxury service',
              'code': '12HOUR',
            },
          ],
          'pricing': {
            '2 Hours': '\$120',
            '3 Hours': '\$170',
            '4 Hours': '\$220',
            'Additional Hour': '\$50',
          },
        };

      case 'Corporate':
        return {
          'title': 'Corporate Services',
          'subtitle': 'Executive Transportation Solutions',
          'icon': Icons.business_center,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/corporate service.jpg',
          'description':
              'Professional transportation services tailored for businesses. Impress clients, facilitate employee travel, and ensure punctuality for all corporate events.',
          'detailedInfo': [
            {
              'icon': Icons.account_circle,
              'title': 'Account Manager',
              'description': 'Dedicated support for all your corporate transportation needs',
            },
            {
              'icon': Icons.receipt_long,
              'title': 'Billing Reports',
              'description': 'Consolidated monthly invoices with detailed trip reports',
            },
            {
              'icon': Icons.verified_user,
              'title': 'Priority Service',
              'description': 'Guaranteed vehicle availability for urgent business needs',
            },
          ],
          'packages': [
            {
              'name': 'Starter Plan',
              'description': 'Perfect for small businesses. Includes 20 rides per month.',
              'duration': 'Per Month',
              'price': '\$1,500',
            },
            {
              'name': 'Business Plan',
              'description': 'For growing companies. Includes 50 rides and priority booking.',
              'duration': 'Per Month',
              'price': '\$3,500',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Enterprise Plan',
              'description': 'Unlimited rides for large corporations with custom solutions.',
              'duration': 'Per Month',
              'price': 'Custom',
            },
          ],
          'features': [
            'Dedicated account manager',
            'Priority booking',
            'Consolidated billing',
            'Travel reports',
            'Multiple user accounts',
            'Executive vehicles',
          ],
          'offers': [
            {
              'title': 'Corporate Account',
              'discount': '25% OFF',
              'description': 'Volume discount on all rides',
              'code': 'BIZPRO',
            },
            {
              'title': 'Monthly Contract',
              'discount': '35% OFF',
              'description': 'Minimum 20 rides/month',
              'code': 'CONTRACT35',
            },
            {
              'title': 'Event Package',
              'discount': 'Custom',
              'description': 'Multiple vehicles for conferences',
              'code': 'EVENT',
            },
          ],
          'pricing': {
            'Executive Sedan': '\$95 - \$140',
            'Premium SUV': '\$130 - \$180',
            'Sprinter Van': '\$180 - \$250',
            'Custom Quote': 'Contact us',
          },
        };

      case 'Events':
        return {
          'title': 'Special Events',
          'subtitle': 'Make Your Celebration Unforgettable',
          'icon': Icons.celebration,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/weeding.jpg',
          'description':
              'Make your special day even more memorable with our luxury event transportation. Perfect for weddings, proms, anniversaries, and any celebration.',
          'detailedInfo': [
            {
              'icon': Icons.photo_camera,
              'title': 'Photo Ready',
              'description': 'Vehicles decorated and prepared for your special photo moments',
            },
            {
              'icon': Icons.local_bar,
              'title': 'Champagne Service',
              'description': 'Complimentary champagne and refreshments for celebrations',
            },
            {
              'icon': Icons.event_available,
              'title': 'Event Coordination',
              'description': 'Professional planning to ensure everything runs smoothly',
            },
          ],
          'packages': [
            {
              'name': 'Prom Package',
              'description': 'Perfect for prom night. Includes 4 hours with red carpet.',
              'duration': '4 Hours',
              'price': '\$399',
            },
            {
              'name': 'Wedding Package',
              'description': 'Complete wedding transportation with decorations and photos.',
              'duration': '6 Hours',
              'price': '\$599',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Luxury Event',
              'description': 'Full premium experience for any special occasion.',
              'duration': '8 Hours',
              'price': '\$899',
            },
          ],
          'features': [
            'Red carpet service',
            'Decorated vehicles',
            'Champagne service',
            'Professional coordination',
            'Multiple vehicle options',
            'Photo opportunities',
          ],
          'offers': [
            {
              'title': 'Wedding Package',
              'discount': '\$599',
              'description': '6 hours with decoration',
              'code': 'WEDDING',
            },
            {
              'title': 'Prom Special',
              'discount': '\$399',
              'description': '4 hours group rate',
              'code': 'PROM',
            },
            {
              'title': 'Anniversary',
              'discount': '20% OFF',
              'description': 'Celebrate in luxury',
              'code': 'ANNIV20',
            },
          ],
          'pricing': {
            'Standard Package': '\$450 - \$650',
            'Premium Package': '\$700 - \$950',
            'Luxury Package': '\$1,000+',
            'Custom Package': 'Contact us',
          },
        };

      case 'Tours':
        return {
          'title': 'City Tours',
          'subtitle': 'Discover The City In Style',
          'icon': Icons.tour,
          'color': const Color(0xFF0B3254),
          'image': 'assets/images/city tours.png',
          'description':
              'Explore the city\'s best attractions with our guided luxury tours. Customized itineraries, knowledgeable guides, and premium comfort throughout your journey.',
          'detailedInfo': [
            {
              'icon': Icons.route,
              'title': 'Custom Routes',
              'description': 'Create your own itinerary or choose from our popular tours',
            },
            {
              'icon': Icons.person_pin,
              'title': 'Expert Guides',
              'description': 'Knowledgeable local guides sharing city history and culture',
            },
            {
              'icon': Icons.camera_alt,
              'title': 'Photo Stops',
              'description': 'Multiple stops at the best photo spots throughout the tour',
            },
          ],
          'packages': [
            {
              'name': 'City Highlights',
              'description': 'Quick tour of top 5 attractions. Perfect for first-time visitors.',
              'duration': '4 Hours',
              'price': '\$299',
            },
            {
              'name': 'Full Day Tour',
              'description': 'Complete city experience with all major attractions and lunch.',
              'duration': '8 Hours',
              'price': '\$499',
              'badge': 'BEST VALUE',
            },
            {
              'name': 'Custom Tour',
              'description': 'Design your own tour with our expert guide and driver.',
              'duration': 'Flexible',
              'price': '\$99/hr',
            },
          ],
          'features': [
            'Customized routes',
            'Expert local guides',
            'All major attractions',
            'Flexible schedule',
            'Comfort stops included',
            'Photo opportunities',
          ],
          'offers': [
            {
              'title': 'Half Day Tour',
              'discount': '\$299',
              'description': '4 hours - Top 5 attractions',
              'code': 'TOUR4',
            },
            {
              'title': 'Full Day Tour',
              'discount': '\$499',
              'description': '8 hours - Complete experience',
              'code': 'TOUR8',
            },
            {
              'title': 'Custom Tour',
              'discount': '15% OFF',
              'description': 'Create your own itinerary',
              'code': 'CUSTOM15',
            },
          ],
          'pricing': {
            'City Highlights': '\$299 - \$399',
            'Full Day Tour': '\$499 - \$649',
            'Multi-Day Package': '\$999+',
            'Private Guide': '+\$100',
          },
        };

      default:
        return {
          'title': 'Our Services',
          'subtitle': 'Premium Transportation Solutions',
          'icon': Icons.car_rental,
          'color': const Color(0xFF0B3254),
          'description': 'Explore our range of luxury transportation services.',
          'features': [],
          'offers': [],
          'pricing': {},
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceInfo = _getServiceInfo();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(serviceInfo),
            _buildDescriptionSection(serviceInfo),
            _buildDetailedInfoSection(serviceInfo),
            _buildPackagesSection(serviceInfo),
            _buildFeaturesSection(serviceInfo),
            _buildOffersSection(serviceInfo),
            _buildPricingSection(serviceInfo),
            _buildWorldCupSection(),
            _buildBookNowSection(serviceInfo),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              'VANELUX',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254),
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          // Nav items
          _buildNavItem('HOME', () => Navigator.of(context).pop()),
          const SizedBox(width: 30),
          _buildServicesMenu(context),
          const SizedBox(width: 30),
          _buildNavItem('FLEET', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FleetScreen()),
            );
          }),
          const SizedBox(width: 30),
          _buildNavItem('ABOUT', () => Navigator.of(context).pop()),
          const SizedBox(width: 40),
          // User info
          if (userName != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0B3254),
                  radius: 18,
                  child: Text(
                    userName![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Hi, $userName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () {},
              child: const Text(
                '+1 917 599-5522',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B3254),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, VoidCallback? onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Color(0xFF0B3254),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            const Text(
              'SERVICES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Color(0xFF0B3254),
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_drop_down,
              color: const Color(0xFF0B3254),
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildServiceMenuItem(context, 'Airport Transfer', Icons.flight_takeoff),
        _buildServiceMenuItem(context, 'Point to Point', Icons.location_on),
        _buildServiceMenuItem(context, 'Hourly Service', Icons.access_time),
        _buildServiceMenuItem(context, 'Corporate', Icons.business_center),
        _buildServiceMenuItem(context, 'Events', Icons.celebration),
        _buildServiceMenuItem(context, 'Tours', Icons.tour),
      ],
    );
  }

  PopupMenuEntry<String> _buildServiceMenuItem(BuildContext context, String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      onTap: () {
        // Si ya estamos en esa página, no hacer nada
        if (widget.serviceType == title) return;
        
        // Navegar a la nueva página de servicio
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceType: title),
            ),
          );
        });
      },
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0B3254)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0B3254),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> info) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        image: info['image'] != null
            ? DecorationImage(
                image: AssetImage(info['image']),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: info['image'] == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  info['color'],
                  const Color(0xFF0B3254),
                  const Color(0xFF1a4d7a),
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay oscuro para mejorar legibilidad del texto
          if (info['image'] != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          // Efectos de fondo decorativos
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    info['icon'],
                    size: 100,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  info['title'],
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  info['subtitle'],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Botón decorativo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Color(0xFF0B3254), size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Premium Service',
                        style: TextStyle(
                          color: Color(0xFF0B3254),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFFAFAFA),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'WHY CHOOSE US',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254),
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            info['description'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              height: 1.8,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('500+', 'Happy Clients'),
              const SizedBox(width: 40),
              _buildStatCard('24/7', 'Support'),
              const SizedBox(width: 40),
              _buildStatCard('100%', 'Satisfaction'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfoSection(Map<String, dynamic> info) {
    if (!info.containsKey('detailedInfo')) return const SizedBox.shrink();
    
    final detailedInfo = info['detailedInfo'] as List;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100,
            vertical: isMobile ? 40 : 80,
          ),
          color: Colors.white,
          child: Column(
            children: [
              // Título con icono
              isMobile
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B3254),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            info['icon'],
                            color: const Color(0xFFFFD700),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${info['title']} - Premium Service',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3254),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B3254),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            info['icon'],
                            color: const Color(0xFFFFD700),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            '${info['title']} - Premium Service',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3254),
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: isMobile ? 24 : 40),
              
              // Imagen y descripción
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        if (info['image'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              info['image'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Descripción
                        Text(
                          info['subtitle'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3254),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          info['description'],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        if (info['image'] != null)
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                info['image'],
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(width: 40),
                        // Descripción
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info['subtitle'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3254),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                info['description'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.8,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: isMobile ? 32 : 50),
              
              // Características detalladas
              isMobile
                  ? Column(
                      children: detailedInfo.map<Widget>((item) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B3254),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                item['icon'],
                                color: const Color(0xFFFFD700),
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: detailedInfo.map((item) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B3254),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    size: 40,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackagesSection(Map<String, dynamic> info) {
    if (!info.containsKey('packages')) return const SizedBox.shrink();
    
    final packages = info['packages'] as List;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100,
            vertical: isMobile ? 40 : 80,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FA),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                'Our Hourly Service Packages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B3254),
                ),
              ),
              SizedBox(height: isMobile ? 32 : 60),
              isMobile
                  ? Column(
                      children: packages.map<Widget>((package) {
                        final hasBadge = package.containsKey('badge');
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: hasBadge
                                ? Border.all(color: const Color(0xFFFFD700), width: 3)
                                : Border.all(color: Colors.grey.shade200, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (hasBadge)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    package['badge'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B3254),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      package['name'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0B3254),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      package['description'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          package['duration'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                        Text(
                                          package['price'],
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0B3254),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: packages.map((package) {
              final hasBadge = package.containsKey('badge');
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: hasBadge
                        ? Border.all(color: const Color(0xFFFFD700), width: 3)
                        : Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (hasBadge)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            package['badge'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3254),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              package['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  package['duration'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                                Text(
                                  package['price'],
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Regresar a la página principal
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B3254),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  'Custom Hourly Services',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Need a custom duration? We can accommodate any timeframe for your specific needs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    // Regresar a la página principal
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Request Custom Quote',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCupSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a4d7a),
            Color(0xFF0B3254),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/en/thumb/e/e3/2026_FIFA_World_Cup.svg/1200px-2026_FIFA_World_Cup.svg.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Color(0xFFFFD700),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'WORLD CUP 2026',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 300,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Colors.orange,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'USA • CANADA • MEXICO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '🏆 Official Transportation Partner 🏆',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Book your luxury transportation for all World Cup 2026 matches!\nExclusive packages available for fans traveling to stadiums.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Regresar a la página principal
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.event, size: 24),
                label: const Text(
                  'VIEW WORLD CUP PACKAGES',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0B3254),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
              ),
              const SizedBox(width: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Abrir el teléfono (en web no hace nada, pero en móvil funcionaría)
                },
                icon: const Icon(Icons.phone, size: 24),
                label: const Text(
                  'CALL: +1 917 599-5522',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(Map<String, dynamic> info) {
    final features = info['features'] as List;
    if (features.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Container(
          color: const Color(0xFFF8F9FA),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100,
            vertical: isMobile ? 40 : 80,
          ),
          child: Column(
            children: [
              Text(
                'Service Features',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B3254),
                ),
              ),
              SizedBox(height: isMobile ? 32 : 50),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: isMobile ? 0 : 40,
                  mainAxisSpacing: isMobile ? 16 : 40,
                  childAspectRatio: isMobile ? 8 : 3,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF28A745),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          features[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersSection(Map<String, dynamic> info) {
    final offers = info['offers'] as List;
    if (offers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0B3254).withOpacity(0.03),
            const Color(0xFFFFD700).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF0B3254),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Special Offers & Promotions',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3254),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Save more with our exclusive deals',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: offers.map((offer) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Badge de descuento
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            offer['discount'],
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3254),
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Contenido
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text(
                              offer['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B3254),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              offer['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B3254).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF0B3254).withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.confirmation_number,
                                    color: Color(0xFF0B3254),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Code: ${offer['code']}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B3254),
                                      letterSpacing: 1,
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
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(Map<String, dynamic> info) {
    final pricing = info['pricing'] as Map<String, String>;
    if (pricing.isEmpty) return const SizedBox.shrink();

    // Mostrar vehículos si existen
    final hasVehicles = info.containsKey('vehicles');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
      child: Column(
        children: [
          const Text(
            'Transparent Pricing',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'No hidden fees, just premium service',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 60),
          
          // Mostrar vehículos con imágenes si existen
          if (hasVehicles) ...[
            const Text(
              'Our Fleet',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3254),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: (info['vehicles'] as List).map((vehicle) {
                return Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0B3254).withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B3254).withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.asset(
                          vehicle['image'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.directions_car,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          vehicle['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3254),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 80),
          ],
          
          // Tabla de precios
          Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFF0B3254).withOpacity(0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B3254).withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: pricing.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFFD700),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 8),
              Text(
                'Prices may vary based on distance, time, and vehicle availability',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowSection(Map<String, dynamic> info) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0B3254),
            const Color(0xFF1a4d7a),
            info['color'],
          ],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 50,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Ready to Book?',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Experience luxury transportation today',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Color(0xFF0B3254),
                            size: 24,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'BOOK NOW',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3254),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 25),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'CONTACT US',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  '+1 917 599-5522',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 30),
                Icon(Icons.access_time, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Available 24/7',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0B3254),
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      child: const Column(
        children: [
          Text(
            '© 2026 VANELUX. All rights reserved.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Premium Luxury Transportation Services',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
