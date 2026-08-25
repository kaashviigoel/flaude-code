import 'package:flutter/material.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class AqiCardWidget extends StatelessWidget {
  final String location;
  final String condition;
  final int? aqi;
  final String aqiStatus;

  const AqiCardWidget({
    super.key,
    required this.location,
    this.condition = 'Air quality data unavailable',
    this.aqi,
    this.aqiStatus = 'Unavailable',
  });

  @override
  Widget build(BuildContext context) {
    final hasAqi = aqi != null;
    final safeAqi = (aqi ?? 0).clamp(0, 300).toDouble();

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                hasAqi ? '$aqi' : '—',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF68B8B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF55C470),
                      Color(0xFFE8C654),
                      Color(0xFFF68B8B),
                      Color(0xFFB56BF5),
                    ],
                  ),
                ),
              ),

              if (hasAqi)
                FractionallySizedBox(
                  widthFactor: (safeAqi / 300.0).clamp(0.05, 0.95),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

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
  final String level;
  final double? tree;
  final double? grass;
  final double? weed;

  const PollenCardWidget({
    super.key,
    this.level = 'Unavailable',
    this.tree,
    this.grass,
    this.weed,
  });

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

          Text(
            level,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFCD00),
            ),
          ),

          const SizedBox(height: 14),

          _pollenRow('Tree', tree, const Color(0xFFFFCD00)),

          const SizedBox(height: 6),

          _pollenRow('Grass', grass, const Color(0xFF6B82A0)),

          const SizedBox(height: 6),

          _pollenRow('Weed', weed, const Color(0xFF4E637F)),
        ],
      ),
    );
  }

  Widget _pollenRow(String label, double? value, Color color) {
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
              value: value,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                value == null ? Colors.white24 : color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UvCardWidget extends StatelessWidget {
  final double? uvIndex;

  const UvCardWidget({super.key, this.uvIndex});

  String _label(double value) {
    if (value < 3) return 'Low';
    if (value < 6) return 'Moderate';
    if (value < 8) return 'High';
    if (value < 11) return 'Very High';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    final value = uvIndex;

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
                value == null ? '—' : value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                value == null ? 'Unavailable' : _label(value),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFCD00),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value == null ? 'UV data unavailable' : 'Current UV exposure',
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

class HumidityCardWidget extends StatelessWidget {
  final double? humidity;

  const HumidityCardWidget({super.key, this.humidity});

  String _label(double value) {
    if (value < 30) return 'Dry';
    if (value <= 60) return 'Comfortable';
    if (value <= 75) return 'Humid';
    return 'Very Humid';
  }

  @override
  Widget build(BuildContext context) {
    final value = humidity;

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
            value == null ? '—' : '${value.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value == null ? 'Humidity data unavailable' : _label(value),
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
