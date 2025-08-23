import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/app/router.dart';

/// Root Kasseta application widget wired with Riverpod and GoRouter.
class KassetaApp extends ConsumerWidget {
  /// Creates the root Kasseta application widget.
  const KassetaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Kasseta',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00A3A3),
      ),
    );
  }
}
