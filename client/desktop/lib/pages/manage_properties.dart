import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/accommodation_review.dart';
import 'package:ebooking_desktop/models/accommodation_type.dart';
import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/providers/reference_data_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/authorized_image.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';
import 'package:ebooking_desktop/widgets/pagination_control.dart';

/// Smještaji — tabela sa pretragom i tri filtera, plus detaljni prikaz.
class ManagePropertiesPage extends StatefulWidget {
  const ManagePropertiesPage({super.key});

  @override
  State<ManagePropertiesPage> createState() => _ManagePropertiesPageState();
}

class _ManagePropertiesPageState extends State<ManagePropertiesPage> {
  static const _searchDebounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String? _busyAccommodationId;

  @override
  void initState() {
    super.initState();
    // Sekcije se ruše i ponovo grade pri prebacivanju kroz sidebar, a upit
    // živi u provideru — bez ovoga bi polje izgledalo prazno dok je tabela
    // i dalje filtrirana.
    _searchController.text = context.read<AdminProvider>().propertyQuery;
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
      context.read<AdminProvider>().setPropertyQuery(value);
    });
  }

  Future<void> _toggleStatus(AccommodationGET item) async {
    final activating = !item.status;
    final confirmed = await nConfirm(
      context,
      title: activating ? 'Activate property' : 'Deactivate property',
      message: activating
          ? 'Property "${item.name}" will be offered to customers again in search '
              'and in nearby listings.'
          : 'Property "${item.name}" will no longer be offered to customers in search '
              'or in nearby listings. Existing reservations are not deleted.',
      confirmLabel: activating ? 'Activate' : 'Deactivate',
      destructive: !activating,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyAccommodationId = item.id);
    final admin = context.read<AdminProvider>();

    try {
      final message = await admin.setAccommodationStatus(
        accommodationId: item.id,
        status: activating,
      );
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    } finally {
      if (mounted) setState(() => _busyAccommodationId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.propertiesLoading &&
            admin.properties.isEmpty &&
            admin.propertiesError == null) {
          return const SectionScaffold(
            child: NLoading(label: 'Loading properties…'),
          );
        }

        final items = admin.properties;

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Properties',
                subtitle: '${admin.propertiesTotalCount} properties.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.propertiesLoading
                        ? null
                        : () => admin.loadProperties(),
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              _Filters(
                admin: admin,
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
                types: context.watch<ReferenceDataProvider>().types,
                cities: context.watch<LocationProvider>().cities,
              ),
              const SizedBox(height: AppSpace.x4),
              if (admin.propertiesError != null)
                NErrorState(
                  message: admin.propertiesError!,
                  onRetry: () => admin.loadProperties(),
                )
              else ...[
                NCard(
                  padding: EdgeInsets.zero,
                  clip: true,
                  child: _PropertyTable(
                    items: items,
                    imageToken: admin.imageToken,
                    busyAccommodationId: _busyAccommodationId,
                    onDelete: (item) => _deleteAccommodation(context, admin, item),
                    onToggleStatus: _toggleStatus,
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NPaginationControl(
                  page: admin.propertiesPage,
                  totalPages: admin.propertiesTotalPages,
                  totalCount: admin.propertiesTotalCount,
                  pageSize: admin.propertiesPageSize,
                  onPageChanged: admin.setPropertiesPage,
                  onPageSizeChanged: admin.setPropertiesPageSize,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  final AdminProvider admin;
  final List<AccommodationType> types;
  final List<City> cities;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _Filters({
    required this.admin,
    required this.controller,
    required this.onSearchChanged,
    required this.types,
    required this.cities,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NSearchField(
            controller: controller,
            hint: 'Search by name, address or city',
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: AppSpace.x3),

        // Gradovi dolaze iz `LocationProvider`, ne iz učitanih smještaja.
        NDropdown<String?>(
          width: 170,
          value: admin.propertyCityFilter,
          hint: 'All cities',
          onChanged: admin.setPropertyCityFilter,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('All cities')),
            for (final city in cities)
              DropdownMenuItem<String?>(value: city.id, child: Text(city.name)),
          ],
        ),
        const SizedBox(width: AppSpace.x3),

        NDropdown<String?>(
          width: 170,
          value: admin.propertyTypeFilter,
          hint: 'All types',
          onChanged: admin.setPropertyTypeFilter,
          items: [
            const DropdownMenuItem<String?>(
                value: null, child: Text('All types')),
            for (final type in types)
              DropdownMenuItem<String?>(
                  value: type.id, child: Text(type.name)),
          ],
        ),
        const SizedBox(width: AppSpace.x3),

        NDropdown<bool?>(
          width: 150,
          value: admin.propertyStatusFilter,
          hint: 'All statuses',
          onChanged: admin.setPropertyStatusFilter,
          items: const [
            DropdownMenuItem<bool?>(value: null, child: Text('All statuses')),
            DropdownMenuItem<bool?>(value: true, child: Text('Active')),
            DropdownMenuItem<bool?>(value: false, child: Text('Inactive')),
          ],
        ),
      ],
    );
  }
}

class _PropertyTable extends StatelessWidget {
  final List<AccommodationGET> items;
  final String? imageToken;
  final String? busyAccommodationId;
  final void Function(AccommodationGET item) onDelete;
  final void Function(AccommodationGET item) onToggleStatus;

  const _PropertyTable({
    required this.items,
    required this.imageToken,
    required this.busyAccommodationId,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final money =
        NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 0);

    return NTable(
      columns: const [
        NColumn('', width: 52),
        NColumn('Name', flex: 3),
        NColumn('Type', flex: 2),
        NColumn('City, country', flex: 3),
        NColumn('Price / night', width: 120, align: Alignment.centerRight),
        NColumn('Rating', width: 110, align: Alignment.centerRight),
        NColumn('Status', width: 120),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: items.length,
      empty: const NEmptyState(
        message: 'No properties match the search criteria.',
      ),
      onRowTap: (index) => _openDetails(context, items[index]),
      cellsBuilder: (context, index) {
        final item = items[index];
        final busy = busyAccommodationId == item.id;

        return [
          _Thumbnail(item: item, token: imageToken),
          Text(item.name, overflow: TextOverflow.ellipsis),
          NMutedCell(item.typeLabel),
          NMutedCell(item.location.placeLabel),
          Text(money.format(item.pricePerNight)),
          _Rating(score: item.reviewScore),
          NStatusTag(active: item.status),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.eye(),
                tooltip: 'Property details',
                onPressed: () => _openDetails(context, item),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                NIconAction(
                  icon: item.status
                      ? PhosphorIcons.eyeSlash()
                      : PhosphorIcons.eye(),
                  tooltip: item.status
                      ? 'Deactivate property'
                      : 'Activate property',
                  onPressed: () => onToggleStatus(item),
                ),
                NIconAction(
                  icon: PhosphorIcons.trash(),
                  tooltip: 'Delete property',
                  color: AppColors.error,
                  onPressed: () => onDelete(item),
                ),
              ],
            ],
          ),
        ];
      },
    );
  }

  void _openDetails(BuildContext context, AccommodationGET item) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _PropertyDetailsDialog(item: item, token: imageToken),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final AccommodationGET item;
  final String? token;

  const _Thumbnail({required this.item, required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: AuthorizedImage(
        path: item.hasImages ? item.imageUrls.first : '',
        token: token,
        width: 40,
        height: 30,
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  final double score;
  const _Rating({required this.score});

  @override
  Widget build(BuildContext context) {
    if (score <= 0) return const NMutedCell('—');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(score.toStringAsFixed(1)),
        const SizedBox(width: 4),
        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
            size: 11, color: AppColors.accent),
      ],
    );
  }
}

/// Master–detail: red tabele otvara detalje smještaja.
class _PropertyDetailsDialog extends StatelessWidget {
  final AccommodationGET item;
  final String? token;

  const _PropertyDetailsDialog({required this.item, required this.token});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money =
        NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 2);
    final amenities = item.accommodationDetails.amenityLabels;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              NDialogHeader(
                title: item.name,
                subtitle: item.location.address.isEmpty
                    ? item.location.placeLabel
                    : '${item.location.address} · ${item.location.placeLabel}',
              ),
              const SizedBox(height: AppSpace.x4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.hasImages)
                        _ImageStrip(urls: item.imageUrls, token: token),
                      if (item.hasImages) const SizedBox(height: AppSpace.x6),

                      Row(
                        children: [
                          NStatusTag(active: item.status),
                          const SizedBox(width: AppSpace.x2),
                          NTag(item.typeLabel),
                        ],
                      ),
                      const SizedBox(height: AppSpace.x6),

                      _DetailRow(
                        label: 'Price per night',
                        value: money.format(item.pricePerNight),
                      ),
                      _DetailRow(
                        label: 'Average rating',
                        value: item.reviewScore <= 0
                            ? 'No ratings yet'
                            : item.reviewScore.toStringAsFixed(1),
                      ),
                      _DetailRow(
                        label: 'Number of beds',
                        value: '${item.accommodationDetails.numberOfBeds}',
                      ),
                      _DetailRow(
                        label: 'Coordinates',
                        value: '${item.location.latitude.toStringAsFixed(5)}, '
                            '${item.location.longitude.toStringAsFixed(5)}',
                      ),

                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.x6),
                        const NKicker('Description'),
                        const SizedBox(height: AppSpace.x2),
                        Text(item.description, style: theme.textTheme.bodyMedium),
                      ],

                      if (amenities.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.x6),
                        const NKicker('Amenities'),
                        const SizedBox(height: AppSpace.x3),
                        Wrap(
                          spacing: AppSpace.x2,
                          runSpacing: AppSpace.x2,
                          children: [for (final a in amenities) NTag(a)],
                        ),
                      ],

                      const SizedBox(height: AppSpace.x6),
                      const NKicker('Reviews'),
                      const SizedBox(height: AppSpace.x3),
                      _ReviewsSection(accommodationId: item.id),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
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

class _ImageStrip extends StatelessWidget {
  final List<String> urls;
  final String? token;

  const _ImageStrip({required this.urls, required this.token});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpace.x2),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          child: AuthorizedImage(
            path: urls[index],
            token: token,
            width: 170,
            height: 120,
            iconSize: 18,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

Future<void> _deleteAccommodation(
  BuildContext context,
  AdminProvider admin,
  AccommodationGET item,
) async {
  final confirmed = await nConfirm(
    context,
    title: 'Delete property',
    message: 'Delete property "${item.name}"? The server will reject the deletion if '
        'there are reservations for it that are still ongoing or upcoming.',
    confirmLabel: 'Delete',
  );
  if (!confirmed || !context.mounted) return;

  try {
    final message = await admin.deleteAccommodation(item.id);
    if (context.mounted) nToast(context, message);
  } catch (e) {
    if (context.mounted) {
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }
}

class _ReviewsSection extends StatefulWidget {
  final String accommodationId;

  const _ReviewsSection({required this.accommodationId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  late Future<List<AccommodationReview>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = context.read<AdminProvider>().reviewsFor(widget.accommodationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<AccommodationReview>>(
      future: _reviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpace.x4),
            child: NLoading(label: 'Loading reviews…'),
          );
        }

        if (snapshot.hasError) {
          return Text(
            ApiResponseHandler.describe(snapshot.error!),
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          );
        }

        final reviews = snapshot.data ?? const <AccommodationReview>[];
        if (reviews.isEmpty) {
          return Text(
            'This property has no reviews yet.',
            style: theme.textTheme.bodySmall,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final review in reviews) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.customerDisplayName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x2),
                  Text('${review.rating}/10', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 4),
                  Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                      size: 11, color: AppColors.accent),
                  if (review.wouldRecommend) ...[
                    const SizedBox(width: AppSpace.x2),
                    const NTag('Recommends', variant: NTagVariant.outline),
                  ],
                ],
              ),
              if (review.comment.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(review.comment, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpace.x3),
            ],
          ],
        );
      },
    );
  }
}
