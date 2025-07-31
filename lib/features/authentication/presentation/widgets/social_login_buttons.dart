import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In
        if (onGooglePressed != null)
          SocialLoginButton(
            onPressed: isLoading ? null : onGooglePressed,
            icon: 'assets/icons/google.svg',
            label: 'Continue with Google',
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            borderColor: Colors.grey.shade300,
          ),
        
        if (onApplePressed != null) ...[
          const SizedBox(height: 12),
          // Apple Sign In
          SocialLoginButton(
            onPressed: isLoading ? null : onApplePressed,
            icon: 'assets/icons/apple.svg',
            label: 'Continue with Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
        
        if (onFacebookPressed != null) ...[
          const SizedBox(height: 12),
          // Facebook Sign In
          SocialLoginButton(
            onPressed: isLoading ? null : onFacebookPressed,
            icon: 'assets/icons/facebook.svg',
            label: 'Continue with Facebook',
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
          ),
        ],
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder - you would use flutter_svg here
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getIconData(),
                size: 16,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    if (icon.contains('google')) return Icons.g_mobiledata;
    if (icon.contains('apple')) return Icons.apple;
    if (icon.contains('facebook')) return Icons.facebook;
    return Icons.login;
  }
}