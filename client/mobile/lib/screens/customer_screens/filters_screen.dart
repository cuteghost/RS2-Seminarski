import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/catalog_provider.dart';
import 'package:ebooking/utils/rating.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class AccommodationFilters {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? typeId;
  final Set<String> amenityIds;

  const AccommodationFilters({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.typeId,
    this.amenityIds = const <String>{},
  });
}

class FiltersPage extends StatefulWidget {
  final AccommodationFilters? initial;

  const FiltersPage({super.key, this.initial});

  @override
  FiltersPageState createState() => FiltersPageState();
}

class FiltersPageState extends State<FiltersPage> {
  static const double _maxPrice = 500;

  late RangeValues priceRange;
  late double minRating;
  String? selectedTypeId;
  late Set<String> selectedAmenityIds;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    priceRange = RangeValues(
      initial?.minPrice ?? 0,
      initial?.maxPrice ?? _maxPrice,
    );
    minRating = initial?.minRating ?? 0;
    selectedTypeId = initial?.typeId;
    selectedAmenityIds = {...?initial?.amenityIds};
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final catalog = Provider.of<CatalogProvider>(context, listen: false);
      await catalog.load();
      if (!mounted || catalog.error == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(catalog.error!)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = Provider.of<CatalogProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Filters')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRICE PER NIGHT', style: textTheme.labelSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${priceRange.start.round()} \u2013 \$${priceRange.end.round()}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.text,
                trackHeight: 3,
              ),
              child: RangeSlider(
                values: priceRange,
                min: 0,
                max: _maxPrice,
                divisions: 50,
                onChanged: (values) => setState(() => priceRange = values),
              ),
            ),
            const SizedBox(height: 12),
            Text('MINIMUM RATING', style: textTheme.labelSmall),
            Row(
              children: [
                Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  size: 15,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  minRating == 0 ? 'Any' : formatRating(minRating),
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.text,
                trackHeight: 3,
              ),
              child: Slider(
                value: minRating,
                min: 0,
                max: maxRating.toDouble(),
                divisions: maxRating,
                onChanged: (value) => setState(() => minRating = value),
              ),
            ),
            const SizedBox(height: 20),
            _singleSection(
              'TYPE OF ACCOMMODATION',
              {for (final type in catalog.types) type.id: type.name},
              selectedTypeId,
              catalog,
              textTheme,
              (id) => setState(
                () => selectedTypeId = selectedTypeId == id ? null : id,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              'AMENITIES',
              {
                for (final amenity in catalog.amenities)
                  amenity.id: amenity.name,
              },
              selectedAmenityIds,
              catalog,
              textTheme,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    AccommodationFilters(
                      minPrice: priceRange.start,
                      maxPrice: priceRange.end,
                      minRating: minRating,
                      typeId: selectedTypeId,
                      amenityIds: selectedAmenityIds,
                    ),
                  );
                },
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    String label,
    Map<String, String> options,
    Set<String> selected,
    CatalogProvider catalog,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 9),
        if (options.isEmpty)
          Text(
            catalog.isLoading
                ? 'Loading...'
                : catalog.error ?? 'Nothing to filter on yet.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final option in options.entries)
                _Chip(
                  label: option.value,
                  selected: selected.contains(option.key),
                  onTap: () => setState(() {
                    if (!selected.add(option.key)) selected.remove(option.key);
                  }),
                ),
            ],
          ),
      ],
    );
  }

  Widget _singleSection(
    String label,
    Map<String, String> options,
    String? selected,
    CatalogProvider catalog,
    TextTheme textTheme,
    ValueChanged<String> onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 9),
        if (options.isEmpty)
          Text(
            catalog.isLoading
                ? 'Loading...'
                : catalog.error ?? 'Nothing to filter on yet.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final option in options.entries)
                _Chip(
                  label: option.value,
                  selected: selected == option.key,
                  onTap: () => onSelect(option.key),
                ),
            ],
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : null,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? AppColors.accentText : AppColors.text,
          ),
        ),
      ),
    );
  }
}
