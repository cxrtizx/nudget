import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileNotifier extends AsyncNotifier<String> {
  static const _key = 'user_name';

  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name.trim());
    state = AsyncData(name.trim());
  }
}

final userNameProvider =
    AsyncNotifierProvider<UserProfileNotifier, String>(
  UserProfileNotifier.new,
);
