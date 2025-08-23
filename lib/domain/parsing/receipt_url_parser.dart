/// Tokens extracted from a SUF verification URL.
class ReceiptUrlTokens {
  /// Creates [ReceiptUrlTokens].
  const ReceiptUrlTokens({required this.vl});

  /// The `vl` payload parameter (URL‑decoded).
  final String vl;
}

/// Parses SUF verification URLs and extracts tokens.
class ReceiptUrlParser {
  /// Parse a [Uri] and return [ReceiptUrlTokens] if valid.
  ReceiptUrlTokens? parse(Uri uri) {
    final host = uri.host.toLowerCase();
    final allowed = <String>{
      'suf.purs.gov.rs',
      'tap.suf.purs.gov.rs',
      // add sandbox domains if needed
    };
    if (!allowed.contains(host)) return null;

    final vl = uri.queryParameters['vl'];
    if (vl == null || vl.isEmpty) return null;

    // Uri decode once (avoid double‑decode).
    final decoded = Uri.decodeComponent(vl);
    return ReceiptUrlTokens(vl: decoded);
  }
}
