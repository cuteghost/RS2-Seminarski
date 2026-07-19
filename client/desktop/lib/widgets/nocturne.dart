// Ove komponente ne znaju ništa o provider-ima niti o domenu: primaju podatke kroz konstruktor
// i emituju callback-e. Boje, radijusi i spacing dolaze iz `config/app_theme.dart`.
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:ebooking_desktop/config/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Kartica  (.card)
// ═══════════════════════════════════════════════════════════════════════════

class NCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool clip;

  const NCard({
    super.key,
    required this.child,
    this.padding,
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding ?? const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );

    if (!clip) return decorated;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusMd),
      child: decorated,
    );
  }
}

/// `.card-kicker` — mali uppercase accent nadnaslov iznad naslova kartice.
class NKicker extends StatelessWidget {
  final String text;
  const NKicker(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      );
}

/// Zaglavlje ekrana: naslov + podnaslov lijevo, akcije desno.
/// Dizajn je "flush-left, asimetričan" — sadržaj se drži lijeve ivice.
class NPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const NPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpace.x2),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: AppSpace.x6),
          Wrap(spacing: AppSpace.x2, children: actions),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tagovi  (.tag / .tag-accent / .tag-neutral / .tag-outline)
// ═══════════════════════════════════════════════════════════════════════════

enum NTagVariant { accent, neutral, outline }

class NTag extends StatelessWidget {
  final String label;
  final NTagVariant variant;

  const NTag(this.label, {super.key, this.variant = NTagVariant.neutral});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    Border? border;

    switch (variant) {
      case NTagVariant.accent:
        bg = AppColors.accentBorder;
        fg = const Color(0xFFF5F4FF);
        break;
      case NTagVariant.neutral:
        bg = AppColors.neutral800;
        fg = const Color(0xFFF3F5FE);
        break;
      case NTagVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.accent;
        border = Border.all(color: AppColors.accent);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(AppColors.radiusMd * 0.75),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          letterSpacing: 0.22,
          color: fg,
        ),
      ),
    );
  }
}

class NStatusTag extends StatelessWidget {
  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  const NStatusTag({
    super.key,
    required this.active,
    this.activeLabel = 'Active',
    this.inactiveLabel = 'Inactive',
  });

  @override
  Widget build(BuildContext context) => NTag(
        active ? activeLabel : inactiveLabel,
        variant: active ? NTagVariant.accent : NTagVariant.neutral,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Avatar sa inicijalima
// ═══════════════════════════════════════════════════════════════════════════

class NInitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const NInitialsAvatar({super.key, required this.name, this.size = 28});

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accentTint,
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: size * 0.39,
          color: AppColors.accentText,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Polje sa labelom  (.field + label + .input)
// ═══════════════════════════════════════════════════════════════════════════

class NField extends StatelessWidget {
  final String label;
  final Widget child;

  const NField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class NSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const NSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 16,
            color: AppColors.textTertiary,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: Icon(PhosphorIcons.x(), size: 14),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

/// Dropdown filter koji se puni iz proslijeđene liste; ne sadrži nijednu vrijednost,
/// sve prima kroz `items`.
class NDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final double? width;

  const NDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(AppColors.radiusMd),
      style: Theme.of(context).textTheme.bodyMedium,
      icon: Icon(PhosphorIcons.caretDown(), size: 14),
      hint: hint == null
          ? null
          : Text(hint!, style: Theme.of(context).textTheme.bodySmall),
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tabela  (.table)
// ═══════════════════════════════════════════════════════════════════════════

class NColumn {
  final String label;

  /// `null` => kolona se širi (flex 1). Postavljeno => fiksna širina.
  final double? width;
  final int flex;
  final Alignment align;

  const NColumn(
    this.label, {
    this.width,
    this.flex = 1,
    this.align = Alignment.centerLeft,
  });
}

/// Lagana tabela na Row/Column-ima (ne DataTable) jer nam treba
/// kontrola nad "fading rule" separatorima i hover stanjem redova.
class NTable extends StatelessWidget {
  final List<NColumn> columns;
  final int rowCount;
  final List<Widget> Function(BuildContext context, int index) cellsBuilder;
  final void Function(int index)? onRowTap;
  final Widget? empty;

  const NTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellsBuilder,
    this.onRowTap,
    this.empty,
  });

  Widget _cell(Widget child, NColumn col) {
    final aligned = Align(alignment: col.align, child: child);
    if (col.width != null) {
      return SizedBox(width: col.width, child: aligned);
    }
    return Expanded(flex: col.flex, child: aligned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final header = Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4, vertical: AppSpace.x3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (final col in columns)
            _cell(
              Text(
                col.label.toUpperCase(),
                style: theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
              col,
            ),
        ],
      ),
    );

    if (rowCount == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          empty ?? const NEmptyState(message: 'No records to display.'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rowCount,
          itemBuilder: (context, index) {
            final cells = cellsBuilder(context, index);
            assert(
              cells.length == columns.length,
              'NTable: red $index ima ${cells.length} ćelija, '
              'a definisano je ${columns.length} kolona.',
            );
            return _NTableRow(
              onTap: onRowTap == null ? null : () => onRowTap!(index),
              child: Row(
                children: [
                  for (var i = 0; i < columns.length; i++)
                    _cell(cells[i], columns[i]),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NTableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _NTableRow({required this.child, this.onTap});

  @override
  State<_NTableRow> createState() => _NTableRowState();
}

class _NTableRowState extends State<_NTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x4, vertical: AppSpace.x3),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.text.withValues(alpha: 0.04)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: AppColors.text.withValues(alpha: 0.06)),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Ćelija sa prigušenim tekstom (`.text-muted` u tabeli).
class NMutedCell extends StatelessWidget {
  final String text;
  const NMutedCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Akcije u redu tabele
// ═══════════════════════════════════════════════════════════════════════════

/// Ikonično dugme sa obaveznim tooltipom. Kad je `disabledReason` postavljen, dugme je
/// disabled i tooltip objašnjava zašto.
class NIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? disabledReason;
  final Color? color;

  const NIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.disabledReason,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = disabledReason != null || onPressed == null;
    return Tooltip(
      message: disabledReason ?? tooltip,
      child: IconButton(
        onPressed: disabled ? null : onPressed,
        icon: Icon(icon, size: 15),
        color: color ?? AppColors.accentLink,
        disabledColor: AppColors.textTertiary.withValues(alpha: 0.5),
        splashRadius: 16,
        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stanja: prazno / učitavanje / greška
// ═══════════════════════════════════════════════════════════════════════════

class NEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;

  const NEmptyState({super.key, required this.message, this.icon, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? PhosphorIcons.tray(),
            size: 26,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpace.x3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpace.x4),
            action!,
          ],
        ],
      ),
    );
  }
}

class NLoading extends StatelessWidget {
  final String? label;
  const NLoading({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpace.x3),
            Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class NErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const NErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 26, color: AppColors.error),
          const SizedBox(height: AppSpace.x3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppColors.error,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpace.x4),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Dijalozi
// ═══════════════════════════════════════════════════════════════════════════

class NDialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const NDialogHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.dialogTheme.titleTextStyle),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpace.x1),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        NIconAction(
          icon: PhosphorIcons.x(),
          tooltip: 'Close',
          color: AppColors.textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Vraća `true` samo ako je korisnik eksplicitno potvrdio.
Future<bool> nConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 380, child: Text(message)),
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpace.x6, 0, AppSpace.x6, AppSpace.x6),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ═══════════════════════════════════════════════════════════════════════════
// Poruke (SnackBar)
// ═══════════════════════════════════════════════════════════════════════════

void nToast(BuildContext context, String message, {bool isError = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? PhosphorIcons.warningCircle()
                  : PhosphorIcons.checkCircle(),
              size: 16,
              color: isError ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
}

// ═══════════════════════════════════════════════════════════════════════════
// Grafovi
// ═══════════════════════════════════════════════════════════════════════════

/// Stubičasti graf iz dizajna: akcenat-700 stubići, labela ispod,
/// visina normalizovana na maksimum. Namjerno bez `fl_chart`-a — dizajn
/// traži tanke stubiće bez ose i grid-a, a to je jednostavnije direktno.
class NBarChart extends StatelessWidget {
  final List<({String label, num value})> data;
  final double height;
  final bool showEveryLabel;

  const NBarChart({
    super.key,
    required this.data,
    this.height = 140,
    this.showEveryLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const NEmptyState(message: 'No data to display.'),
      );
    }

    final max = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final safeMax = max == 0 ? 1 : max;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: '${data[i].label}: ${data[i].value}',
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        child: Container(
                          height: ((height - 22) * data[i].value / safeMax)
                              .clamp(2.0, height - 22),
                          decoration: const BoxDecoration(
                            color: AppColors.accentBar,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 12,
                      child: (showEveryLabel || i % 2 == 0)
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                data[i].label,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NMeterBar extends StatelessWidget {
  final double fraction; // 0..1
  final double height;

  const NMeterBar({super.key, required this.fraction, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: AppColors.neutral900,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tabovi (sub-navigacija unutar ekrana)
// ═══════════════════════════════════════════════════════════════════════════

class NTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const NTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: _NTab(
              label: labels[i],
              active: i == selected,
              onTap: () => onChanged(i),
            ),
          ),
      ],
    );
  }
}

class _NTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.surface : Colors.transparent,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppColors.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppColors.radiusMd),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: active ? AppColors.accentBorder : AppColors.border),
              left: BorderSide(
                  color: active ? AppColors.accentBorder : AppColors.border),
              right: BorderSide(
                  color: active ? AppColors.accentBorder : AppColors.border),
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppColors.radiusMd),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: active ? AppColors.accentText : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
