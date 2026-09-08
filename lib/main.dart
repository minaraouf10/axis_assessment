import '../../../../core/utils/app_import.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const CurrencyExchangeApp());
}
