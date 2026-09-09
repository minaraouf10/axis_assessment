import 'package:axis_assessment/app.dart';
import 'package:axis_assessment/core/core.dart';
import 'package:axis_assessment/core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const CurrencyExchangeApp());
}
