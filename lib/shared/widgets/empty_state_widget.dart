import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Master Reusable Empty State Widget for Skillora
/// Responsive, scalable across Mobile, Tablet, Desktop, and Web.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final String lottieAsset;
  final IconData fallbackIcon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double animationHeight;

  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    required this.lottieAsset,
    this.fallbackIcon = Icons.inbox_outlined,
    this.actionText,
    this.onActionPressed,
    this.animationHeight = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: animationHeight,
                child: Lottie.asset(
                  lottieAsset,
                  height: animationHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334B9C).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        fallbackIcon,
                        size: 48,
                        color: const Color(0xFF334B9C),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707E94),
                    height: 1.4,
                  ),
                ),
              ],
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334B9C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    actionText!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
