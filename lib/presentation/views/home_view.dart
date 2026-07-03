import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas/app/constants/app_assets.dart';
import 'package:midas/app/theme/app_text_styles.dart';
import 'package:midas/app/theme/app_theme.dart';
import 'package:midas/presentation/controllers/home_controller.dart';
import 'package:midas/presentation/widgets/midas_toolbar_logo.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final orgLabel = (Get.arguments?['orgLabel'] ?? '').toString();
    final version = (Get.arguments?['version'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
        title: const MidasToolbarLogo(height: 36),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppTheme.primary,
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Image.asset(AppAssets.splashLogo, width: 44, height: 44),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          orgLabel.isEmpty ? 'GSSPL' : orgLabel,
                          style: AppTextStyles.drawerHeader(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _DrawerItem(
                  icon: Icons.home,
                  label: 'Dashboard',
                ),
                ...controller.drawerMenuItems.map(
                  (item) => _DrawerItem(icon: item.icon, label: item.title),
                ),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.onLogoutTap();
                  },
                ),
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Version ${version.isEmpty ? 'N/A' : version}',
                      style: AppTextStyles.version(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(
        () {
          final currentItems = controller.selectedTab.value == 0
              ? controller.assetMenuItems
              : controller.equipmentMenuItems;

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                child: Column(
                  children: [
                    Text(
                      controller.selectedTab.value == 0
                          ? 'Asset Tracking and Management\nSystem'
                          : 'Equipment Maintenance Management\nSystem',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('User :', style: AppTextStyles.userLabel()),
                          Flexible(
                            child: Text(
                              orgLabel.isEmpty ? 'GSSPL' : orgLabel,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.userValue(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.showAssetsTab || controller.showEquipmentsTab)
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      if (controller.showAssetsTab)
                        _TabHeader(
                          text: 'ASSETS',
                          selected: controller.selectedTab.value == 0,
                          onTap: () => controller.onTabChanged(0),
                        ),
                      if (controller.showEquipmentsTab)
                        _TabHeader(
                          text: 'EQUIPMENTS',
                          selected: controller.selectedTab.value == 1,
                          onTap: () => controller.onTabChanged(1),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: currentItems.isEmpty
                    ? Center(
                        child: Text(
                          'No modules available for your account.',
                          style: AppTextStyles.body(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          children: currentItems
                              .map(
                                (item) => _ActionCard(
                                  icon: item.icon,
                                  title: item.title,
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppTheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.tabLabel(
              color: selected ? AppTheme.primary : Colors.black,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: AppTextStyles.drawerItem()),
      onTap: onTap,
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle(),
          ),
        ],
      ),
    );
  }
}
