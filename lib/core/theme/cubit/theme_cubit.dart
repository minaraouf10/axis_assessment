import 'package:axis_assessment/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._settingsBox) : super(const ThemeState()) {
    _restore();
  }

  static const String themeModeKey = 'theme_mode';

  final Box<dynamic> _settingsBox;

  void _restore() {
    final stored = _settingsBox.get(themeModeKey) as String?;
    if (stored == null) {
      return;
    }
    emit(ThemeState(mode: _fromName(stored)));
  }

  Future<void> toggle() async {
    final next = switch (state.mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    await _settingsBox.put(themeModeKey, mode.name);
    emit(ThemeState(mode: mode));
  }

  ThemeMode _fromName(String name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}
