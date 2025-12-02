import 'package:flutter/material.dart';
import '../services/google_maps_service.dart';

class PlacesAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color iconColor;
  final Function(String placeId, String description, double lat, double lng)?
  onPlaceSelected;
  final VoidCallback? onChanged;

  const PlacesAutocompleteField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.iconColor = const Color(0xFF4A90E2),
    this.onPlaceSelected,
    this.onChanged,
  });

  @override
  State<PlacesAutocompleteField> createState() =>
      _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  List<dynamic> _suggestions = [];
  bool _isSearching = false;
  String? _selectedPlaceId;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300, // Ancho fijo
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
  }

  Widget _buildSuggestionsList() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        final description = suggestion['description'] ?? '';

        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              debugPrint('📍 [TAP] Suggestion selected: $description');
              // Store the suggestion data before any async operation
              final placeId = suggestion['place_id'];
              final desc = description;
              
              // Call immediately without await to prevent overlay issues
              _handleSuggestionSelection(placeId, desc);
            },
            hoverColor: Colors.grey[100],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: widget.iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await GoogleMapsService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });

        if (results.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        _removeOverlay();
        debugPrint('Error searching places: $e');
      }
    }
  }

  void _handleSuggestionSelection(String placeId, String description) {
    debugPrint('🔍 [HANDLER] Processing selection: $description');
    
    // Update text field immediately
    widget.controller.text = description;
    
    // Update state
    setState(() {
      _selectedPlaceId = placeId;
      _suggestions = []; // Clear suggestions to close overlay
    });
    
    // Remove overlay and focus immediately
    _removeOverlay();
    _focusNode.unfocus();
    
    // Fetch coordinates in background
    _fetchPlaceCoordinates(placeId, description);
  }

  Future<void> _fetchPlaceCoordinates(String placeId, String description) async {
    try {
      debugPrint('🔍 [FETCH] Getting place details for: $placeId');
      final details = await GoogleMapsService.getPlaceDetails(placeId);

      debugPrint('🔍 [FETCH] Place details received: ${details.toString()}');

      if (details['location'] != null) {
        final location = details['location'];
        final lat = location['lat'] as double;
        final lng = location['lng'] as double;

        debugPrint('✅ [FETCH] Coordinates obtained - Lat: $lat, Lng: $lng');

        if (widget.onPlaceSelected != null) {
          debugPrint('🔍 [CALLBACK] Calling onPlaceSelected');
          widget.onPlaceSelected!(placeId, description, lat, lng);
          debugPrint('✅ [CALLBACK] Success');
        } else {
          debugPrint('⚠️ [WARNING] onPlaceSelected callback is NULL!');
        }
      } else {
        debugPrint('⚠️ [WARNING] No location in place details');
      }
    } catch (e) {
      debugPrint('❌ [ERROR] Getting place details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon, color: widget.iconColor),
            suffixIcon: _selectedPlaceId != null
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            _selectedPlaceId = null;
            _searchPlaces(value);
          },
        ),
      ),
    );
  }
}
