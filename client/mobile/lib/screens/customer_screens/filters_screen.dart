import 'package:ebooking/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Filters returned to the caller on Apply. Only fields backed by real data
/// on AccommodationGET (price, rating) are actually applied to results --
/// type/meals/room-facility chips stay visual-only until the backend
/// exposes matching fields to filter by, same as before this redesign.
class AccommodationFilters {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const AccommodationFilters({this.minPrice, this.maxPrice, this.minRating});
}

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  FiltersPageState createState() => FiltersPageState();
}

class FiltersPageState extends State<FiltersPage> {
  RangeValues priceRange = const RangeValues(0, 500);
  double minRating = 0;
  final Set<String> accommodationTypes = {};
  final Set<String> meals = {};
  final Set<String> roomFacilities = {};

  static const _typeOptions = [
    'House', 'Hotels', 'Resorts', 'Apartments', 'Villas', 'Hostels', 'Cottages', 'Penthouse',
  ];
  static const _mealOptions = ['Breakfast Included', 'Kitchen Facilities'];
  static const _facilityOptions = [
    'Bathtub', 'Balcony', 'Private Bathroom', 'AC', 'Terrace', 'Kitchen',
    'Private pool', 'Coffee Machine', 'View', 'Sea view', 'Washing Machine',
    'Spa Tub', 'Soundproof',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                Text('\$${priceRange.start.round()} \u2013 \$${priceRange.end.round()}',
                    style: textTheme.bodyMedium),
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
                max: 500,
                divisions: 50,
                onChanged: (values) => setState(() => priceRange = values),
              ),
            ),
            const SizedBox(height: 12),
            Text('MINIMUM RATING', style: textTheme.labelSmall),
            Row(
              children: [
                Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                    size: 15, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(minRating == 0 ? 'Any' : minRating.toStringAsFixed(1),
                    style: textTheme.bodyMedium),
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
                max: 10,
                divisions: 10,
                onChanged: (value) => setState(() => minRating = value),
              ),
            ),
            const SizedBox(height: 20),
            _section('TYPE OF ACCOMMODATION', _typeOptions, accommodationTypes),
            const SizedBox(height: 20),
            _section('MEALS', _mealOptions, meals),
            const SizedBox(height: 20),
            _section('ROOM FACILITIES', _facilityOptions, roomFacilities),
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

  Widget _section(String label, List<String> options, Set<String> selected) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 9),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final option in options)
              _Chip(
                label: option,
                selected: selected.contains(option),
                onTap: () => setState(() {
                  if (!selected.add(option)) selected.remove(option);
                }),
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

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : null,
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: selected ? AppColors.accentText : AppColors.text)),
      ),
    );
  }
}
