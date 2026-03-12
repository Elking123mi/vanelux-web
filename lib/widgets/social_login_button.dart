import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButton extends StatelessWidget {
  final String provider; // 'google' or 'facebook'
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGoogle = provider.toLowerCase() == 'google';
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isGoogle ? Colors.grey[300]! : const Color(0xFF1877F2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: isGoogle ? Colors.white : const Color(0xFF1877F2),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isGoogle ? Colors.grey : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    isGoogle
                        ? FontAwesomeIcons.google
                        : FontAwesomeIcons.facebook,
                    size: 20,
                    color: isGoogle ? const Color(0xFF4285F4) : Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isGoogle
                        ? 'Continue with Google'
                        : 'Continue with Facebook',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isGoogle ? Colors.black87 : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Widget with divider for social login section
class SocialLoginSection extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final bool isLoading;

  const SocialLoginSection({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR"
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey[300], thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey[300], thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Google Sign-In Button
        SocialLoginButton(
          provider: 'google',
          onPressed: onGooglePressed,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),

        // Facebook Sign-In Button
        SocialLoginButton(
          provider: 'facebook',
          onPressed: onFacebookPressed,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
