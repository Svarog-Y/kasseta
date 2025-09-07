import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Minimal landing-page parser (token + invoice).
///
/// Responsibilities:
///  • Extract token from inline script: `viewModel.Token('uuid')`.
///  • Extract invoice number:
///    – Prefer DOM span `#invoiceNumberLabel`.
///    – Fallback to script: `viewModel.InvoiceNumber('value')`.
///  • Validate formats strictly and throw `FormatException` on failure.
///
/// Notes:
///  • Parser does not execute JavaScript; it inspects HTML/script text only.
///  • Kept small so we can expand in later steps without breaking callers.
class ReceiptLandingParser {
  /// Extracts both invoice number and token from [html].
  ///
  /// Throws [FormatException] if either value is missing or malformed.
  LandingTokens parse(String html) {
    final invoice = extractInvoice(html);
    final token = extractToken(html);
    return LandingTokens(invoiceNumber: invoice, token: token);
  }

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

  /// Extracts the invoice number from the landing page [html].
  ///
  /// Prefers DOM `#invoiceNumberLabel`, falls back to inline script.
  /// Throws [FormatException] if not found or malformed.
  String extractInvoice(String html) {
    final doc = html_parser.parse(html);
    final viaDom = _extractInvoiceFromDom(doc);
    final invoice = viaDom ?? _extractInvoiceFromJs(doc);
    if (invoice == null) {
      throw const FormatException('Invoice number not found.');
    }
    if (!_isValidInvoice(invoice)) {
      throw FormatException('Invalid invoice format: $invoice');
    }
    return invoice;
  }

  // -------- Token internals --------

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

  // -------- Invoice internals --------

  String? _extractInvoiceFromDom(dom.Document doc) {
    final el = doc.querySelector('#invoiceNumberLabel');
    if (el == null) return null;
    final norm = el.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return norm.isEmpty ? null : norm;
  }

  String? _extractInvoiceFromJs(dom.Document doc) {
    final scripts = doc.querySelectorAll('script');
    final r = RegExp(
      "viewModel\\.InvoiceNumber\\(\\s*['\"]([A-Z0-9\\-]{10,})['\"]\\s*\\)",
    );
    for (final s in scripts) {
      final t = s.text;
      final m = r.firstMatch(t);
      if (m != null) return m.group(1);
    }
    return null;
  }

  bool _isValidInvoice(String v) {
    // Example: K8UBE2HN-K8UBE2HN-111060
    final rx = RegExp(r'^[A-Z0-9]{8}-[A-Z0-9]{8}-\d{5,}$');
    return rx.hasMatch(v);
  }
}

/// Value object holding the two tokens required by SUF items API.
class LandingTokens {
  /// Creates a new [LandingTokens].
  const LandingTokens({
    required this.invoiceNumber,
    required this.token,
  });

  /// The invoice number string from DOM or script.
  final String invoiceNumber;

  /// The UUID-like token string from inline script.
  final String token;
}
