import 'package:flutter/material.dart';
import 'package:midas/app/constants/app_strings.dart';
import 'package:midas/app/routes/app_routes.dart';

enum AppMenuSection { assets, equipments }

class AppMenuItem {
  const AppMenuItem({
    required this.permissionLabel,
    required this.title,
    required this.icon,
    required this.section,
    this.showInDrawer = true,
    this.showOnHome = true,
    this.route,
  });

  final String permissionLabel;
  final String title;
  final IconData icon;
  final AppMenuSection section;
  final bool showInDrawer;
  final bool showOnHome;

  /// Named route to open when this menu item is tapped. `null` means the
  /// feature is not wired up yet.
  final String? route;
}

class AppMenuConfig {
  AppMenuConfig._();

  static const dashboard = AppMenuItem(
    permissionLabel: '__dashboard__',
    title: AppStrings.dashboard,
    icon: Icons.home,
    section: AppMenuSection.assets,
    showOnHome: false,
  );

  static const items = <AppMenuItem>[
    AppMenuItem(
      permissionLabel: 'Assign QR Asset',
      title: AppStrings.assignAssetTag,
      icon: Icons.qr_code_scanner,
      section: AppMenuSection.assets,
      route: AppRoutes.assignAssetTag,
    ),
    AppMenuItem(
      permissionLabel: 'DeAssign QR Asset',
      title: AppStrings.deAssignAssetTag,
      icon: Icons.qr_code_2,
      section: AppMenuSection.assets,
      route: AppRoutes.deAssignAssetTag,
    ),
    AppMenuItem(
      permissionLabel: 'Assign Location',
      title: AppStrings.assignLocationTag,
      icon: Icons.map,
      section: AppMenuSection.assets,
      route: AppRoutes.assignLocationTag,
    ),
    AppMenuItem(
      permissionLabel: 'Change Location By Location',
      title: AppStrings.changeLocationByLocation,
      icon: Icons.sync,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Change Location By Asset',
      title: AppStrings.changeLocationByAsset,
      icon: Icons.sync_problem,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Identify Asset',
      title: AppStrings.identifyAsset,
      icon: Icons.search,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Search Asset',
      title: AppStrings.searchAsset,
      icon: Icons.add_location,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Audit Assets',
      title: AppStrings.auditAssets,
      icon: Icons.library_books,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Link Equipment Tag',
      title: AppStrings.linkEquipmentTag,
      icon: Icons.link,
      section: AppMenuSection.equipments,
    ),
    AppMenuItem(
      permissionLabel: 'Delink Equipment Tag',
      title: AppStrings.delinkEquipmentTag,
      icon: Icons.link_off,
      section: AppMenuSection.equipments,
    ),
    AppMenuItem(
      permissionLabel: 'Identify Equipment',
      title: AppStrings.identifyEquipment,
      icon: Icons.badge,
      section: AppMenuSection.equipments,
    ),
  ];

  static List<AppMenuItem> visibleItems(
    Set<String> permissionLabels, {
    AppMenuSection? section,
    bool drawerOnly = false,
    bool homeOnly = false,
  }) {
    return items.where((item) {
      if (section != null && item.section != section) return false;
      if (drawerOnly && !item.showInDrawer) return false;
      if (homeOnly && !item.showOnHome) return false;
      return permissionLabels.contains(_normalize(item.permissionLabel));
    }).toList();
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}
