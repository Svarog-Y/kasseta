import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/features/scan/application/scan_controller.dart';
import 'package:kasseta/features/scan/presentation/widgets/qr_scanner_view.dart';

/// The main screen for scanning QR codes and saving landing HTML.
///
/// Flow:
///  - Check permission on init.
///  - When ready, show the QR scanner.
///  - On QR, controller parses and starts saving landing HTML.
///  - When saved, show a Share button to export the .html file.
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
          ScanIdle() => const _CenteredText('Preparing…'),
          ScanNeedsPermission() => _NeedsPermission(ref: ref),
          ScanRequestingPermission() =>
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          ScanPermissionPermanentlyDenied() => const _CenteredText(
              'Permission permanently denied.\n'
              'Open system settings to enable camera.',
            ),
          ScanReady() => SizedBox.expand(
              child: QrScannerView(
                onQr: (value) {
                  ref.read(scanControllerProvider.notifier).onQrFound(value);
                },
              ),
            ),
          // Brief intermediate state; shown before saving starts.
          ScanFound(:final uri) => _Found(uri: uri),
          // Show progress while saving the landing HTML file.
          ScanSavingHtml(:final uri) => _Saving(uri: uri),
          // Show result + Share action.
          ScanSavedHtml(qrUri: final qr, fileUri: final file) =>
            _Saved(qrUri: qr, fileUri: file, ref: ref),
          ScanError(:final message) => _CenteredText('Error: $message'),
        },
      ),
    );
  }
}

/// Simple centered text widget to keep layout tidy.
class _CenteredText extends StatelessWidget {
  const _CenteredText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}

class _NeedsPermission extends StatelessWidget {
  const _NeedsPermission({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Camera permission required.'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            ref.read(scanControllerProvider.notifier).requestPermission();
          },
          child: const Text('Grant camera permission'),
        ),
      ],
    );
  }
}

class _Found extends StatelessWidget {
  const _Found({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      title: 'QR captured. Preparing to save HTML…',
      subtitle: uri.toString(),
      showProgress: true,
    );
  }
}

class _Saving extends StatelessWidget {
  const _Saving({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      title: 'Saving landing HTML…',
      subtitle: uri.toString(),
      showProgress: true,
    );
  }
}

class _Saved extends StatelessWidget {
  const _Saved({
    required this.qrUri,
    required this.fileUri,
    required this.ref,
  });

  final Uri qrUri;
  final Uri fileUri;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      title: 'Landing HTML saved.',
      subtitle: 'File: ${fileUri.toFilePath()}',
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await ref
                .read(scanControllerProvider.notifier)
                .shareSavedHtml(fileUri);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share dialog opened')),
              );
            }
          },
          icon: const Icon(Icons.share),
          label: const Text('Share HTML'),
        ),
      ],
    );
  }
}

/// Reusable card-like status presenter to keep text within 80 cols.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    this.subtitle,
    this.showProgress = false,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool showProgress;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (showProgress) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (actions != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
