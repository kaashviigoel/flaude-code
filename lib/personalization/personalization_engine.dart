enum AppPersona { health, fitness, traveller, commuter }

class PersonalizationEngine {
  static AppPersona fromString(String? persona) {
    switch (persona?.toLowerCase()) {
      case 'fitness':
        return AppPersona.fitness;
      case 'travel':
      case 'traveller':
        return AppPersona.traveller;
      case 'commute':
      case 'commuter':
        return AppPersona.commuter;
      case 'health':
      default:
        return AppPersona.health;
    }
  }

  static String getPersonaBadge(AppPersona persona) {
    switch (persona) {
      case AppPersona.fitness:
        return 'FITNESS PROFILE';
      case AppPersona.traveller:
        return 'TRAVELLER PROFILE';
      case AppPersona.commuter:
        return 'COMMUTER PROFILE';
      case AppPersona.health:
        return 'HEALTH-CONSCIOUS PROFILE';
    }
  }

  static String getHeadline(AppPersona persona) {
    switch (persona) {
      case AppPersona.fitness:
        return 'Peak\nPerformance';
      case AppPersona.traveller:
        return 'Smooth\nJourney';
      case AppPersona.commuter:
        return 'Clear\nTransit';
      case AppPersona.health:
        return 'Breathe\nEasy';
    }
  }
}
