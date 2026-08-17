/// Contrat de préparation uniquement. Aucun appel réseau n'est effectué au lot 3.
abstract final class PocketBaseV1Contract {
  static const baseUrl = 'https://psyco.fly.dev';

  static const libraryCollection = 'cv1_libraries';
  static const documentCollection = 'cv1_documents';
  static const operationCollection = 'cv1_operations';
  static const deviceCollection = 'cv1_devices';

  /// La collection historique est volontairement absente des collections V1.
  static const historicalReadOnlyCollection = 'travel_checklists';
}
