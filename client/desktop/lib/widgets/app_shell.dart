import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/pages/dashboard.dart';
import 'package:ebooking_desktop/pages/locations_page.dart';
import 'package:ebooking_desktop/pages/login.dart';
import 'package:ebooking_desktop/pages/manage_properties.dart';
import 'package:ebooking_desktop/pages/manage_users.dart';
import 'package:ebooking_desktop/pages/messenger_screen.dart';
import 'package:ebooking_desktop/pages/reference_data_page.dart';
import 'package:ebooking_desktop/pages/reports_page.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Odredišta bočne navigacije — 1:1 sa `eBooking Admin.dc.html`.
enum AdminSection {
  dashboard('Pregled'),
  properties('Smještaji'),
  users('Korisnici'),
  locations('Lokacije'),
  reference('Referentni podaci'),
  reports('Izvještaji'),
  messenger('Poruke');

  final String label;
  const AdminSection(this.label);
}

/// Glavni okvir administratorske aplikacije.
///
/// ZAMJENJUJE `widgets/drawer.dart`. Stari `CustomDrawer` je imao dva problema:
///  1. Svaka stavka je radila `Navigator.push`, pa se stack gomilao — nakon
///     desetak klikova "nazad" je vodio kroz cijelu historiju navigacije.
///  2. Bio je `Drawer` (hamburger) na desktopu, gdje ne postoji razlog da
///     navigacija bude skrivena — dizajn traži trajni sidebar od 240px.
///
/// Sada je jedan `IndexedStack`: sekcije se ne uništavaju pri prebacivanju,
/// pa se stanje pretrage/filtera zadržava, a `Navigator` stack ostaje prazan.
class AppShell extends StatefulWidget {
  final AdminSection initialSection;

  const AppShell({super.key, this.initialSection = AdminSection.dashboard});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AdminSection _section = widget.initialSection;

  static const _sidebarWidth = 240.0;

  IconData _iconFor(AdminSection section, {bool active = false}) {
    final style = active ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular;
    switch (section) {
      case AdminSection.dashboard:
        return PhosphorIcons.squaresFour(style);
      case AdminSection.properties:
        return PhosphorIcons.buildings(style);
      case AdminSection.users:
        return PhosphorIcons.users(style);
      case AdminSection.locations:
        return PhosphorIcons.mapPin(style);
      case AdminSection.reference:
        return PhosphorIcons.tag(style);
      case AdminSection.reports:
        return PhosphorIcons.chartBar(style);
      case AdminSection.messenger:
        return PhosphorIcons.chatCircle(style);
    }
  }

  Future<void> _logout() async {
    final confirmed = await nConfirm(
      context,
      title: 'Odjava',
      message: 'Želite li se odjaviti sa administratorskog naloga?',
      confirmLabel: 'Odjavi me',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    final auth = context.read<AuthProvider>();
    final messages = context.read<MessageProvider>();
    final profile = context.read<ProfileProvider>();
    final navigator = Navigator.of(context);

    await messages.stopSignalR();
    await auth.logout();
    profile.reset();

    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            width: _sidebarWidth,
            current: _section,
            iconBuilder: _iconFor,
            onSelect: (section) => setState(() => _section = section),
            onLogout: _logout,
          ),
          Expanded(child: _buildSection()),
        ],
      ),
    );
  }

  /// Renderuje SAMO odabranu sekciju.
  ///
  /// BUGFIX: ranije je ovdje bio `IndexedStack`, koji gradi I RASPOREĐUJE
  /// svih sedam sekcija odjednom (prikazuje samo jednu). Posljedice:
  ///  - sve tabele, grafovi i messenger paneli su bili u stablu istovremeno,
  ///    pa je layout prolazio kroz stotine redova koje korisnik ne vidi;
  ///  - off-stage djeca sa `Expanded`/`Flexible` parent data u kombinaciji sa
  ///    kompilacijom semantike obarala su assertion
  ///    `!semantics.parentDataDirty` u `RenderObject`, koji se onda ponavljao
  ///    svaki frame i zamrzavao aplikaciju nakon prijave.
  ///
  /// Stanje pretrage/filtera se NE gubi jer živi u provider-ima
  /// (`AdminProvider.propertyQuery`, `LocationProvider.countryQuery`…),
  /// a ekrani svoje `TextEditingController`-e sijeju iz providera u
  /// `initState`.
  Widget _buildSection() {
    switch (_section) {
      case AdminSection.dashboard:
        return const DashboardPage();
      case AdminSection.properties:
        return const ManagePropertiesPage();
      case AdminSection.users:
        return const ManageUsersPage();
      case AdminSection.locations:
        return const LocationsPage();
      case AdminSection.reference:
        return const ReferenceDataPage();
      case AdminSection.reports:
        return const ReportsPage();
      case AdminSection.messenger:
        return const MessengerPage();
    }
  }
}

class _Sidebar extends StatelessWidget {
  final double width;
  final AdminSection current;
  final IconData Function(AdminSection, {bool active}) iconBuilder;
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.width,
    required this.current,
    required this.iconBuilder,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4, vertical: AppSpace.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandMark(),
          const SizedBox(height: AppSpace.x8),
          for (final section in AdminSection.values)
            _NavItem(
              label: section.label,
              icon: iconBuilder(section, active: section == current),
              active: section == current,
              badge: section == AdminSection.messenger
                  ? const _UnreadBadge()
                  : null,
              onTap: () => onSelect(section),
            ),
          const Spacer(),
          const _SignedInAs(),
          const SizedBox(height: AppSpace.x2),
          _NavItem(
            label: 'Odjava',
            icon: PhosphorIcons.signOut(),
            active: false,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent),
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
            ),
            child: Icon(PhosphorIcons.house(), size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('eBooking', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'Administracija',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignedInAs extends StatelessWidget {
  const _SignedInAs();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        if (!provider.isLoaded) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x2, vertical: AppSpace.x3),
          child: Row(
            children: [
              NInitialsAvatar(name: profile.fullName, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      profile.emailAddress,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge();

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<ProfileProvider>().profile.id;
    final unread = context.watch<MessageProvider>().totalUnread(currentUserId);
    if (unread == 0) return const SizedBox.shrink();
    return NTag('$unread', variant: NTagVariant.accent);
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Widget? badge;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final foreground = active ? AppColors.accentText : AppColors.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accentTint
                  : (_hovered ? AppColors.neutral800 : Colors.transparent),
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              border: Border.all(
                color: active ? AppColors.accentBorder : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 17, color: foreground),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      color: foreground,
                    ),
                  ),
                ),
                if (widget.badge != null) widget.badge!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standardni okvir sadržaja sekcije — jedinstven padding i skrol.
class SectionScaffold extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const SectionScaffold({
    super.key,
    required this.child,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: const EdgeInsets.all(AppSpace.x8),
      child: child,
    );
    if (!scrollable) return padded;
    return SingleChildScrollView(child: padded);
  }
}
