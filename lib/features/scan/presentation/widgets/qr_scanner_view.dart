import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A thin wrapper over MobileScanner that emits a single QR result.
class QrScannerView extends StatefulWidget {
  /// Creates a [QrScannerView].
  const QrScannerView({required this.onQr, super.key});

  /// Called when a QR is detected (first hit only).
  final void Function(String value) onQr;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    autoStart: false,
  );

  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_fired) return;
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if (raw == null || raw.isEmpty) return;
            _fired = true;
            _controller.stop();
            widget.onQr(raw);
          },
        ),
        // Simple center scan window. We can style further later.
        IgnorePointer(
          child: Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
