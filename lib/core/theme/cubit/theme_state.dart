import 'package:axis_assessment/core/core.dart';

class ThemeState extends Equatable {
  const ThemeState({this.mode = ThemeMode.system});

  final ThemeMode mode;

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
