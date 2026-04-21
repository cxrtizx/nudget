import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/app.dart';

/// Application entry point.
///
/// [ProviderScope] is the root of the Riverpod provider tree. All providers
/// and their overrides must live inside this scope.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: NudgetApp(),
    ),
  );
}
