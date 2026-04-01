import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OAuthService {
  // Google Sign-In configuration
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '579087046563-ofmak1mol3fo8evutbtrp33i63muv5bf.apps.googleusercontent.com'
        : null, // Android/iOS uses google-services.json/GoogleService-Info.plist
    scopes: [
      'email',
      'profile',
    ],
  );

  static const String _apiBaseUrl =
      'https://web-production-700fe.up.railway.app/api/v1';

  /// Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null; // User cancelled
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        throw Exception('Failed to get token from Google');
      }

      print('📤 Sending token to backend (idToken: ${idToken != null}, accessToken: ${accessToken != null})...');

      // Build payload - use whichever token is available
      // On web (GIS), signIn() returns accessToken but not idToken
      final Map<String, dynamic> payload = {
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      };
      if (idToken != null) payload['id_token'] = idToken;
      if (accessToken != null) payload['access_token'] = accessToken;

      // Send to backend for verification and user creation
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend authentication successful');

        // Save full session (token + user) so it persists across reloads
        await AuthService.saveOAuthSession(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          userData: Map<String, dynamic>.from(data['user']),
        );

        return {
          'success': true,
          'user': data['user'],
          'access_token': data['access_token'],
          'provider': 'google',
        };
      } else {
        throw Exception(
            'Backend authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign in with Facebook
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      print('🔵 Starting Facebook Sign-In...');

      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        print('❌ Facebook Sign-In failed: ${result.status}');
        return null;
      }

      print('✅ Facebook Sign-In successful');

      // Get user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final String? accessToken = result.accessToken?.tokenString;

      if (accessToken == null) {
        throw Exception('Failed to get access token from Facebook');
      }

      print('📤 Sending access token to backend...');

      // Send to backend
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/facebook'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
          'email': userData['email'],
          'name': userData['name'],
          'photo_url': userData['picture']?['data']?['url'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend authentication successful');

        // Save full session (token + user) so it persists across reloads
        await AuthService.saveOAuthSession(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          userData: Map<String, dynamic>.from(data['user']),
        );

        return {
          'success': true,
          'user': data['user'],
          'access_token': data['access_token'],
          'provider': 'facebook',
        };
      } else {
        throw Exception(
            'Backend authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Facebook Sign-In error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign up with Google — rejects with 409 if the account already exists.
  /// Use this for Sign Up flows (uses /auth/google/signup endpoint).
  /// For Login flows use [signInWithGoogle] instead.
  static Future<Map<String, dynamic>?> signUpWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-Up...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ User cancelled Google Sign-Up');
        return null;
      }
      print('✅ Google Sign-Up auth: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      if (idToken == null && accessToken == null) {
        throw Exception('Failed to get token from Google');
      }
      final Map<String, dynamic> payload = {
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      };
      if (idToken != null) payload['id_token'] = idToken;
      if (accessToken != null) payload['access_token'] = accessToken;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/google/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend sign-up successful');
        await AuthService.saveOAuthSession(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          userData: Map<String, dynamic>.from(data['user']),
        );
        return {
          'success': true,
          'user': data['user'],
          'access_token': data['access_token'],
          'provider': 'google',
        };
      } else if (response.statusCode == 409) {
        Map<String, dynamic> body = {};
        try { body = jsonDecode(response.body); } catch (_) {}
        return {
          'success': false,
          'error': body['detail'] ?? 'Ya existe una cuenta con este correo. Por favor inicia sesión.',
        };
      } else {
        throw Exception(
            'Backend sign-up failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Google Sign-Up error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign out from all providers
  static Future<void> signOut() async {
    try {
      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print('✅ Signed out from Google');
      }

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();
      print('✅ Signed out from Facebook');

      // Clear local auth tokens
      await AuthService.clearTokens();
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  /// Check if user is signed in with any OAuth provider
  static Future<bool> isSignedIn() async {
    final bool googleSignedIn = await _googleSignIn.isSignedIn();
    final AccessToken? fbToken = await FacebookAuth.instance.accessToken;
    return googleSignedIn || fbToken != null;
  }

  /// Get current OAuth provider
  static Future<String?> getCurrentProvider() async {
    if (await _googleSignIn.isSignedIn()) {
      return 'google';
    }
    final AccessToken? fbToken = await FacebookAuth.instance.accessToken;
    if (fbToken != null) {
      return 'facebook';
    }
    return null;
  }
}
