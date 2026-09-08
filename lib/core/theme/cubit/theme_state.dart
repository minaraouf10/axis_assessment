import '../../../../core/utils/app_import.dart';

class ThemeState extends Equatable {
  const ThemeState({this.mode = ThemeMode.system});

  final ThemeMode mode;

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
