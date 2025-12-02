// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

import '../config/app_config.dart';

class RouteMapView extends StatefulWidget {
  const RouteMapView({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.strokeColor,
    this.strokeWeight,
  });

  final String originLabel;
  final String destinationLabel;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? strokeColor;
  final double? strokeWeight;

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  static int _viewFactoryCounter = 0;
  late final String _elementId;
  html.DivElement? _container;
  bool _isRendering = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _elementId = 'route-map-view-${_viewFactoryCounter++}';
    _container = html.DivElement()
      ..id = _elementId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.border = '0'
      ..style.borderRadius = '16px'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = '#10223D';

    // Register the view factory for the embedded HTML map container.
    ui_web.platformViewRegistry.registerViewFactory(
      _elementId,
      (int viewId) => _container!,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _renderRoute());
  }

  bool get _hasValidCoordinates =>
      widget.originLat != null &&
      widget.originLng != null &&
      widget.destinationLat != null &&
      widget.destinationLng != null;

  @override
  void didUpdateWidget(RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool coordinatesChanged =
        widget.originLat != oldWidget.originLat ||
        widget.originLng != oldWidget.originLng ||
        widget.destinationLat != oldWidget.destinationLat ||
        widget.destinationLng != oldWidget.destinationLng;
    if (coordinatesChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _renderRoute());
    }
  }

  Future<void> _renderRoute() async {
    if (!mounted) {
      return;
    }

    if (!_hasValidCoordinates) {
      setState(() {
        _errorMessage =
            'Selecciona direcciones válidas para visualizar la ruta en el mapa.';
        _isRendering = false;
      });
      return;
    }

    setState(() {
      _isRendering = true;
      _errorMessage = null;
    });

    try {
      final Object? bridge = js_util.getProperty(
        js_util.globalThis,
        'vaneluxMaps',
      );
      if (bridge == null) {
        throw Exception('Google Maps bridge no disponible.');
      }

      final Map<String, dynamic> origin = <String, dynamic>{
        'lat': widget.originLat,
        'lng': widget.originLng,
        'label': widget.originLabel,
      };
      final Map<String, dynamic> destination = <String, dynamic>{
        'lat': widget.destinationLat,
        'lng': widget.destinationLng,
        'label': widget.destinationLabel,
      };

      final Map<String, dynamic> options = <String, dynamic>{
        'strokeColor': widget.strokeColor ?? '#0B3254',
        'strokeWeight': widget.strokeWeight ?? 5,
        'fitPadding': 72,
      };

      await js_util.promiseToFuture<void>(
        js_util.callMethod(bridge, 'renderRouteMap', <dynamic>[
          AppConfig.googleMapsApiKey,
          _elementId,
          origin,
          destination,
          options,
        ]),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRendering = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRendering = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _container = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      HtmlElementView(viewType: _elementId, key: ValueKey<String>(_elementId)),
    ];

    if (_isRendering) {
      children.add(
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x18000000)),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      children.add(
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.55),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }
}
