enum AppPersona {
  health,
  fitness,
  beach,
  traveller,
  family,
  agriculture,
  commuter,
  events,
}

class PersonalizationEngine {
  static AppPersona fromString(String? persona) {
    switch (persona?.trim().toLowerCase()) {
      case 'health':
        return AppPersona.health;

      case 'fitness':
        return AppPersona.fitness;

      case 'beach':
      case 'beach & surf':
      case 'beach_surf':
        return AppPersona.beach;

      case 'travel':
      case 'traveller':
      case 'traveler':
        return AppPersona.traveller;

      case 'family':
        return AppPersona.family;

      case 'agriculture':
        return AppPersona.agriculture;

      case 'commute':
      case 'commuter':
        return AppPersona.commuter;

      case 'events':
      case 'event':
        return AppPersona.events;

      default:
        return AppPersona.health;
    }
  }

  static String toBackendString(AppPersona persona) {
    switch (persona) {
      case AppPersona.health:
        return 'health';

      case AppPersona.fitness:
        return 'fitness';

      case AppPersona.beach:
        return 'beach';

      case AppPersona.traveller:
        return 'traveller';

      case AppPersona.family:
        return 'family';

      case AppPersona.agriculture:
        return 'agriculture';

      case AppPersona.commuter:
        return 'commuter';

      case AppPersona.events:
        return 'events';
    }
  }

  static String getPersonaBadge(AppPersona persona) {
    switch (persona) {
      case AppPersona.health:
        return 'HEALTH PROFILE';

      case AppPersona.fitness:
        return 'FITNESS PROFILE';

      case AppPersona.beach:
        return 'BEACH & SURF PROFILE';

      case AppPersona.traveller:
        return 'TRAVELLER PROFILE';

      case AppPersona.family:
        return 'FAMILY PROFILE';

      case AppPersona.agriculture:
        return 'AGRICULTURE PROFILE';

      case AppPersona.commuter:
        return 'COMMUTER PROFILE';

      case AppPersona.events:
        return 'EVENTS PROFILE';
    }
  }

  static String getHeadline(AppPersona persona) {
    switch (persona) {
      case AppPersona.health:
        return 'Breathe\nEasy';

      case AppPersona.fitness:
        return 'Peak\nPerformance';

      case AppPersona.beach:
        return 'Chase\nThe Waves';

      case AppPersona.traveller:
        return 'Smooth\nJourney';

      case AppPersona.family:
        return 'Plan\nTogether';

      case AppPersona.agriculture:
        return 'Grow\nSmarter';

      case AppPersona.commuter:
        return 'Clear\nTransit';

      case AppPersona.events:
        return 'Perfect\nTiming';
    }
  }

  static String getDescription(AppPersona persona) {
    switch (persona) {
      case AppPersona.health:
        return 'Weather insights focused on your wellbeing.';

      case AppPersona.fitness:
        return 'Plan your workouts around the weather.';

      case AppPersona.beach:
        return 'Sea and weather conditions for your next adventure.';

      case AppPersona.traveller:
        return 'Weather insights for a smoother journey.';

      case AppPersona.family:
        return 'Plan your family day around the weather.';

      case AppPersona.agriculture:
        return 'Weather insights for smarter growing and planning.';

      case AppPersona.commuter:
        return 'Stay ahead of weather on your daily commute.';

      case AppPersona.events:
        return 'Plan the perfect outdoor event around the weather.';
    }
  }

  static String getIcon(AppPersona persona) {
    switch (persona) {
      case AppPersona.health:
        return '♥';

      case AppPersona.fitness:
        return '⚡';

      case AppPersona.beach:
        return '≈';

      case AppPersona.traveller:
        return '✈';

      case AppPersona.family:
        return '♧';

      case AppPersona.agriculture:
        return '♣';

      case AppPersona.commuter:
        return '⌁';

      case AppPersona.events:
        return '★';
    }
  }
}
