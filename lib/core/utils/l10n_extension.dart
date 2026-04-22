import 'package:flutter/widgets.dart';
import 'package:nudget/l10n/app_localizations.dart';

/// Shorthand so widgets can write `context.l10n.someKey` instead of the
/// verbose `AppLocalizations.of(context)!.someKey`.
///
/// The `!` is safe here because [AppLocalizations] delegates are always
/// registered in [MaterialApp], so `of(context)` never returns null at
/// runtime inside the widget tree.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
