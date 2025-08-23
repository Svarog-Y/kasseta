import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/services/permissions_service.dart';

/// Global provider that exposes the concrete [PermissionsService].
///
/// In tests we override this with fakes to simulate different OS states.
final permissionsServiceProvider = Provider<PermissionsService>(
  (ref) => PermissionsServiceImpl(),
);
