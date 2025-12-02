import 'package:flutter/material.dart';

class FleetPage extends StatefulWidget {
  const FleetPage({super.key});

  @override
  State<FleetPage> createState() => _FleetPageState();
}

class _FleetPageState extends State<FleetPage> {
  final Color _navy = const Color(0xFF0B3254);
  final Color _gold = const Color(0xFFD4AF37);
  final List<String> _categories = [
    'Todos',
    'Sedanes',
    'SUV',
    'Sprinter',
    'Especial',
  ];
  String _selectedCategory = 'Todos';

  late final List<FleetVehicle> _vehicles = [
    FleetVehicle(
      name: 'Mercedes-Maybach S 680',
      category: 'Sedanes',
      imageUrl:
          'https://images.unsplash.com/photo-1617450365226-a9994d16ff2a?auto=format&fit=crop&w=1600&q=80',
      headline: 'Lujo presidencial para traslados ejecutivos y eventos VIP.',
      baseRate: 189.00,
      hourlyRate: 145.00,
      passengers: 4,
      luggage: 3,
      interior:
          'Cuero Nappa Beige, asiento reclinable, iluminación ambiental 64 tonos',
      amenities: [
        'Chofer bilingüe',
        'Wi-Fi 5G ilimitado',
        'Sistema Burmester 4D',
        'Cargadores MagSafe y USB-C',
        'Servicio de bebidas premium',
      ],
      highlights: [
        'Traslados corporativos',
        'Reuniones C-Suite',
        'Viajes JFK - Manhattan',
      ],
    ),
    FleetVehicle(
      name: 'BMW 760i xDrive',
      category: 'Sedanes',
      imageUrl:
          'https://images.unsplash.com/photo-1605559424843-9e4ad3723dad?auto=format&fit=crop&w=1600&q=80',
      headline:
          'Performance y elegancia para itinerarios intensivos en ciudad.',
      baseRate: 165.00,
      hourlyRate: 125.00,
      passengers: 4,
      luggage: 3,
      interior: 'Cuero Merino Smoke White, techo panorámico Sky Lounge',
      amenities: [
        'Pantallas táctiles traseras',
        'Modo Executive Lounge',
        'Sistema Bowers & Wilkins',
        'Almohadas de cachemira',
      ],
      highlights: [
        'Roadshows financieros',
        'Transferencias a Hampton',
        'City-to-city',
      ],
    ),
    FleetVehicle(
      name: 'Cadillac Escalade ESV Platinum',
      category: 'SUV',
      imageUrl:
          'https://images.unsplash.com/photo-1571422789648-ef357f10d838?auto=format&fit=crop&w=1600&q=80',
      headline: 'El icono norteamericano: espacio, seguridad y presencia.',
      baseRate: 172.50,
      hourlyRate: 130.00,
      passengers: 6,
      luggage: 6,
      interior: 'Cuero anilina, sistema AKG Studio Reference, techos negros',
      amenities: [
        'Refrigerador integrado',
        'Monitores duales 12"',
        'Apple TV 4K + Netflix',
        'Cristalería Baccarat',
      ],
      highlights: ['Familias VIP', 'Eventos deportivos', 'Traslados hotel 5*'],
    ),
    FleetVehicle(
      name: 'Chevrolet Suburban High Country',
      category: 'SUV',
      imageUrl:
          'https://images.unsplash.com/photo-1541447271487-0965f4d6f12f?auto=format&fit=crop&w=1600&q=80',
      headline: 'SUV versátil con capacidad extra y comodidad absoluta.',
      baseRate: 149.50,
      hourlyRate: 115.00,
      passengers: 6,
      luggage: 6,
      interior: 'Cuero Jet Black, asientos calefactables y ventilados',
      amenities: [
        'Puertos USB en todas las filas',
        'Cargador inalámbrico',
        'Audio Bose Performance',
        'Cortinillas de privacidad',
      ],
      highlights: ['Familias', 'Excursiones corporativas', 'Tours NYC'],
    ),
    FleetVehicle(
      name: 'Range Rover Autobiography LWB',
      category: 'SUV',
      imageUrl:
          'https://images.unsplash.com/photo-1617813486164-1f910f7cc8e9?auto=format&fit=crop&w=1600&q=80',
      headline: 'Capacidad all-terrain con el refinamiento británico más alto.',
      baseRate: 210.00,
      hourlyRate: 165.00,
      passengers: 4,
      luggage: 4,
      interior: 'Cuero Windsor Ebony & Perlino, Executive Class Seating',
      amenities: [
        'Consola central refrigerada',
        'Sistema Meridian Signature',
        'Tables eléctricas desplegables',
      ],
      highlights: [
        'Escapadas a Hudson Valley',
        'Eventos fashion week',
        'Clientes de alto perfil',
      ],
    ),
    FleetVehicle(
      name: 'Mercedes-Benz Sprinter Jet Class',
      category: 'Sprinter',
      imageUrl:
          'https://images.unsplash.com/photo-1605559424639-1d74fd9f5bff?auto=format&fit=crop&w=1600&q=80',
      headline:
          'Salón rodante con configuración club seating y concierge a bordo.',
      baseRate: 265.00,
      hourlyRate: 195.00,
      passengers: 10,
      luggage: 12,
      interior:
          'Cuero napa negro + detalles Piano Black, luz indirecta, piso de madera',
      amenities: [
        'Pantalla cinema 50"',
        'PS5 + streaming premium',
        'Bar iluminado',
        'Cortinillas motorizadas',
        'Espacio conferencia',
      ],
      highlights: ['Roadshows', 'Team building', 'Runway shuttles'],
    ),
    FleetVehicle(
      name: 'Executive Sprinter 3500 Extended',
      category: 'Sprinter',
      imageUrl:
          'https://images.unsplash.com/photo-1594007654729-407eedc4be65?auto=format&fit=crop&w=1600&q=80',
      headline:
          'Configuración ejecutiva 12 pax con workstation y coffee station.',
      baseRate: 235.00,
      hourlyRate: 175.00,
      passengers: 12,
      luggage: 16,
      interior: 'Asientos capitán reclinables, mesas plegables, piso executive',
      amenities: [
        'Wi-Fi empresarial Cisco',
        'Apple AirPlay + HDMI',
        'Iluminación RGB',
        'Enfriador doble',
      ],
      highlights: [
        'Grupos corporativos',
        'Shuttle aeropuertos',
        'Producciones TV',
      ],
    ),
    FleetVehicle(
      name: 'Rolls-Royce Ghost Black Badge',
      category: 'Especial',
      imageUrl:
          'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=1600&q=80',
      headline: 'Icono británico para entradas memorables y bodas boutique.',
      baseRate: 350.00,
      hourlyRate: 295.00,
      passengers: 3,
      luggage: 2,
      interior:
          'Estrellas Starlight, cuero Arctic White, inserciones fibra de carbono',
      amenities: [
        'Chofer ceremonial',
        'Paraguas RR',
        'Cristalería y champagne',
        'Kit fotografía instantánea',
      ],
      highlights: ['Bodas de lujo', 'Red carpets', 'Presentaciones de marca'],
    ),
    FleetVehicle(
      name: 'Luxe Mini Coach 27 pax',
      category: 'Especial',
      imageUrl:
          'https://images.unsplash.com/photo-1603562619648-5ef0ed15d9c4?auto=format&fit=crop&w=1600&q=80',
      headline: 'Colectivo premium con orientación hospitality y concierge.',
      baseRate: 410.00,
      hourlyRate: 315.00,
      passengers: 27,
      luggage: 32,
      interior:
          'Asientos reclinables Italian Leather, piso nogal, techo acústico',
      amenities: [
        'Streaming HD con audio Bose Pro',
        'Baño privado',
        'Refrigeradores dobles',
        'Guía turística bilingüe opcional',
      ],
      highlights: [
        'Movilidad corporativa',
        'Weddings shuttles',
        'Eventos deportivos élite',
      ],
    ),
  ];

  List<FleetVehicle> get _filteredVehicles {
    if (_selectedCategory == 'Todos') {
      return _vehicles;
    }
    return _vehicles.where((v) => v.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: _navy,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 24,
                bottom: 16,
              ),
              title: const Text('Nuestra flota de lujo'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1920&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _navy.withOpacity(0.75),
                          _navy.withOpacity(0.55),
                          _navy.withOpacity(0.82),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Experiencias sobre ruedas diseñadas a la medida',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            _HeroPill(text: 'Choferes certificados DOT'),
                            _HeroPill(text: 'Monitoreo GPS 24/7'),
                            _HeroPill(text: 'Seguro comercial completo'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlights(),
                  const SizedBox(height: 36),
                  _buildCategorySelector(),
                  const SizedBox(height: 32),
                  ..._filteredVehicles.map(_buildVehicleCard),
                  const SizedBox(height: 48),
                  _buildServiceAddOns(),
                  const SizedBox(height: 48),
                  _buildFaqSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    final items = [
      _HighlightCard(
        color: const Color(0xFF152E47),
        title: 'Hospitality 360°',
        subtitle:
            'Itinerarios curados por concierge, asignación de chofer titular y monitoreo en vivo.',
        icon: Icons.workspace_premium_outlined,
      ),
      _HighlightCard(
        color: const Color(0xFF0E2437),
        title: 'Seguridad Proactiva',
        subtitle:
            'Inspecciones diarias, sanitización electrostática y cobertura liability de 5M USD.',
        icon: Icons.verified_user_outlined,
      ),
      _HighlightCard(
        color: const Color(0xFF1C3B59),
        title: 'Flexibilidad Total',
        subtitle:
            'Atención 24/7, respuesta en menos de 5 minutos y comunicación multicanal.',
        icon: Icons.schedule_send_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1200;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: items
              .map(
                (item) => SizedBox(
                  width: isWide ? (constraints.maxWidth / 3) - 14 : 360,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona una categoría',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((category) {
            final isActive = _selectedCategory == category;
            return ChoiceChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(category),
              ),
              labelStyle: TextStyle(
                color: isActive ? _navy : _navy.withOpacity(0.65),
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              selectedColor: _gold.withOpacity(0.25),
              side: BorderSide(color: isActive ? _gold : Colors.grey.shade300),
              selected: isActive,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(FleetVehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 18),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 980;
            final content = [
              _VehicleImage(imageUrl: vehicle.imageUrl),
              const SizedBox(width: 26, height: 26),
              Expanded(
                child: _VehicleInfo(vehicle: vehicle, navy: _navy),
              ),
              const SizedBox(width: 26, height: 26),
              _VehicleSummary(
                vehicle: vehicle,
                navy: _navy,
                gold: _gold,
                onTap: () => _openVehicleDetails(vehicle),
              ),
            ];
            if (isWide) {
              return Row(children: content);
            }
            return Column(children: content);
          },
        ),
      ),
    );
  }

  Widget _buildServiceAddOns() {
    final addons = [
      (
        'Concierge aeropuerto',
        'Meet & greet personalizado en puerta de llegadas, asistencia con equipaje y coordinación con concierge hotelero.',
      ),
      (
        'Protocolos de seguridad',
        'Choferes entrenados en evasión defensiva, escoltas armados certificados NYPD off-duty (opcional).',
      ),
      (
        'Experiencias curadas',
        'Floristería, champagne Dom Pérignon, playlists personalizadas y amenities bajo petición.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios complementarios',
          style: TextStyle(
            color: _navy,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ...addons.map(
          (addon) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: _gold, size: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.$1,
                        style: TextStyle(
                          color: _navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        addon.$2,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    final faqs = [
      (
        '¿Cuánta anticipación necesito para reservar?',
        'Confirmamos inmediatamente con disponibilidad en tiempo real. Para días pico recomendamos 48 h de anticipación.',
      ),
      (
        '¿Ofrecen facturación corporativa?',
        'Sí, configuramos cuentas con crédito, reportes consolidados y dashboards de movilidad para tu empresa.',
      ),
      (
        '¿Qué incluye la tarifa base?',
        'Chofer profesional, agua Fiji, toallas refrescantes, planificación de ruta, peajes y seguimiento de vuelo.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preguntas frecuentes',
            style: TextStyle(
              color: _navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...faqs.map(
            (faq) => ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              childrenPadding: const EdgeInsets.only(
                bottom: 12,
                left: 8,
                right: 8,
              ),
              iconColor: _gold,
              collapsedIconColor: _navy.withOpacity(0.6),
              title: Text(
                faq.$1,
                style: TextStyle(color: _navy, fontWeight: FontWeight.w600),
              ),
              children: [
                Text(
                  faq.$2,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openVehicleDetails(FleetVehicle vehicle) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 32,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100, minHeight: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          color: _navy,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    vehicle.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                vehicle.headline,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _DetailChip(
                                    icon: Icons.event_available_outlined,
                                    label:
                                        'Tarifa base: \$${vehicle.baseRate.toStringAsFixed(2)}',
                                  ),
                                  _DetailChip(
                                    icon: Icons.schedule_outlined,
                                    label:
                                        'Tarifa hora: \$${vehicle.hourlyRate.toStringAsFixed(2)}',
                                  ),
                                  _DetailChip(
                                    icon: Icons.group_outlined,
                                    label: '${vehicle.passengers} pasajeros',
                                  ),
                                  _DetailChip(
                                    icon: Icons.luggage_outlined,
                                    label: '${vehicle.luggage} maletas',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              Text(
                                'Amenities signature',
                                style: TextStyle(
                                  color: _navy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...vehicle.amenities.map(
                                (a) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: _gold,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          a,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F7F3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Perfecto para',
                                  style: TextStyle(
                                    color: _navy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...vehicle.highlights.map(
                                  (h) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          color: _navy,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            h,
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Reserva iniciada para ${vehicle.name}',
                                        ),
                                        backgroundColor: _navy,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _navy,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  icon: const Icon(
                                    Icons.event_available_rounded,
                                  ),
                                  label: const Text(
                                    'Solicitar cotización inmediata',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Coordinación 24/7 vía concierge@vanelux.com\nLínea directa: +1 (332) 555-9088',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}

class FleetVehicle {
  FleetVehicle({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.headline,
    required this.baseRate,
    required this.hourlyRate,
    required this.passengers,
    required this.luggage,
    required this.interior,
    required this.amenities,
    required this.highlights,
  });

  final String name;
  final String category;
  final String imageUrl;
  final String headline;
  final double baseRate;
  final double hourlyRate;
  final int passengers;
  final int luggage;
  final String interior;
  final List<String> amenities;
  final List<String> highlights;
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _VehicleInfo extends StatelessWidget {
  const _VehicleInfo({required this.vehicle, required this.navy});

  final FleetVehicle vehicle;
  final Color navy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vehicle.name,
          style: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          vehicle.headline,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DetailChip(
              icon: Icons.group_outlined,
              label: '${vehicle.passengers} pasajeros',
            ),
            _DetailChip(
              icon: Icons.luggage_outlined,
              label: '${vehicle.luggage} maletas',
            ),
            _DetailChip(icon: Icons.king_bed_outlined, label: vehicle.interior),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Incluye',
          style: TextStyle(color: navy, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vehicle.amenities
              .map(
                (amenity) => Chip(
                  label: Text(amenity),
                  backgroundColor: const Color(0xFFF2F0EB),
                  labelStyle: TextStyle(
                    color: navy.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({
    required this.vehicle,
    required this.navy,
    required this.gold,
    required this.onTap,
  });

  final FleetVehicle vehicle;
  final Color navy;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Desde',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${vehicle.baseRate.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hora adicional \$${vehicle.hourlyRate.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.75)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Categoría: ${vehicle.category}',
            style: TextStyle(color: navy.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            'Disponibilidad inmediata',
            style: TextStyle(color: gold, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: navy,
              minimumSize: const Size(220, 48),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Ver ficha completa'),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0B3254)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0B3254),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
