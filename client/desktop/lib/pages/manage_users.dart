import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';
import 'package:ebooking_desktop/widgets/pagination_control.dart';

/// Korisnici — tabela sa pretragom, filterom statusa i deaktivacijom naloga.
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  static const _searchDebounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  String? _busyUserId;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<AdminProvider>().userQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      context.read<AdminProvider>().setUserQuery(value);
    });
  }

  Future<void> _deactivate(Profile user) async {
    final confirmed = await nConfirm(
      context,
      title: 'Deactivate account',
      message: 'Account "${user.fullName}" (${user.emailAddress}) will be '
          'deactivated and the user will no longer be able to log in.\n\n'
          'Existing reservations are NOT deleted.',
      confirmLabel: 'Deactivate account',
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

  Future<void> _editUser(Profile user) async {
    final admin = context.read<AdminProvider>();
    final message = await showDialog<String>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _UserFormDialog(
        admin: admin,
        user: user,
        isOwnAccount: user.id == admin.signedInAdministratorId,
      ),
    );
    if (message != null && mounted) nToast(context, message);
  }

  Future<void> _openMessage(Profile user) async {
    final messenger = context.read<MessageProvider>();
    try {
      await messenger.openChatWithUser(user.id);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  Future<void> _newAdministrator() async {
    final admin = context.read<AdminProvider>();
    final message = await showDialog<String>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _AdministratorFormDialog(admin: admin),
    );
    if (message != null && mounted) nToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final messagingAvailable = context.watch<MessageProvider>().isConnected;

    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.usersLoading && admin.users.isEmpty && admin.usersError == null) {
          return const SectionScaffold(
            child: NLoading(label: 'Loading users…'),
          );
        }

        final users = admin.users;

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Users',
                subtitle: '${admin.userTotalCount} registered users, '
                    '${admin.userActiveCount} active.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.usersLoading ? null : _newAdministrator,
                    icon: Icon(PhosphorIcons.plus(), size: 14),
                    label: const Text('New administrator'),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  OutlinedButton.icon(
                    onPressed: admin.usersLoading
                        ? null
                        : () {
                            admin.loadUsers();
                            admin.loadUserCounts();
                          },
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              Row(
                children: [
                  Expanded(
                    child: NSearchField(
                      controller: _searchController,
                      hint: 'Search by name or email address',
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  NDropdown<UserRole?>(
                    width: 170,
                    value: admin.userRoleFilter,
                    hint: 'All roles',
                    onChanged: admin.setUserRoleFilter,
                    items: [
                      const DropdownMenuItem<UserRole?>(
                          value: null, child: Text('All roles')),
                      for (final role in UserRole.values)
                        DropdownMenuItem<UserRole?>(
                            value: role, child: Text(role.label)),
                    ],
                  ),
                  const SizedBox(width: AppSpace.x3),
                  NDropdown<bool?>(
                    width: 180,
                    value: admin.userStatusFilter,
                    hint: 'All statuses',
                    onChanged: admin.setUserStatusFilter,
                    items: const [
                      DropdownMenuItem<bool?>(
                          value: null, child: Text('All statuses')),
                      DropdownMenuItem<bool?>(
                          value: true, child: Text('Active')),
                      DropdownMenuItem<bool?>(
                          value: false, child: Text('Deactivated')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x4),
              if (admin.usersError != null)
                NErrorState(
                  message: admin.usersError!,
                  onRetry: admin.loadUsers,
                )
              else ...[
                NCard(
                  padding: EdgeInsets.zero,
                  clip: true,
                  child: _UserTable(
                    users: users,
                    busyUserId: _busyUserId,
                    signedInId: admin.signedInAdministratorId,
                    messagingAvailable: messagingAvailable,
                    onDeactivate: _deactivate,
                    onOpen: _openDetails,
                    onEdit: _editUser,
                    onMessage: _openMessage,
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NPaginationControl(
                  page: admin.usersPage,
                  totalPages: admin.usersTotalPages,
                  totalCount: admin.usersTotalCount,
                  pageSize: admin.usersPageSize,
                  onPageChanged: admin.setUsersPage,
                  onPageSizeChanged: admin.setUsersPageSize,
                ),
              ],
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
  final String signedInId;
  final Future<void> Function(Profile) onDeactivate;
  final void Function(Profile) onOpen;
  final void Function(Profile) onEdit;
  final bool messagingAvailable;
  final void Function(Profile) onMessage;

  const _UserTable({
    required this.users,
    required this.busyUserId,
    required this.signedInId,
    required this.messagingAvailable,
    required this.onDeactivate,
    required this.onOpen,
    required this.onEdit,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return NTable(
      columns: const [
        NColumn('', width: 44),
        NColumn('Full name', flex: 3),
        NColumn('Email', flex: 3),
        NColumn('Role', width: 130),
        NColumn('Date of birth', width: 140),
        NColumn('Status', width: 130),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: users.length,
      empty: const NEmptyState(
        message: 'No users match the search criteria.',
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
            inactiveLabel: 'Deactivated',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.eye(),
                tooltip: 'User details',
                onPressed: () => onOpen(user),
              ),
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Edit user',
                onPressed: () => onEdit(user),
              ),
              NIconAction(
                icon: PhosphorIcons.chatCircle(),
                tooltip: 'Send message',
                disabledReason: user.id == signedInId
                    ? 'You cannot send a message to the account you are '
                        'currently logged in as.'
                    : (!messagingAvailable
                        ? 'The connection to the messaging service has not been established.'
                        : null),
                onPressed: () => onMessage(user),
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
                  tooltip: 'Delete account',
                  color: AppColors.error,
                  disabledReason: user.id == signedInId
                      ? 'You cannot delete the account you are currently '
                          'logged in as.'
                      : null,
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
                              inactiveLabel: 'Deactivated',
                            ),
                            const SizedBox(width: AppSpace.x2),
                            NTag(user.role.label, variant: NTagVariant.outline),
                          ],
                        ),
                        const SizedBox(height: AppSpace.x4),
                        _Row(label: 'Username', value: user.displayName),
                        _Row(
                          label: 'Date of birth',
                          value: dob == null ? '—' : dateFormat.format(dob),
                        ),
                        _Row(label: 'Gender', value: user.gender.label),
                        if (user.socialLink.isNotEmpty)
                          _Row(
                            label: 'Social media',
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
                  child: const Text('Back'),
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

class _UserFormDialog extends StatefulWidget {
  final AdminProvider admin;
  final Profile user;
  final bool isOwnAccount;

  const _UserFormDialog({
    required this.admin,
    required this.user,
    required this.isOwnAccount,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayName;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _socialLink;
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _repeatPassword = TextEditingController();

  late DateTime? _birthDate;
  late UserGender _gender;
  late bool _isActive;

  bool _changePassword = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.user.displayName);
    _firstName = TextEditingController(text: widget.user.firstName);
    _lastName = TextEditingController(text: widget.user.lastName);
    _socialLink = TextEditingController(text: widget.user.socialLink);
    _birthDate = DateTime.tryParse(widget.user.dob);
    _gender = widget.user.gender;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _socialLink.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _repeatPassword.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      setState(() => _error = 'Select a date of birth.');
      return;
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);

    try {
      var message = await widget.admin.updateUser(
        userId: widget.user.id,
        changes: {
          'displayName': _displayName.text.trim(),
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'birthDate': _birthDate!.toIso8601String(),
          'gender': _gender.index,
          'socialLink': _socialLink.text.trim(),
          if (!widget.isOwnAccount) 'isActive': _isActive,
        },
      );

      if (_changePassword) {
        message = widget.isOwnAccount
            ? await widget.admin.changeOwnPassword(
                oldPassword: _oldPassword.text,
                newPassword: _newPassword.text,
              )
            : await widget.admin.resetUserPassword(
                userId: widget.user.id,
                newPassword: _newPassword.text,
              );
      }

      navigator.pop(message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = ApiResponseHandler.describe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 660),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(
                  title: 'Edit user',
                  subtitle: '${widget.user.fullName} · ${widget.user.role.label}'
                      '${widget.isOwnAccount ? ' · your own account' : ''}',
                ),
                const SizedBox(height: AppSpace.x4),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NField(
                          label: 'Username',
                          child: TextFormField(
                            controller: _displayName,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 50, 'Username'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'First name',
                          child: TextFormField(
                            controller: _firstName,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 15, 'First name'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Last name',
                          child: TextFormField(
                            controller: _lastName,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 30, 'Last name'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Date of birth',
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _pickBirthDate,
                            icon: Icon(PhosphorIcons.calendarBlank(), size: 14),
                            label: Text(_birthDate == null
                                ? 'Select date'
                                : dateFormat.format(_birthDate!)),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Gender',
                          child: DropdownButtonFormField<UserGender>(
                            initialValue: _gender,
                            isExpanded: true,
                            items: [
                              for (final gender in UserGender.values)
                                DropdownMenuItem<UserGender>(
                                  value: gender,
                                  child: Text(gender.label),
                                ),
                            ],
                            onChanged: _saving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _gender = value);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Social media',
                          child: TextFormField(
                            controller: _socialLink,
                            enabled: !_saving,
                            decoration: const InputDecoration(
                                hintText: 'e.g. https://example.test/profile'),
                            validator: (v) => (v ?? '').trim().length > 200
                                ? 'The social media address may have at most '
                                    '200 characters.'
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _isActive,
                          onChanged: (_saving || widget.isOwnAccount)
                              ? null
                              : (value) => setState(() => _isActive = value),
                          title: const Text('Account is active'),
                          subtitle: Text(
                            widget.isOwnAccount
                                ? 'The status of your own account cannot be changed.'
                                : 'A deactivated account cannot log in, and '
                                    'existing tokens stop being valid.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x2),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _changePassword,
                          onChanged: _saving
                              ? null
                              : (value) => setState(
                                  () => _changePassword = value ?? false),
                          title: const Text('Change password'),
                          subtitle: Text(
                            widget.isOwnAccount
                                ? 'Your own account also requires the current password.'
                                : 'Another user\'s password is set without entering the old one.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (_changePassword) ...[
                          if (widget.isOwnAccount) ...[
                            const SizedBox(height: AppSpace.x3),
                            NField(
                              label: 'Current password',
                              child: TextFormField(
                                controller: _oldPassword,
                                obscureText: true,
                                enabled: !_saving,
                                validator: (v) => (v ?? '').isEmpty
                                    ? 'Enter the current password.'
                                    : null,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpace.x3),
                          NField(
                            label: 'New password',
                            child: TextFormField(
                              controller: _newPassword,
                              obscureText: true,
                              enabled: !_saving,
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'The new password is required and must not be '
                                      'empty.'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x3),
                          NField(
                            label: 'Confirm new password',
                            child: TextFormField(
                              controller: _repeatPassword,
                              obscureText: true,
                              enabled: !_saving,
                              validator: (v) => v != _newPassword.text
                                  ? 'Confirmation does not match the new password.'
                                  : null,
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: AppSpace.x4),
                          _DialogError(message: _error!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.x6),
                _DialogActions(
                  saving: _saving,
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdministratorFormDialog extends StatefulWidget {
  final AdminProvider admin;

  const _AdministratorFormDialog({required this.admin});

  @override
  State<_AdministratorFormDialog> createState() =>
      _AdministratorFormDialogState();
}

class _AdministratorFormDialogState extends State<_AdministratorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();

  DateTime? _birthDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _displayName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      setState(() => _error = 'Select a date of birth.');
      return;
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);

    try {
      final message = await widget.admin.addAdministrator({
        'displayName': _displayName.text.trim(),
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'birthDate': _birthDate!.toIso8601String(),
        'email': _email.text.trim(),
        'password': _password.text,
      });
      navigator.pop(message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = ApiResponseHandler.describe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const NDialogHeader(
                  title: 'New administrator',
                  subtitle: 'The account is created active and can log in immediately.',
                ),
                const SizedBox(height: AppSpace.x4),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NField(
                          label: 'Username',
                          child: TextFormField(
                            controller: _displayName,
                            autofocus: true,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 50, 'Username'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'First name',
                          child: TextFormField(
                            controller: _firstName,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 15, 'First name'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Last name',
                          child: TextFormField(
                            controller: _lastName,
                            enabled: !_saving,
                            validator: (v) => _text(v, 3, 30, 'Last name'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Email',
                          child: TextFormField(
                            controller: _email,
                            enabled: !_saving,
                            decoration:
                                const InputDecoration(hintText: 'name@domain.ba'),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Email address is required.';
                              }
                              final regex = RegExp(
                                  r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                              if (!regex.hasMatch(text)) {
                                return 'Enter a valid email address in the '
                                    'format: name@domain.ba';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Date of birth',
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _pickBirthDate,
                            icon: Icon(PhosphorIcons.calendarBlank(), size: 14),
                            label: Text(_birthDate == null
                                ? 'Select date'
                                : dateFormat.format(_birthDate!)),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x4),
                        NField(
                          label: 'Password',
                          child: TextFormField(
                            controller: _password,
                            obscureText: true,
                            enabled: !_saving,
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Password is required and must not be empty.'
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x3),
                        NField(
                          label: 'Confirm password',
                          child: TextFormField(
                            controller: _repeat,
                            obscureText: true,
                            enabled: !_saving,
                            validator: (v) => v != _password.text
                                ? 'Confirmation does not match the password.'
                                : null,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpace.x4),
                          _DialogError(message: _error!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.x6),
                _DialogActions(
                  saving: _saving,
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _text(String? value, int min, int max, String field) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$field is required and must have $min to $max characters.';
  if (text.length < min || text.length > max) {
    return '$field must have between $min and $max characters.';
  }
  return null;
}

class _DialogActions extends StatelessWidget {
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _DialogActions({
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: saving ? null : onCancel, child: const Text('Back')),
        const SizedBox(width: AppSpace.x3),
        OutlinedButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _DialogError extends StatelessWidget {
  final String message;

  const _DialogError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 15, color: AppColors.error),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
