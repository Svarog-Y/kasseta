import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/domain/parsing/receipt_url_parser.dart';
import 'package:kasseta/services/permissions_service.dart';

/// Global provider that exposes the concrete [PermissionsService].
///
/// In tests we override this with fakes to simulate different OS states.
final permissionsServiceProvider = Provider<PermissionsService>(
  (ref) => PermissionsServiceImpl(),
);

/// Global provider for the SUF receipt URL parser.
final receiptUrlParserProvider = Provider<ReceiptUrlParser>(
  (ref) => ReceiptUrlParser(),
);
