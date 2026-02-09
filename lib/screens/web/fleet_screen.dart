import 'package:flutter/material.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(),
            _buildFleetGrid(),
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
          _buildNavItem('HOME', () => Navigator.of(context).pop()),
          const SizedBox(width: 30),
          _buildNavItem('SERVICES', () => Navigator.of(context).pop()),
          const SizedBox(width: 30),
          _buildNavItem('FLEET', null),
          const SizedBox(width: 30),
          _buildNavItem('ABOUT', () => Navigator.of(context).pop()),
          const SizedBox(width: 40),
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

  Widget _buildHeroSection() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3254),
            Color(0xFF1a4d7a),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Our Premium Fleet',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Luxury Vehicles for Every Occasion',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetGrid() {
    final vehicles = [
      {
        'name': 'Mercedes S-Class',
        'description': 'Luxury sedan perfect for executive transport',
        'passengers': 'Up to 3 passengers',
        'price': '\$120/hour',
        'image': 'assets/images/mercdes-s-class.png',
        'badge': 'LUXURY',
      },
      {
        'name': 'BMW 7 Series',
        'description': 'Premium comfort with advanced technology',
        'passengers': 'Up to 3 passengers',
        'price': '\$115/hour',
        'image': 'assets/images/bmw 7 series.jpg',
        'badge': 'LUXURY',
      },
      {
        'name': 'Audi A8',
        'description': 'Sophisticated design meets cutting-edge performance',
        'passengers': 'Up to 3 passengers',
        'price': '\$110/hour',
        'image': 'assets/images/audi a8.jpg',
        'badge': 'LUXURY',
      },
      {
        'name': 'Cadillac Escalade',
        'description': 'Spacious SUV for families and groups',
        'passengers': 'Up to 6 passengers',
        'price': '\$150/hour',
        'image': 'assets/images/cadillac-scalade.png',
        'badge': 'SUV',
      },
      {
        'name': 'Suburban',
        'description': 'Comfortable group transportation',
        'passengers': 'Up to 7 passengers',
        'price': '\$140/hour',
        'image': 'assets/images/suburban.png',
        'badge': 'SUV',
      },
      {
        'name': 'Suburban RTS',
        'description': 'Extended SUV for special events',
        'passengers': 'Up to 7 passengers',
        'price': '\$160/hour',
        'image': 'assets/images/suburban rts.png',
        'badge': 'SUV',
      },
      {
        'name': 'Mercedes Sprinter',
        'description': 'Luxury van for group transportation',
        'passengers': 'Up to 14 passengers',
        'price': '\$180/hour',
        'image': 'assets/images/mercedez-sprinter.png',
        'badge': 'VAN',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 30,
          mainAxisSpacing: 40,
          childAspectRatio: 0.75,
        ),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  vehicle['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: const Color(0xFFF5F5F5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car,
                            size: 60,
                            color: Color(0xFF0B3254),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Premium Vehicle',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0B3254),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vehicle['badge'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3254),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vehicle['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 18,
                        color: Color(0xFF0B3254),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vehicle['passengers'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0B3254),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehicle['price'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B3254),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF0B3254),
      child: const Center(
        child: Text(
          '© 2026 Vanelux. All rights reserved.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
