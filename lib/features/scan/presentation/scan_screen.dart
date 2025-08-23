import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/features/scan/application/scan_controller.dart';

/// The main screen for scanning QR codes.
///
/// Currently a placeholder; in Phase 4 we will wire up the camera
/// and QR reader here.
class ScanScreen extends ConsumerStatefulWidget {
  /// Creates a [ScanScreen].
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off permission check.
    Future.microtask(() async {
      await ref.read(scanControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kasseta — Scan')),
      body: Center(
        child: switch (state) {
          ScanIdle() => const Text('Preparing…'),
          ScanNeedsPermission() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Camera permission required.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(
                      scanControllerProvider.notifier
                    ).requestPermission();
                  },
                  child: const Text('Grant camera permission'),
                ),
              ],
            ),
          ScanRequestingPermission() => const CircularProgressIndicator(),
          ScanPermissionPermanentlyDenied() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Permission permanently denied.\n'
                  'Open system settings to enable camera.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('OK'),
                ),
              ],
            ),
          ScanReady() => const Text('Permission OK. (Scanner coming next)'),
          ScanError(:final message) => Text('Error: $message'),
        },
      ),
    );
  }
}
