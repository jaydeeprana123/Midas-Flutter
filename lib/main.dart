import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:midas/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const App());
}
