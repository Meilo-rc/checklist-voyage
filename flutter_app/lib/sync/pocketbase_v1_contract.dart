/// Contrat PocketBase V1. Les tests peuvent toujours injecter une autre URL.
abstract final class PocketBaseV1Contract {
  static const baseUrl = 'https://checklist-voyage-pb.fly.dev';

  static const libraryCollection = 'cv1_libraries';
  static const entityCollection = 'cv1_library_entities';
  static const operationCollection = 'cv1_operations';
  static const deviceCollection = 'cv1_devices';
  static const pushPath = '/api/cv1/sync/push';
  static const pullPath = '/api/cv1/sync/pull';
  static const documentSharePath = '/api/cv1/documents/share';
  static const documentJoinPath = '/api/cv1/documents/join';
  static const documentPushPath = '/api/cv1/documents/push';
  static const documentPullPath = '/api/cv1/documents/pull';

  /// La collection historique est volontairement absente des collections V1.
  static const historicalCollectionForbidden = 'travel_checklists';
}
