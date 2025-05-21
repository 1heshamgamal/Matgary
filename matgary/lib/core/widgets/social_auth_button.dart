import 'package:flutter/material.dart';

/// Social authentication button widget
class SocialAuthButton extends StatelessWidget {
  /// Icon path
  final String icon;
  
  /// On pressed callback
  final VoidCallback? onPressed;
  
  /// Constructor
  const SocialAuthButton({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported_outlined,
                size: 24,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              );
            },
          ),
        ),
      ),
    );
  }
}