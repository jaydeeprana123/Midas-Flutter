import 'package:flutter/material.dart';
import 'package:midas/app/constants/app_assets.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_text_styles.dart';

class PoweredByLogo extends StatelessWidget {
  const PoweredByLogo({super.key, this.height = 44});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openSite();
      },
      child: Row(
        children: [
          Text(AppStrings.poweredBy, style: AppTextStyles.footer()),
          SizedBox(width: 4),
          SizedBox(
            height: height,
            width: height,
            child: Image.asset(
              AppAssets.poweredByLogo,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSite() async {
    final uri = Uri.parse(AppStrings.poweredByUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
