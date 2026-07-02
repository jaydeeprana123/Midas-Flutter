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
          child: Column(
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
                    Text('GSSPL', style: AppTextStyles.drawerHeader()),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...const [
                _DrawerItem(icon: Icons.home, label: 'Dashboard'),
                _DrawerItem(icon: Icons.qr_code_scanner, label: 'Assign Asset Tag'),
                _DrawerItem(icon: Icons.qr_code_2, label: 'DeAssign Asset Tag'),
                _DrawerItem(icon: Icons.map, label: 'Assign Location Tag'),
                _DrawerItem(icon: Icons.sync, label: 'Change Location By Location'),
                _DrawerItem(icon: Icons.sync_problem, label: 'Change Location By Asset'),
                _DrawerItem(icon: Icons.search, label: 'Identify Asset'),
                _DrawerItem(icon: Icons.add_location, label: 'Search Asset'),
                _DrawerItem(icon: Icons.library_books, label: 'Audit Assets'),
                _DrawerItem(icon: Icons.logout, label: 'Logout'),
              ],
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
      body: Obx(
        () => Column(
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('User :', style: AppTextStyles.userLabel()),
                        Text(
                          orgLabel.isEmpty ? 'GSSPL' : orgLabel,
                          style: AppTextStyles.userValue(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  _TabHeader(
                    text: 'ASSETS',
                    selected: controller.selectedTab.value == 0,
                    onTap: () => controller.onTabChanged(0),
                  ),
                  _TabHeader(
                    text: 'EQUIPMENTS',
                    selected: controller.selectedTab.value == 1,
                    onTap: () => controller.onTabChanged(1),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: controller.selectedTab.value == 0
                    ? const [
                        _ActionCard(icon: Icons.qr_code_scanner, title: 'Assign Asset Tag'),
                        _ActionCard(icon: Icons.qr_code_2, title: 'DeAssign Asset Tag'),
                        _ActionCard(icon: Icons.map, title: 'Assign Location Tag'),
                        _ActionCard(icon: Icons.sync, title: 'Change Location By Location'),
                        _ActionCard(icon: Icons.sync_problem, title: 'Change Location By Asset'),
                        _ActionCard(icon: Icons.search, title: 'Identify Asset'),
                        _ActionCard(icon: Icons.add_location, title: 'Search Asset'),
                        _ActionCard(icon: Icons.library_books, title: 'Audit Assets'),
                      ]
                    : const [
                        _ActionCard(icon: Icons.link, title: 'Link Equipment Tag'),
                        _ActionCard(icon: Icons.link_off, title: 'Delink Equipment Tag'),
                        _ActionCard(icon: Icons.badge, title: 'Identify Equipment'),
                      ],
              ),
            ),
          ),
          ],
        ),
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
              bottom: BorderSide(color: selected ? AppTheme.primary : Colors.transparent, width: 3),
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
  const _DrawerItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: AppTextStyles.drawerItem()),
      onTap: () {},
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
