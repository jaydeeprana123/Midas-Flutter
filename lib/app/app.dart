import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/bindings/initial_binding.dart';
import 'package:midas/app/routes/app_pages.dart';
import 'package:midas/app/routes/app_routes.dart';
import 'package:midas/app/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Midas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
