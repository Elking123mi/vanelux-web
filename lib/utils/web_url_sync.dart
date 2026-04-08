import 'package:flutter/foundation.dart';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String toUrlSlug(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return 'page';

  final normalized = trimmed
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return normalized.isEmpty ? 'page' : normalized;
}

void syncWebPath(
  String path, {
  bool replace = false,
  Map<String, String>? queryParameters,
}) {
  if (!kIsWeb) return;

  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final sanitizedQuery = queryParameters == null || queryParameters.isEmpty
      ? null
      : queryParameters.map((key, value) => MapEntry(key, value.trim()));

  final targetUri = Uri(
    path: normalizedPath,
    queryParameters: sanitizedQuery,
  );
  final targetHash = '#${targetUri.toString()}';

  void apply({required bool useReplace}) {
    if (html.window.location.hash == targetHash) return;
    if (useReplace) {
      html.window.history.replaceState(null, '', targetHash);
    } else {
      html.window.history.pushState(null, '', targetHash);
    }
  }

  apply(useReplace: replace);

  // Flutter Web can rewrite URL right after startup; enforce the target hash.
  scheduleMicrotask(() => apply(useReplace: true));
  Future.delayed(const Duration(milliseconds: 120), () {
    apply(useReplace: true);
  });
}
