// lib/main.dart

import 'package:flutter/material.dart';

/// Entry point for the Kasseta application.
///
/// Keeps the app minimal for Phase 2 while we set up architecture
/// and testing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KassetaApp());
}

/// Root widget for the Kasseta app.
///
/// For Phase 2 this is a simple placeholder; in Phase 3 we'll wire
/// routing, state management, and feature scaffolding.
class KassetaApp extends StatelessWidget {
  /// Creates the root Kasseta application widget.
  const KassetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Required named parameters are already positioned before optional ones,
    // complying with `always_put_required_named_parameters_first`.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasseta',
      home: _Phase2Placeholder(),
    );
  }
}

/// Temporary placeholder screen for Phase 2.
///
/// This will be replaced in Phase 3 by a proper router + screen structure.
class _Phase2Placeholder extends StatelessWidget {
  const _Phase2Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Kasseta — Phase 2 OK'),
      ),
    );
  }
}
