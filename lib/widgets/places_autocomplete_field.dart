import 'package:flutter/material.dart';
import '../services/google_maps_service.dart';

/// Simple autocomplete field without overlay - more reliable on Windows
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
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _searchPlaces(text);
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final results = await GoogleMapsService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectSuggestion(dynamic suggestion) async {
    final placeId = suggestion['place_id'];
    final description = suggestion['description'] ?? '';

    debugPrint('✅ [AUTOCOMPLETE] Selected: $description');

    // Update text field immediately
    widget.controller.text = description;

    // Hide suggestions
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });

    // Fetch coordinates in background
    try {
      final details = await GoogleMapsService.getPlaceDetails(placeId);
      if (details['location'] != null) {
        final location = details['location'];
        final lat = location['lat'] as double;
        final lng = location['lng'] as double;

        debugPrint('✅ [AUTOCOMPLETE] Coordinates: $lat, $lng');

        if (widget.onPlaceSelected != null) {
          widget.onPlaceSelected!(placeId, description, lat, lng);
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(widget.prefixIcon, color: widget.iconColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),

        // Suggestions dropdown (shown directly below, no overlay)
        if (_showSuggestions && (_isSearching || _suggestions.isNotEmpty))
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _suggestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final description =
                              suggestion['description'] ?? '';

                          return ListTile(
                            onTap: () {
                              debugPrint('🖱️ [TAP] $description');
                              _selectSuggestion(suggestion);
                            },
                            leading: Icon(
                              Icons.location_on,
                              color: widget.iconColor,
                              size: 20,
                            ),
                            title: Text(
                              description,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            dense: true,
                          );
                        },
                      ),
          ),
      ],
    );
  }
}
