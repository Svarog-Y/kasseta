import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Minimal landing-page parser (token only for this step).
///
/// This step extracts the token from inline script:
///   viewModel.Token(`uuid-text`)
///
/// Next steps will add invoice extraction and a combined result type.
class ReceiptLandingParser {
  /// Extracts the token from the provided landing page [html].
  ///
  /// Throws [FormatException] if the token is not found or malformed.
  String extractToken(String html) {
    final doc = html_parser.parse(html);
    final token = _extractTokenFromJs(doc);
    if (token == null) {
      throw const FormatException('Token not found in script.');
    }
    if (!_isValidToken(token)) {
      throw FormatException('Invalid token format: $token');
    }
    return token;
    }

  String? _extractTokenFromJs(dom.Document doc) {
    final scripts = doc.querySelectorAll('script');
    final r = RegExp(
      "viewModel\\.Token\\(\\s*['\"]([0-9a-fA-F\\-]{36})['\"]\\s*\\)",
    );
    for (final s in scripts) {
      final t = s.text;
      final m = r.firstMatch(t);
      if (m != null) return m.group(1);
    }
    return null;
  }

  bool _isValidToken(String v) {
    // UUID-like 36 chars with hyphens.
    final rx = RegExp(
      '^[0-9a-fA-F]{8}-'
      '[0-9a-fA-F]{4}-'
      '[0-9a-fA-F]{4}-'
      '[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{12}$',
    );
    return rx.hasMatch(v);
  }
}
