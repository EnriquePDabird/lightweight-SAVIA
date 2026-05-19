import 'package:flutter/material.dart';

import '../theme/savia_colors.dart';

/// Logo SAVIA (icono + nombre + tagline).
class SaviaLogo extends StatelessWidget {
  final double iconSize;
  final bool compact;

  const SaviaLogo({super.key, this.iconSize = 40, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_outlined, color: SaviaColors.primary, size: iconSize),
            const SizedBox(width: 8),
            Text(
              'Savia',
              style: TextStyle(
                fontSize: compact ? 28 : 36,
                fontWeight: FontWeight.w800,
                color: SaviaColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            'SOLUCIONES AMBIENTALES',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
              color: SaviaColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}

/// Etiqueta en mayúsculas sobre un campo (estilo mockup login).
class SaviaFieldLabel extends StatelessWidget {
  final String label;

  const SaviaFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

/// Botón principal naranja a ancho completo.
class SaviaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? trailingIcon;

  const SaviaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SaviaColors.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Tarjeta de sección con borde (formularios).
class SaviaSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const SaviaSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SaviaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SaviaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: SaviaColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// AppBar estándar SAVIA.
class SaviaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onProfileTap;

  const SaviaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final profileAction = Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: SaviaColors.surfaceElevated,
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: SaviaColors.textMuted,
            ),
          ),
        ),
      ),
    );

    return AppBar(
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Text(title),
      actions: actions ?? (onProfileTap != null ? [profileAction] : null),
    );
  }
}

enum SaviaNavTab { campanas, receptores }

/// Barra inferior de navegación (mockup).
class SaviaBottomNav extends StatelessWidget {
  final SaviaNavTab current;
  final ValueChanged<SaviaNavTab>? onTap;

  const SaviaBottomNav({
    super.key,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SaviaColors.bottomNavBg,
        border: Border(top: BorderSide(color: SaviaColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(context, SaviaNavTab.campanas, Icons.campaign_outlined, 'Campañas'),
              _item(context, SaviaNavTab.receptores, Icons.people_outline, 'Receptores'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, SaviaNavTab tab, IconData icon, String label) {
    final selected = current == tab;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () => onTap!(tab) : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? SaviaColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? SaviaColors.onPrimary : SaviaColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? SaviaColors.onPrimary : SaviaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scaffold con barra inferior opcional.
class SaviaScaffold extends StatelessWidget {
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final SaviaNavTab? bottomNavTab;
  final ValueChanged<SaviaNavTab>? onBottomNavTap;
  final bool showBack;

  const SaviaScaffold({
    super.key,
    this.title,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavTab,
    this.onBottomNavTap,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaviaColors.background,
      appBar: appBar ??
          (title != null
              ? SaviaAppBar(title: title!, showBack: showBack)
              : null),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavTab != null
          ? SaviaBottomNav(current: bottomNavTab!, onTap: onBottomNavTap)
          : null,
    );
  }
}
