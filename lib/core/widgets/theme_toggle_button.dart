import 'package:axis_assessment/core/core.dart';
import 'package:axis_assessment/core/theme/cubit/theme_cubit.dart';
import 'package:axis_assessment/core/theme/cubit/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final icon = switch (state.mode) {
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
          ThemeMode.system => Icons.brightness_auto_outlined,
        };
        return IconButton(
          tooltip: 'Theme: ${state.mode.name}',
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: Icon(icon),
        );
      },
    );
  }
}
