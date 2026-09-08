import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

class NPaginationControl extends StatelessWidget {
  final int page;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const NPaginationControl({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page $page of $totalPages · $totalCount records',
          style: textTheme.bodySmall,
        ),
        Row(
          children: [
            NDropdown<int>(
              width: 130,
              value: pageSizeOptions.contains(pageSize) ? pageSize : null,
              hint: 'Per page',
              onChanged: (value) {
                if (value != null) onPageSizeChanged(value);
              },
              items: [
                for (final size in pageSizeOptions)
                  DropdownMenuItem(value: size, child: Text('$size per page')),
              ],
            ),
            const SizedBox(width: AppSpace.x3),
            NIconAction(
              icon: PhosphorIcons.caretLeft(),
              tooltip: 'Previous page',
              disabledReason: page <= 1 ? 'This is the first page.' : null,
              onPressed: () => onPageChanged(page - 1),
            ),
            const SizedBox(width: AppSpace.x2),
            NIconAction(
              icon: PhosphorIcons.caretRight(),
              tooltip: 'Next page',
              disabledReason:
                  page >= totalPages ? 'This is the last page.' : null,
              onPressed: () => onPageChanged(page + 1),
            ),
          ],
        ),
      ],
    );
  }
}
