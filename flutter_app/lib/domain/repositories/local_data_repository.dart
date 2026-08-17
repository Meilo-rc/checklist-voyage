import '../models/app_snapshot.dart';

abstract interface class LocalDataRepository {
  Stream<AppSnapshot> watchSnapshot();

  Future<String> ensureInstallationId();

  Future<String> getInstallationId();
}
