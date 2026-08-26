import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Korisnici — tabela sa pretragom, filterom statusa i deaktivacijom naloga.
///
/// Izmjene u odnosu na staru verziju:
///  - Bio je `GridView` sa 6 kartica u redu i slikom preko cijele kartice;
///    dizajn traži tabelu sa avatarom uz ime.
///  - `Image(image: FileImage(user.profilePicture))` — `profilePicture` je bio
///    ne-nullable `File` koji je model pisao na disk; korisnik bez slike je
///    rušio parsiranje prije nego se ekran uopšte prikaže.
///  - Dugme za brisanje je imalo prazan `onPressed`. Sada zaista poziva
///    `DELETE /api/Administrator/DeleteUser`, uz confirmation dialog
///    (Upute 6: obavezan za nepovratne akcije).
///  - Nije bilo pretrage (Upute 2.2).
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _searchController = TextEditingController();
  String? _busyUserId;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<AdminProvider>().userQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deactivate(Profile user) async {
    final confirmed = await nConfirm(
      context,
      title: 'Deaktivacija naloga',
      message: 'Nalog "${user.fullName}" (${user.emailAddress}) bit će '
          'deaktiviran i korisnik se više neće moći prijaviti.\n\n'
          'Postojeće rezervacije se NE brišu.',
      confirmLabel: 'Deaktiviraj nalog',
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyUserId = user.id);
    final admin = context.read<AdminProvider>();

    try {
      final message = await admin.deleteUser(user.id);
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && admin.profiles.isEmpty) {
          return const SectionScaffold(
            child: NLoading(label: 'Učitavanje korisnika…'),
          );
        }

        final users = admin.filteredProfiles;

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Korisnici',
                subtitle: '${admin.profiles.length} registrovanih korisnika, '
                    '${admin.activeUserCount} aktivnih.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.isLoading ? null : admin.getProfiles,
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Osvježi'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              Row(
                children: [
                  Expanded(
                    child: NSearchField(
                      controller: _searchController,
                      hint: 'Pretraga po imenu ili e-mail adresi',
                      onChanged: admin.setUserQuery,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  NDropdown<bool?>(
                    width: 180,
                    value: admin.userStatusFilter,
                    hint: 'Svi statusi',
                    onChanged: admin.setUserStatusFilter,
                    items: const [
                      DropdownMenuItem<bool?>(
                          value: null, child: Text('Svi statusi')),
                      DropdownMenuItem<bool?>(
                          value: true, child: Text('Aktivan')),
                      DropdownMenuItem<bool?>(
                          value: false, child: Text('Deaktiviran')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  users.length == admin.profiles.length
                      ? 'Prikazano ${users.length} zapisa'
                      : 'Prikazano ${users.length} od '
                          '${admin.profiles.length} zapisa (filtrirano)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpace.x3),
              NCard(
                padding: EdgeInsets.zero,
                clip: true,
                child: _UserTable(
                  users: users,
                  busyUserId: _busyUserId,
                  onDeactivate: _deactivate,
                  onOpen: _openDetails,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDetails(Profile user) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _UserDetailsDialog(user: user),
    );
  }
}

class _UserTable extends StatelessWidget {
  final List<Profile> users;
  final String? busyUserId;
  final Future<void> Function(Profile) onDeactivate;
  final void Function(Profile) onOpen;

  const _UserTable({
    required this.users,
    required this.busyUserId,
    required this.onDeactivate,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return NTable(
      columns: const [
        NColumn('', width: 44),
        NColumn('Ime i prezime', flex: 3),
        NColumn('E-mail', flex: 3),
        NColumn('Uloga', width: 130),
        NColumn('Datum rođenja', width: 140),
        NColumn('Status', width: 130),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: users.length,
      empty: const NEmptyState(
        message: 'Nijedan korisnik ne odgovara zadatim kriterijima pretrage.',
      ),
      onRowTap: (index) => onOpen(users[index]),
      cellsBuilder: (context, index) {
        final user = users[index];
        final busy = busyUserId == user.id;

        final dob = DateTime.tryParse(user.dob);

        return [
          _UserAvatar(user: user),
          Text(user.fullName, overflow: TextOverflow.ellipsis),
          NMutedCell(user.emailAddress),
          NTag(
            user.role.label,
            variant: user.role == UserRole.administrator
                ? NTagVariant.outline
                : NTagVariant.neutral,
          ),
          NMutedCell(dob == null ? '—' : dateFormat.format(dob)),
          NStatusTag(
            active: user.isActive,
            inactiveLabel: 'Deaktiviran',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.eye(),
                tooltip: 'Detalji korisnika',
                onPressed: () => onOpen(user),
              ),
              if (busy)
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                NIconAction(
                  icon: PhosphorIcons.userMinus(),
                  tooltip: 'Deaktiviraj nalog',
                  color: AppColors.error,
                  // Upute 6: nedostupna akcija = disabled + razlog.
                  disabledReason: !user.isActive
                      ? 'Nalog je već deaktiviran.'
                      : (user.role == UserRole.administrator
                          ? 'Administratorski nalozi se ne mogu deaktivirati '
                              'iz ovog pregleda.'
                          : null),
                  onPressed: () => onDeactivate(user),
                ),
            ],
          ),
        ];
      },
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final Profile user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final bytes = user.profilePicture;
    if (bytes == null || bytes.isEmpty) {
      return NInitialsAvatar(name: user.fullName, size: 28);
    }
    return ClipOval(
      child: Image.memory(
        bytes,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            NInitialsAvatar(name: user.fullName, size: 28),
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final Profile user;

  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final dob = DateTime.tryParse(user.dob);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              NDialogHeader(title: user.fullName, subtitle: user.emailAddress),
              const SizedBox(height: AppSpace.x6),
              Row(
                children: [
                  _UserAvatarLarge(user: user),
                  const SizedBox(width: AppSpace.x6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            NStatusTag(
                              active: user.isActive,
                              inactiveLabel: 'Deaktiviran',
                            ),
                            const SizedBox(width: AppSpace.x2),
                            NTag(user.role.label, variant: NTagVariant.outline),
                          ],
                        ),
                        const SizedBox(height: AppSpace.x4),
                        // Upute 6: forme ne smiju prikazivati ID vrijednosti
                        // iz baze — zato ovdje nema `user.id`.
                        _Row(label: 'Korisničko ime', value: user.displayName),
                        _Row(
                          label: 'Datum rođenja',
                          value: dob == null ? '—' : dateFormat.format(dob),
                        ),
                        _Row(label: 'Spol', value: user.gender.label),
                        if (user.socialLink.isNotEmpty)
                          _Row(
                            label: 'Društvena mreža',
                            value: user.socialLink,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nazad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatarLarge extends StatelessWidget {
  final Profile user;
  const _UserAvatarLarge({required this.user});

  @override
  Widget build(BuildContext context) {
    final bytes = user.profilePicture;
    if (bytes == null || bytes.isEmpty) {
      return NInitialsAvatar(name: user.fullName, size: 84);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusMd),
      child: Image.memory(
        bytes,
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            NInitialsAvatar(name: user.fullName, size: 84),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
