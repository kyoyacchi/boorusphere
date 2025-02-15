import 'package:boorusphere/data/repository/version/entity/app_version.dart';

abstract class VersionRepo {
  AppVersion get current;
  Future<AppVersion> fetch();
}
