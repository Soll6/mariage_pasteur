import 'package:flutter/material.dart';

class DrawerOpener extends InheritedWidget {
  final VoidCallback openDrawer;

  const DrawerOpener({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  static DrawerOpener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrawerOpener>();
  }

  @override
  bool updateShouldNotify(DrawerOpener oldWidget) {
    return openDrawer != oldWidget.openDrawer;
  }
}
