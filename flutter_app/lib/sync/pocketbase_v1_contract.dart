/// Contrat de préparation uniquement. Aucun appel réseau n'est effectué au lot 3.
abstract final class PocketBaseV1Contract {
  static const baseUrl = 'https://psyco.fly.dev';

  static const libraryCollection = 'cv1_libraries';
  static const entityCollection = 'cv1_library_entities';
  static const operationCollection = 'cv1_operations';
  static const deviceCollection = 'cv1_devices';
  static const pushPath = '/api/cv1/sync/push';
  static const pullPath = '/api/cv1/sync/pull';

  /// La collection historique est volontairement absente des collections V1.
  static const historicalCollectionForbidden = 'travel_checklists';
}
