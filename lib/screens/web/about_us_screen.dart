import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color _brandBlue = Color(0xFF0B3254);
  static const Color _brandGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _brandBlue,
        elevation: 0.8,
        title: const Text(
          'About VaneLux',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(isCompact),
            _buildStats(isCompact),
            _buildStory(isCompact),
            _buildGallery(isCompact),
            _buildValues(isCompact),
            _buildCta(context, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 20 : 60,
        vertical: isCompact ? 28 : 44,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B3254), Color(0xFF15456E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroLogo(),
                const SizedBox(height: 16),
                _heroText(isCompact),
              ],
            )
          : Row(
              children: [
                Expanded(child: _heroText(isCompact)),
                const SizedBox(width: 40),
                _heroLogo(size: 190),
              ],
            ),
    );
  }

  Widget _heroLogo({double size = 140}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  Widget _heroText(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Luxury transportation with trust, style, and precision.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 28 : 44,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'VaneLux was built to deliver first-class ground transportation for business leaders, families, and travelers who value reliability and comfort.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isCompact ? 16 : 18,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isCompact) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 60,
        vertical: isCompact ? 24 : 34,
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: const [
          _StatCard(number: '10+', label: 'Years of service'),
          _StatCard(number: '500K+', label: 'Happy customers'),
          _StatCard(number: '50+', label: 'Luxury vehicles'),
          _StatCard(number: '24/7', label: 'Always available'),
        ],
      ),
    );
  }

  Widget _buildStory(bool isCompact) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 60),
      padding: EdgeInsets.all(isCompact ? 18 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Story',
            style: TextStyle(
              color: _brandBlue,
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'At VaneLux, every ride is designed as a premium experience. From airport transfers and executive meetings to weddings and special events, our professional chauffeurs and luxury fleet are focused on punctuality, discretion, and comfort.',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: isCompact ? 15 : 17,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We continuously improve our service standards, route planning, and vehicle quality so each client receives a smooth and memorable journey from pickup to drop-off.',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: isCompact ? 15 : 17,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(bool isCompact) {
    final cards = [
      _ImageCardData(
        imagePath: 'assets/images/corporate service.jpg',
        title: 'Executive Transportation',
      ),
      _ImageCardData(
        imagePath: 'assets/images/all airports.jpg',
        title: 'Airport Transfers',
      ),
      _ImageCardData(
        imagePath: 'assets/images/city tours.png',
        title: 'City Tours',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 60,
        vertical: 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What We Deliver',
            style: TextStyle(
              color: _brandBlue,
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isCompact ? 1 : 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isCompact ? 1.45 : 1.05,
            ),
            itemBuilder: (context, index) => _buildImageCard(cards[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(_ImageCardData data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(data.imagePath, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00000000), Color(0xB2000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValues(bool isCompact) {
    final values = [
      _ValueData(
        icon: Icons.schedule,
        title: 'Punctuality',
        text: 'On-time pickups and careful route planning for every booking.',
      ),
      _ValueData(
        icon: Icons.verified_user,
        title: 'Safety',
        text: 'Experienced chauffeurs and maintained vehicles for peace of mind.',
      ),
      _ValueData(
        icon: Icons.auto_awesome,
        title: 'Comfort',
        text: 'Premium interiors and smooth rides for business or leisure trips.',
      ),
      _ValueData(
        icon: Icons.support_agent,
        title: 'Service',
        text: 'Professional support and concierge-level attention, 24/7.',
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 60),
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Core Values',
            style: TextStyle(
              color: _brandBlue,
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: values
                .map((value) => _buildValueCard(value, isCompact))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(_ValueData value, bool isCompact) {
    return Container(
      width: isCompact ? double.infinity : 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _brandGold.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(value.icon, color: _brandBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _brandBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCta(BuildContext context, bool isCompact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isCompact ? 16 : 60, 24, isCompact ? 16 : 60, 40),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 18 : 26),
        decoration: BoxDecoration(
          color: _brandBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ctaText(isCompact),
                  const SizedBox(height: 14),
                  _ctaButton(context),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _ctaText(isCompact)),
                  const SizedBox(width: 18),
                  _ctaButton(context),
                ],
              ),
      ),
    );
  }

  Widget _ctaText(bool isCompact) {
    return Text(
      'Ready to ride with VaneLux? Book your next trip and experience premium transportation done right.',
      style: TextStyle(
        color: Colors.white,
        fontSize: isCompact ? 16 : 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }

  Widget _ctaButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandGold,
        foregroundColor: _brandBlue,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'BOOK A RIDE',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE4EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VANELUX',
            style: TextStyle(
              color: AboutUsScreen._brandGold,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              color: AboutUsScreen._brandBlue,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _ImageCardData {
  const _ImageCardData({required this.imagePath, required this.title});

  final String imagePath;
  final String title;
}

class _ValueData {
  const _ValueData({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;
}
