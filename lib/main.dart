import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/app/app.dart';

/// Entry point for the Kasseta application.
///
/// Phase 3: now mounts Riverpod + Router via KassetaApp.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KassetaApp()));
}
