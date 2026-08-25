import 'package:flutter/material.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class AqiCardWidget extends StatelessWidget {
  final String location;
  final String condition;
  final int aqi;
  final String aqiStatus;

  const AqiCardWidget({
    super.key,
    this.location = 'San Francisco',
    this.condition = 'Partly Cloudy • 68°F',
    this.aqi = 112,
    this.aqiStatus = 'Unhealthy for Sensitive Groups',
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location & Subtitle
          Text(
            location,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            condition,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 24),

          // AQI Label and Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'AIR QUALITY INDEX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '$aqi',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF68B8B), // Coral/Amber tone
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AQI Spectrum Gradient Bar
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF55C470), // Good (Green)
                      Color(0xFFE8C654), // Moderate (Yellow)
                      Color(0xFFF68B8B), // Unhealthy sensitive (Coral)
                      Color(0xFFB56BF5), // Very unhealthy (Purple)
                    ],
                  ),
                ),
              ),

              // Pointer indicator
              FractionallySizedBox(
                widthFactor: (aqi / 300.0).clamp(0.05, 0.95),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Labels below bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Good',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Expanded(
                child: Text(
                  aqiStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF68B8B),
                  ),
                ),
              ),
              Text(
                'Hazardous',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PollenCardWidget extends StatelessWidget {
  const PollenCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.spa_outlined,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Pollen',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'High',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFCD00),
            ),
          ),
          const SizedBox(height: 14),
          _buildPollenRow('Tree', 0.85, const Color(0xFFFFCD00)),
          const SizedBox(height: 6),
          _buildPollenRow('Grass', 0.40, const Color(0xFF6B82A0)),
          const SizedBox(height: 6),
          _buildPollenRow('Weed', 0.25, const Color(0xFF4E637F)),
        ],
      ),
    );
  }

  Widget _buildPollenRow(String label, double factor, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: factor,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}

class UvCardWidget extends StatelessWidget {
  final double uvIndex;

  const UvCardWidget({super.key, this.uvIndex = 6.0});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xFFFFCD00),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'UV Index',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${uvIndex.toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'High',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFCD00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Protection needed until 4 PM',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class HumidityCardWidget extends StatelessWidget {
  final double humidity;

  const HumidityCardWidget({super.key, this.humidity = 42.0});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF4AC7F0),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Humidity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${humidity.toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Optimal for comfort',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
