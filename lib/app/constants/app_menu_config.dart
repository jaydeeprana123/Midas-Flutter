import 'package:flutter/material.dart';

enum AppMenuSection { assets, equipments }

class AppMenuItem {
  const AppMenuItem({
    required this.permissionLabel,
    required this.title,
    required this.icon,
    required this.section,
    this.showInDrawer = true,
    this.showOnHome = true,
  });

  final String permissionLabel;
  final String title;
  final IconData icon;
  final AppMenuSection section;
  final bool showInDrawer;
  final bool showOnHome;
}

class AppMenuConfig {
  AppMenuConfig._();

  static const dashboard = AppMenuItem(
    permissionLabel: '__dashboard__',
    title: 'Dashboard',
    icon: Icons.home,
    section: AppMenuSection.assets,
    showOnHome: false,
  );

  static const items = <AppMenuItem>[
    AppMenuItem(
      permissionLabel: 'Assign QR Asset',
      title: 'Assign Asset Tag',
      icon: Icons.qr_code_scanner,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'DeAssign QR Asset',
      title: 'DeAssign Asset Tag',
      icon: Icons.qr_code_2,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Assign Location',
      title: 'Assign Location Tag',
      icon: Icons.map,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Change Location By Location',
      title: 'Change Location By Location',
      icon: Icons.sync,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Change Location By Asset',
      title: 'Change Location By Asset',
      icon: Icons.sync_problem,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Identify Asset',
      title: 'Identify Asset',
      icon: Icons.search,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Search Asset',
      title: 'Search Asset',
      icon: Icons.add_location,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Audit Assets',
      title: 'Audit Assets',
      icon: Icons.library_books,
      section: AppMenuSection.assets,
    ),
    AppMenuItem(
      permissionLabel: 'Link Equipment Tag',
      title: 'Link Equipment Tag',
      icon: Icons.link,
      section: AppMenuSection.equipments,
    ),
    AppMenuItem(
      permissionLabel: 'Delink Equipment Tag',
      title: 'Delink Equipment Tag',
      icon: Icons.link_off,
      section: AppMenuSection.equipments,
    ),
    AppMenuItem(
      permissionLabel: 'Identify Equipment',
      title: 'Identify Equipment',
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
