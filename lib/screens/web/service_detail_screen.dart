import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/web_url_sync.dart';
import 'corporate_registration_screen.dart';
import 'fleet_screen.dart';
import 'web_home_screen.dart';
import 'contact_us_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceType;

  const ServiceDetailScreen({super.key, required this.serviceType});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? userName;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    syncWebPath('/services');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          userName = user.name;
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  bool get _isCorporateVerified {
    final user = _currentUser;
    if (user == null) return false;
    return user.roles.contains('corporate') ||
        user.allowedApps.contains('vanelux_corporate');
  }

  String _mapServiceTypeForBooking() {
    // Map ServiceDetailScreen service types to WebHomeScreen service types
    switch (widget.serviceType) {
      case 'Airport Transfer':
        return 'To Airport';
      case 'Hourly Service':
        return 'Hourly/As Directed';
      case 'Tours':
        return 'Tour';
      case 'Point to Point':
      case 'Corporate':
      case 'Events':
      default:
        return widget.serviceType;
    }
  }

  String _getPackageSectionTitle() {
    switch (widget.serviceType) {
      case 'Airport Transfer':
        return 'Our Airport Transfer Packages';
      case 'Hourly Service':
        return 'Our Hourly Service Packages';
      case 'Corporate':
        return 'Our Corporate Packages';
      case 'Events':
        return 'Our Event Packages';
      case 'Tours':
        return 'Our Tour Packages';
      case 'Point to Point':
        return 'Our Point to Point Packages';
      default:
        return 'Our Service Packages';
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
              'description':
                  'Real-time monitoring of your flight status to ensure on-time pickup',
            },
            {
              'icon': Icons.people,
              'title': 'Meet & Greet',
              'description':
                  'Professional chauffeur waiting at arrivals with your name sign',
            },
            {
              'icon': Icons.luggage,
              'title': 'Luggage Assistance',
              'description':
                  'Complete baggage handling from terminal to vehicle',
            },
          ],
          'packages': [
            {
              'name': 'Basic Package',
              'description':
                  'Perfect for solo travelers or couples. Includes standard sedan service.',
              'duration': '1-Way',
              'price': '\$85',
            },
            {
              'name': 'Standard Package',
              'description':
                  'Ideal for families. Includes SUV with luggage space.',
              'duration': 'Round Trip',
              'price': '\$150',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Premium Package',
              'description':
                  'Luxury sedan with VIP treatment. Perfect for business travelers.',
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
              'description':
                  'Direct pickup from your location to your exact destination',
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
              'description':
                  'One-time ride within city limits. Perfect for appointments.',
              'duration': 'One-Way',
              'price': '\$45',
            },
            {
              'name': 'Round Trip',
              'description':
                  'Go and return service with waiting time included.',
              'duration': 'Round Trip',
              'price': '\$85',
              'badge': 'SAVE 15%',
            },
            {
              'name': 'Weekly Pass',
              'description':
                  'Unlimited city rides for one week. Best for commuters.',
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
              'description':
                  'Visit as many locations as you want during your rental period',
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
              'description':
                  'Perfect for business meetings or short shopping trips. Includes 2 hours of service.',
              'duration': '2 Hours',
              'price': '\$120',
            },
            {
              'name': 'Standard Package',
              'description':
                  'Ideal for half-day sightseeing or shopping. Includes 4 hours of service.',
              'duration': '4 Hours',
              'price': '\$220',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Premium Package',
              'description':
                  'Full-day service for extensive tours or business needs. Includes 8 hours.',
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
              'description':
                  'Dedicated support for all your corporate transportation needs',
            },
            {
              'icon': Icons.receipt_long,
              'title': 'Billing Reports',
              'description':
                  'Consolidated monthly invoices with detailed trip reports',
            },
            {
              'icon': Icons.verified_user,
              'title': 'Priority Service',
              'description':
                  'Guaranteed vehicle availability for urgent business needs',
            },
          ],
          'packages': [
            {
              'name': 'Starter Plan',
              'description':
                  'Perfect for small businesses. Includes 20 rides per month.',
              'duration': 'Per Month',
              'price': '\$1,500',
            },
            {
              'name': 'Business Plan',
              'description':
                  'For growing companies. Includes 50 rides and priority booking.',
              'duration': 'Per Month',
              'price': '\$3,500',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Enterprise Plan',
              'description':
                  'Unlimited rides for large corporations with custom solutions.',
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
              'description':
                  'Vehicles decorated and prepared for your special photo moments',
            },
            {
              'icon': Icons.local_bar,
              'title': 'Champagne Service',
              'description':
                  'Complimentary champagne and refreshments for celebrations',
            },
            {
              'icon': Icons.event_available,
              'title': 'Event Coordination',
              'description':
                  'Professional planning to ensure everything runs smoothly',
            },
          ],
          'packages': [
            {
              'name': 'Prom Package',
              'description':
                  'Perfect for prom night. Includes 4 hours with red carpet.',
              'duration': '4 Hours',
              'price': '\$399',
            },
            {
              'name': 'Wedding Package',
              'description':
                  'Complete wedding transportation with decorations and photos.',
              'duration': '6 Hours',
              'price': '\$599',
              'badge': 'MOST POPULAR',
            },
            {
              'name': 'Luxury Event',
              'description':
                  'Full premium experience for any special occasion.',
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
              'description':
                  'Create your own itinerary or choose from our popular tours',
            },
            {
              'icon': Icons.person_pin,
              'title': 'Expert Guides',
              'description':
                  'Knowledgeable local guides sharing city history and culture',
            },
            {
              'icon': Icons.camera_alt,
              'title': 'Photo Stops',
              'description':
                  'Multiple stops at the best photo spots throughout the tour',
            },
          ],
          'packages': [
            {
              'name': 'City Highlights',
              'description':
                  'Quick tour of top 5 attractions. Perfect for first-time visitors.',
              'duration': '4 Hours',
              'price': '\$299',
            },
            {
              'name': 'Full Day Tour',
              'description':
                  'Complete city experience with all major attractions and lunch.',
              'duration': '8 Hours',
              'price': '\$499',
              'badge': 'BEST VALUE',
            },
            {
              'name': 'Custom Tour',
              'description':
                  'Design your own tour with our expert guide and driver.',
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

  bool _isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 900;
  }

  bool _isTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 900 && width < 1240;
  }

  double _sectionPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 18;
    if (width < 1240) return 36;
    return 80;
  }

  void _goHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WebHomeScreen()),
    );
  }

  void _navigateToBooking({String? packageName}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WebHomeScreen(
          initialServiceType: _mapServiceTypeForBooking(),
          selectedPackage: packageName,
          isServiceLocked: packageName != null,
        ),
      ),
    );
  }

  void _openCorporateRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CorporateRegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceInfo = _getServiceInfo();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
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
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    if (isMobile) {
      return Container(
        height: 76,
        padding: EdgeInsets.symmetric(horizontal: pad),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _goHome,
              child: const Text(
                'VANELUX',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B3254),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined, color: Color(0xFF0B3254)),
              tooltip: '9294180058',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Color(0xFF0B3254)),
              onSelected: (value) {
                if (value == 'HOME') {
                  _goHome();
                } else if (value == 'FLEET') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FleetScreen(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetailScreen(serviceType: value),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'HOME', child: Text('Home')),
                PopupMenuItem(value: 'FLEET', child: Text('Fleet')),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'Airport Transfer',
                  child: Text('Airport Transfer'),
                ),
                PopupMenuItem(
                  value: 'Point to Point',
                  child: Text('Point to Point'),
                ),
                PopupMenuItem(
                  value: 'Hourly Service',
                  child: Text('Hourly Service'),
                ),
                PopupMenuItem(value: 'Corporate', child: Text('Corporate')),
                PopupMenuItem(value: 'Events', child: Text('Events')),
                PopupMenuItem(value: 'Tours', child: Text('Tours')),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      height: 88,
      padding: EdgeInsets.symmetric(horizontal: pad),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _goHome,
            child: const Text(
              'VANELUX',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B3254),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          _buildNavItem('HOME', _goHome),
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
                    color: Color(0xFF0B3254),
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () {},
              child: const Text(
                '9294180058',
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
            fontSize: 13.5,
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
        _buildServiceMenuItem(
          context,
          'Airport Transfer',
          Icons.flight_takeoff,
        ),
        _buildServiceMenuItem(context, 'Point to Point', Icons.location_on),
        _buildServiceMenuItem(context, 'Hourly Service', Icons.access_time),
        _buildServiceMenuItem(context, 'Corporate', Icons.business_center),
        _buildServiceMenuItem(context, 'Events', Icons.celebration),
        _buildServiceMenuItem(context, 'Tours', Icons.tour),
      ],
    );
  }

  PopupMenuEntry<String> _buildServiceMenuItem(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return PopupMenuItem<String>(
      value: title,
      onTap: () {
        if (widget.serviceType == title) return;
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF0B3254)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> info) {
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      height: isMobile ? 440 : 560,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: info['image'] != null
            ? DecorationImage(
                image: AssetImage(info['image']),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.44),
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
                  const Color(0xFF1A4D7A),
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.58),
                  ],
                ),
              ),
            ),
          ),
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 54,
              vertical: isMobile ? 24 : 44,
            ),
            child: Align(
              alignment: isMobile ? Alignment.center : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 640 : 820),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isMobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.24),
                        ),
                      ),
                      child: const Text(
                        'Tailored luxury mobility',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 14 : 20),
                    Row(
                      mainAxisAlignment: isMobile
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.32),
                            ),
                          ),
                          child: Icon(
                            info['icon'],
                            size: isMobile ? 34 : 42,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!isMobile)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Premium Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 14 : 24),
                    Text(
                      info['title'],
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        fontSize: isMobile ? 42 : 62,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info['subtitle'],
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        fontSize: isMobile ? 19 : 25,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (widget.serviceType == 'Corporate') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _isCorporateVerified
                              ? const Color(0xFF22C55E).withOpacity(0.22)
                              : Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isCorporateVerified
                                ? const Color(0xFF22C55E)
                                : Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCorporateVerified
                                  ? Icons.verified
                                  : Icons.approval,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isCorporateVerified
                                    ? 'Corporate account verified for your login'
                                    : 'Not corporate-verified yet. Submit your corporate account request.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: isMobile ? 24 : 34),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: isMobile
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _navigateToBooking(),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Book this service'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF0B3254),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FleetScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions_car_outlined),
                          label: const Text('View fleet'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.74),
                              width: 1.6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (widget.serviceType == 'Corporate')
                          ElevatedButton.icon(
                            onPressed: _openCorporateRegistration,
                            icon: Icon(
                              _isCorporateVerified
                                  ? Icons.domain_verification
                                  : Icons.business_center,
                            ),
                            label: Text(
                              _isCorporateVerified
                                  ? 'Manage corporate setup'
                                  : 'Apply corporate account',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B3254),
                              foregroundColor: const Color(0xFFD4AF37),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: Color(0xFFD4AF37),
                                  width: 1.2,
                                ),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> info) {
    final isMobile = _isMobileLayout(context);
    final isTablet = _isTabletLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 34,
        vertical: isMobile ? 28 : 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3254).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'WHY CHOOSE US',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: Color(0xFF0B3254),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Handpicked chauffeurs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B3254),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 18 : 24),
          Text(
            info['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              height: 1.65,
              color: const Color(0xFF3F4A59),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isMobile ? 22 : 30),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              _buildStatCard(
                '500+',
                'Happy Clients',
                compact: isMobile || isTablet,
              ),
              _buildStatCard(
                '24/7',
                'Always Available',
                compact: isMobile || isTablet,
              ),
              _buildStatCard(
                '100%',
                'Private Comfort',
                compact: isMobile || isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, {bool compact = false}) {
    return Container(
      width: compact ? 160 : 200,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 16 : 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF0B3254).withOpacity(0.12)),
          color: const Color(0xFFF9FBFF),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: compact ? 30 : 34,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B3254),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: const Color(0xFF5B6678),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfoSection(Map<String, dynamic> info) {
    if (!info.containsKey('detailedInfo')) return const SizedBox.shrink();

    final detailedInfo = info['detailedInfo'] as List;
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 30,
        vertical: isMobile ? 28 : 34,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${info['title']} Experience',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Details designed for comfort, precision and style.',
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 26),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      info['image'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (info['image'] != null) const SizedBox(height: 18),
                Text(
                  info['subtitle'] ?? '',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B3254),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  info['description'],
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Color(0xFF556070),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info['image'] != null)
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        info['image'],
                        height: 330,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (info['image'] != null) const SizedBox(width: 28),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['subtitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B3254),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        info['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          color: Color(0xFF556070),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemWidth = maxWidth < 740
                  ? maxWidth
                  : maxWidth < 1140
                  ? (maxWidth - 20) / 2
                  : (maxWidth - 40) / 3;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: detailedInfo.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3254),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              size: 28,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(Map<String, dynamic> info) {
    if (!info.containsKey('packages')) return const SizedBox.shrink();

    final packages = info['packages'] as List;
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
        vertical: isMobile ? 24 : 34,
      ),
      decoration: const BoxDecoration(color: Color(0xFFEEF3FA)),
      child: Column(
        children: [
          Text(
            _getPackageSectionTitle(),
            style: TextStyle(
              fontSize: isMobile ? 28 : 38,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3254),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 26 : 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final cardWidth = maxWidth < 760
                  ? maxWidth
                  : maxWidth < 1200
                  ? (maxWidth - 22) / 2
                  : (maxWidth - 44) / 3;

              return Wrap(
                spacing: 22,
                runSpacing: 22,
                children: packages.map((package) {
                  final hasBadge = package.containsKey('badge');
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasBadge
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFDDE4EE),
                          width: hasBadge ? 2.2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (hasBadge)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Text(
                                package['badge'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package['name'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  package['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0B3254,
                                        ).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        package['duration'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0B3254),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      package['price'],
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0B3254),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: widget.serviceType == 'Corporate'
                                        ? _openCorporateRegistration
                                        : () => _navigateToBooking(
                                            packageName: package['name'],
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B3254),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: Text(
                                      widget.serviceType == 'Corporate'
                                          ? 'Apply account'
                                          : 'Choose package',
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
              );
            },
          ),
          const SizedBox(height: 34),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 18 : 22,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3254),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceType == 'Corporate'
                      ? 'Corporate Account Registration'
                      : 'Custom Hourly Services',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.serviceType == 'Corporate'
                      ? 'Corporate account registration: submit your company request and our team will verify your account manually.'
                      : 'Need a custom duration? We can accommodate any timeframe for your specific needs.',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: widget.serviceType == 'Corporate'
                          ? _openCorporateRegistration
                          : () => _navigateToBooking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0B3254),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.serviceType == 'Corporate'
                            ? 'Request corporate verification'
                            : 'Request custom quote',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _goHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.6)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to booking'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCupSection() {
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 26,
        vertical: isMobile ? 20 : 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a4d7a), Color(0xFF0B3254)],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Special Event Spotlight',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'World Cup 2026 transport concierge',
            style: TextStyle(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Reserve luxury transportation for match days, airport arrivals and private group itineraries across host cities.',
            style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _navigateToBooking(),
                icon: const Icon(Icons.event),
                label: const Text('View event packages'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0B3254),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone),
                label: const Text('CALL: 9294180058'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 30,
        vertical: isMobile ? 26 : 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3254),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Features',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: features.map<Widget>((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CD17D),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(Map<String, dynamic> info) {
    final offers = info['offers'] as List;
    if (offers.isEmpty) return const SizedBox.shrink();

    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 26 : 34,
      ),
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
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3254),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Save more with our exclusive deals',
            style: TextStyle(fontSize: 20, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final cardWidth = maxWidth < 760
                  ? maxWidth
                  : maxWidth < 1200
                  ? (maxWidth - 20) / 2
                  : (maxWidth - 40) / 3;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: offers.map((offer) {
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.8),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.16),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Text(
                              offer['discount'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0B3254),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Text(
                                  offer['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0B3254),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  offer['description'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0B3254,
                                    ).withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Code: ${offer['code']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0B3254),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(Map<String, dynamic> info) {
    final pricing = info['pricing'] as Map<String, String>;
    if (pricing.isEmpty) return const SizedBox.shrink();

    final hasVehicles = info.containsKey('vehicles');
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Transparent Pricing',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3254),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'No hidden fees, just premium service',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),

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
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: (info['vehicles'] as List).map((vehicle) {
                return Container(
                  width: isMobile ? 220 : 250,
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
            const SizedBox(height: 36),
          ],

          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0B3254).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: pricing.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
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
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              color: const Color(0xFF333333),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 24,
                          fontWeight: FontWeight.w800,
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
              Icon(Icons.info_outline, size: 18, color: Colors.grey[500]),
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
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 70,
        horizontal: isMobile ? 18 : 30,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
              padding: const EdgeInsets.all(16),
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
            Text(
              'Ready to Book?',
              style: TextStyle(
                fontSize: isMobile ? 38 : 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Experience luxury transportation today',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToBooking(),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('BOOK NOW'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0B3254),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ContactUsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('CONTACT US'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.8),
                      width: 1.6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: const [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '9294180058',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Available 24/7',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isMobile = _isMobileLayout(context);
    final pad = _sectionPadding(context);

    return Container(
      color: const Color(0xFF0B3254),
      margin: EdgeInsets.only(top: 24),
      padding: EdgeInsets.symmetric(
        horizontal: pad,
        vertical: isMobile ? 30 : 34,
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('Airport Transfer'),
              _buildFooterLink('Point to Point'),
              _buildFooterLink('Hourly Service'),
              _buildFooterLink('Corporate'),
              _buildFooterLink('Events'),
              _buildFooterLink('Tours'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '© 2026 VANELUX. All rights reserved.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium luxury transportation, redesigned for comfort and speed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title) {
    return GestureDetector(
      onTap: () {
        if (widget.serviceType == title) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(serviceType: title),
          ),
        );
      },
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.84),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
