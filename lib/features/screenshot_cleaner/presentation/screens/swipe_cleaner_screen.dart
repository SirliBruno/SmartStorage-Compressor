import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';

/// Screenshot Cleaner Screen - Ready for Sprint 06 swipe deck implementation.
class SwipeCleanerScreen extends StatelessWidget {
  const SwipeCleanerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.placeholderCleanerTitle),
      ),
      body: SafeArea(
        child: EmptyStateView(
          icon: Icons.swipe_outlined,
          title: l10n.placeholderCleanerTitle,
          subtitle: l10n.placeholderCleanerDesc,
        ),
      ),
    );
  }
}
