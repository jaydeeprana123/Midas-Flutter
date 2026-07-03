import 'package:flutter/material.dart';
import 'package:midas/app/constants/app_assets.dart';

class MidasToolbarLogo extends StatelessWidget {
  const MidasToolbarLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 4.2,
      child: Image.asset(
        AppAssets.toolbarLogo,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
