import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kasseta/features/scan/presentation/scan_screen.dart';

/// Provides the app-wide router instance.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
    ],
  );
});
