import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/customer_screens/results_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:intl/intl.dart';

class SearchAccommodationsScreen extends StatefulWidget {
  const SearchAccommodationsScreen({super.key});

  @override
  SearchAccommodationsScreenState createState() =>
      SearchAccommodationsScreenState();
}

class SearchAccommodationsScreenState
    extends State<SearchAccommodationsScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  City? _selectedCity;
  Country? _selectedCountry;

  int numberOfGuests = 1;
  static const double _maxPrice = 500;

  RangeValues _priceRange = const RangeValues(0, _maxPrice);
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      await locationProvider.fetchCountries();
      // An empty dropdown has to say why it is empty.
      if (!mounted || locationProvider.error == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationProvider.error!)));
    });
  }

  bool get _nightsPicked =>
      fromDate != null && toDate != null && toDate!.isAfter(fromDate!);

  bool get _isValid => _selectedCity != null && _nightsPicked;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  Future<void> _runSearch() async {
    if (!_isValid) return;
    setState(() => _isSearching = true);
    final criteria = SearchCriteria(
      priceFrom: _priceRange.start,
      priceTo: _priceRange.end >= _maxPrice ? 0 : _priceRange.end,
      city: _selectedCity!.name,
      checkIn: fromDate!,
      checkOut: toDate!,
    );
    try {
      final firstPage = await Provider.of<SearchProvider>(
        context,
        listen: false,
      ).search(criteria);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(
            criteria: criteria,
            firstPage: firstPage,
            numberOfDays: toDate!.difference(fromDate!).inDays,
            checkIn: fromDate,
            checkOut: toDate,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countries = Provider.of<LocationProvider>(
      context,
      listen: true,
    ).countries;
    final cities = Provider.of<LocationProvider>(context, listen: true).cities;

    return Scaffold(
      appBar: AppBar(title: const Text('Search stays')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Where
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: _selectedCity != null
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WHERE', style: textTheme.labelSmall),
                          const SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<Country>(
                              initialValue: _selectedCountry,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Select country',
                              ),
                              icon: Icon(PhosphorIcons.caretDown(), size: 16),
                              onChanged: (Country? newValue) async {
                                setState(() {
                                  _selectedCountry = newValue;
                                  _selectedCity = null;
                                });
                                if (newValue != null) {
                                  await Provider.of<LocationProvider>(
                                    context,
                                    listen: false,
                                  ).fetchCities(newValue.id);
                                }
                              },
                              items: countries
                                  .map<DropdownMenuItem<Country>>(
                                    (country) => DropdownMenuItem(
                                      value: country,
                                      child: Text(country.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          if (_selectedCountry != null) ...[
                            const SizedBox(height: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<City>(
                                initialValue: _selectedCity,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Select city',
                                ),
                                icon: Icon(PhosphorIcons.caretDown(), size: 16),
                                onChanged: (City? newValue) {
                                  setState(() => _selectedCity = newValue);
                                },
                                items: cities
                                    .map<DropdownMenuItem<City>>(
                                      (city) => DropdownMenuItem(
                                        value: city,
                                        child: Text(city.name),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // When
                    InkWell(
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: fromDate != null
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppColors.radiusMd,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('WHEN', style: textTheme.labelSmall),
                                const SizedBox(height: 5),
                                Text(
                                  fromDate != null && toDate != null
                                      ? '${DateFormat('d MMM').format(fromDate!)} – ${DateFormat('d MMM').format(toDate!)} · ${toDate!.difference(fromDate!).inDays} nights'
                                      : 'Select dates',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Icon(
                              PhosphorIcons.calendarBlank(),
                              size: 19,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Guests
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GUESTS', style: textTheme.labelSmall),
                              const SizedBox(height: 5),
                              Text(
                                '$numberOfGuests guest${numberOfGuests > 1 ? 's' : ''}',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _CircleStep(
                                icon: PhosphorIcons.minus(),
                                enabled: numberOfGuests > 1,
                                onTap: () => setState(() {
                                  if (numberOfGuests > 1) numberOfGuests--;
                                }),
                              ),
                              const SizedBox(width: 12),
                              _CircleStep(
                                icon: PhosphorIcons.plus(),
                                enabled: true,
                                accent: true,
                                onTap: () => setState(() => numberOfGuests++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Price
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PRICE PER NIGHT',
                                style: textTheme.labelSmall,
                              ),
                              Text(
                                _priceRange.end >= _maxPrice
                                    ? '\$${_priceRange.start.round()} – \$${_maxPrice.round()}+'
                                    : '\$${_priceRange.start.round()} – \$${_priceRange.end.round()}',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.text,
                              overlayColor: AppColors.accent.withValues(
                                alpha: 0.15,
                              ),
                              trackHeight: 3,
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: _maxPrice,
                              divisions: 50,
                              onChanged: (values) =>
                                  setState(() => _priceRange = values),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: OutlinedButton.icon(
                onPressed: _isValid && !_isSearching ? _runSearch : null,
                icon: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(PhosphorIcons.magnifyingGlass(), size: 17),
                label: Text(
                  _isValid
                      ? 'Search stays'
                      : _selectedCity != null && !_nightsPicked
                      ? 'Check-out has to be at least one night later'
                      : 'Choose city and dates',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleStep extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool accent;
  final VoidCallback onTap;

  const _CircleStep({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: !enabled
                ? AppColors.border.withValues(alpha: 0.45)
                : accent
                ? AppColors.accent
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: !enabled
              ? AppColors.textTertiary.withValues(alpha: 0.45)
              : accent
              ? AppColors.accentText
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
