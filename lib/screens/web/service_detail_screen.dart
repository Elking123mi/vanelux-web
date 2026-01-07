import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceType;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceType,
  }) : super(key: key);

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
          'description':
              'Travel in style and comfort with our premium airport transfer service. We provide reliable, punctual transportation to and from all major airports in the area.',
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
          'description':
              'Experience hassle-free direct transportation from any location to your destination. Perfect for business meetings, special occasions, or daily commutes.',
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
          'description':
              'Have a personal chauffeur at your disposal for as long as you need. Perfect for business days, shopping trips, or touring the city at your own pace.',
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
          'description':
              'Professional transportation services tailored for businesses. Impress clients, facilitate employee travel, and ensure punctuality for all corporate events.',
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
          'description':
              'Make your special day even more memorable with our luxury event transportation. Perfect for weddings, proms, anniversaries, and any celebration.',
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
          'description':
              'Explore the city\'s best attractions with our guided luxury tours. Customized itineraries, knowledgeable guides, and premium comfort throughout your journey.',
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
            _buildFeaturesSection(serviceInfo),
            _buildOffersSection(serviceInfo),
            _buildPricingSection(serviceInfo),
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
          _buildNavItem('SERVICES', null),
          const SizedBox(width: 30),
          _buildNavItem('FLEET', null),
          const SizedBox(width: 30),
          _buildNavItem('ABOUT', null),
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

  Widget _buildHeroSection(Map<String, dynamic> info) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            info['color'],
            const Color(0xFF0B3254),
            const Color(0xFF1a4d7a),
          ],
        ),
      ),
      child: Stack(
        children: [
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

  Widget _buildFeaturesSection(Map<String, dynamic> info) {
    final features = info['features'] as List;
    if (features.isEmpty) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
      child: Column(
        children: [
          const Text(
            'Service Features',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 50),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 40,
              mainAxisSpacing: 40,
              childAspectRatio: 3,
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
