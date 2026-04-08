import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void syncWebPath(String path, {bool replace = false}) {
  if (!kIsWeb) return;

  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final targetHash = '#$normalizedPath';

  if (html.window.location.hash == targetHash) {
    return;
  }

  if (replace) {
    html.window.history.replaceState(null, '', targetHash);
  } else {
    html.window.history.pushState(null, '', targetHash);
  }
}
