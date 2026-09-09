import 'package:axis_assessment/core/core.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading exchange rates...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
