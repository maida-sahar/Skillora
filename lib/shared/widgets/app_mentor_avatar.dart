import 'dart:convert';
import 'package:flutter/material.dart';

class AppMentorAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color backgroundColor;
  final IconData fallbackIcon;

  const AppMentorAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24.0,
    this.backgroundColor = Colors.indigo,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(fallbackIcon, color: Colors.white, size: radius * 0.9),
      );
    }

    if (url.startsWith('data:image')) {
      try {
        final base64Content = url.split(',').last;
        final bytes = base64Decode(base64Content);
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: Icon(fallbackIcon, color: Colors.white, size: radius * 0.9),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: backgroundColor,
            width: radius * 2,
            height: radius * 2,
            alignment: Alignment.center,
            child: Icon(fallbackIcon, color: Colors.white, size: radius * 0.9),
          ),
        ),
      ),
    );
  }
}
