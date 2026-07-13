import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WeddingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  const WeddingAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceBright.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.menu, color: AppColors.primary),
            ),
      title: Text(
        title ?? 'Sonia & Aimé',
        style: const TextStyle(
          fontFamily: 'NotoSerif',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
      actions: actions ??
          [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.favorite, color: AppColors.primary),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
