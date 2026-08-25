import 'package:flutter/material.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class AlertCardWidget extends StatelessWidget {
  final WeatherAlert alert;
  final String locationName;
  final String? timeLabel;

  const AlertCardWidget({
    super.key,
    required this.alert,
    this.locationName = 'Bengaluru',
    this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final severity = (alert.severity ?? 'advisory').toLowerCase();

    Color severityColor;
    IconData severityIcon;
    String badgeText;

    if (severity == 'critical') {
      severityColor = const Color(0xFFFF4B4B); // Vibrant Red
      severityIcon = Icons.warning_amber_rounded;
      badgeText = 'CRITICAL';
    } else if (severity == 'warning') {
      severityColor = const Color(0xFFFFCD00); // Vibrant Gold Yellow
      severityIcon = Icons.bolt_rounded;
      badgeText = 'WARNING';
    } else {
      severityColor = const Color(0xFF4AC7F0); // Light Cyan
      severityIcon = Icons.air_rounded;
      badgeText = 'ADVISORY';
    }

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Badge & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    severityIcon,
                    color: severityColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badgeText,
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              Text(
                timeLabel ?? _formatTime(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Alert Title
          Text(
            alert.event ?? 'Weather Alert',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 4),

          // Location Subtitle
          Text(
            locationName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          // Alert Description
          Text(
            alert.description ?? 'No additional details provided.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    if (alert.startsAt != null) {
      final hour = alert.startsAt!.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12 $ampm';
    }
    return 'ONGOING';
  }
}
