import 'package:flutter/material.dart';

/// The main screen for scanning QR codes.
///
/// Currently a placeholder; in Phase 4 we will wire up the camera
/// and QR reader here.
class ScanScreen extends StatelessWidget {
  /// Creates a new [ScanScreen] widget.
  const ScanScreen({super.key});

  /// Builds the [ScanScreen] widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasseta — Scan')),
      body: const Center(
        child: Text('Scan screen ready. (Camera coming next)'),
      ),
    );
  }
}
