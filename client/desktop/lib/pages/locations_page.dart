import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/models/location_model.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/geocoding_service.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Lokacije — CRUD nad referentnim podacima "države" i "gradovi".
class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NPageHeader(
            title: 'Locations',
            subtitle: 'Countries, cities and exact property locations.',
            actions: [
              OutlinedButton.icon(
                onPressed: context.read<LocationProvider>().loadAll,
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          NTabs(
            labels: const ['Countries', 'Cities', 'Locations'],
            selected: _tab,
            onChanged: (index) => setState(() => _tab = index),
          ),
          const SizedBox(height: AppSpace.x4),
          switch (_tab) {
            0 => const _CountriesTab(),
            1 => const _CitiesTab(),
            _ => const _LocationsTab(),
          },
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Države
// ═══════════════════════════════════════════════════════════════════════════

class _CountriesTab extends StatefulWidget {
  const _CountriesTab();

  @override
  State<_CountriesTab> createState() => _CountriesTabState();
}

class _CountriesTabState extends State<_CountriesTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<LocationProvider>().countryQuery;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final provider = context.read<LocationProvider>();

    try {
      final message = await provider.addCountry(_nameController.text);
      if (!mounted) return;
      // `addCountry` interno ponovo učitava listu, pa nema potrebe za ručnim osvježavanjem.
      _nameController.clear();
      _formKey.currentState?.reset();
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _edit(Country country) async {
    final provider = context.read<LocationProvider>();
    final newName = await showDialog<String>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _NameDialog(
        title: 'Edit country',
        label: 'Country name',
        initialValue: country.name,
        hint: 'e.g. North Macedonia',
      ),
    );
    if (newName == null || !mounted) return;

    try {
      final message =
          await provider.updateCountry(id: country.id, name: newName);
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  Future<void> _delete(Country country) async {
    final confirmed = await nConfirm(
      context,
      title: 'Delete country',
      message: 'Country "${country.name}" will be deleted.\n\n'
          'If any city is still linked to this country, the server will '
          'reject the deletion and explain the reason.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<LocationProvider>();
    try {
      final message = await provider.deleteCountry(country.id);
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final countries = provider.filteredCountries;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NSearchField(
                    controller: _searchController,
                    hint: 'Search countries by name',
                    onChanged: provider.setCountryQuery,
                  ),
                  const SizedBox(height: AppSpace.x4),
                  NCard(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: provider.isLoadingCountries && countries.isEmpty
                        ? const NLoading(label: 'Loading countries…')
                        : provider.countriesError != null
                            ? NErrorState(
                                message: provider.countriesError!,
                                onRetry: provider.loadCountries,
                              )
                            : _CountryTable(
                                countries: countries,
                                provider: provider,
                                onEdit: _edit,
                                onDelete: _delete,
                              ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.x4),
            SizedBox(width: 300, child: _buildAddForm(context)),
          ],
        );
      },
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return NCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const NKicker('New country'),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Name',
              child: TextFormField(
                controller: _nameController,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. North Macedonia',
                ),
                validator: _validateName,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            OutlinedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add country'),
            ),
            const SizedBox(height: AppSpace.x4),
            Text(
              'A country used by at least one city cannot be deleted.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// `Country.Name` je na backendu `[MaxLength(50)]` sa unique indeksom.
String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Name is required.';
  if (text.length < 2) return 'Name must have at least 2 characters.';
  if (text.length > 50) return 'Name may have at most 50 characters.';
  if (!RegExp(r"^[\p{L}][\p{L}\s\-'’.]*$", unicode: true).hasMatch(text)) {
    return 'Only letters, spaces, hyphens and apostrophes are allowed.';
  }
  return null;
}

class _CountryTable extends StatelessWidget {
  final List<Country> countries;
  final LocationProvider provider;
  final Future<void> Function(Country) onEdit;
  final Future<void> Function(Country) onDelete;

  const _CountryTable({
    required this.countries,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return NTable(
      columns: const [
        NColumn('Country', flex: 3),
        NColumn('Cities', width: 110, align: Alignment.centerRight),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: countries.length,
      empty: const NEmptyState(
        message: 'No countries entered yet. Add the first one through the form on the right.',
      ),
      cellsBuilder: (context, index) {
        final country = countries[index];
        final blockedReason = provider.deleteBlockedReason(country);

        return [
          Text(country.name, overflow: TextOverflow.ellipsis),
          NMutedCell('${provider.cityCountFor(country)}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Edit name',
                onPressed: () => onEdit(country),
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Delete country',
                color: AppColors.error,
                disabledReason: blockedReason,
                onPressed: () => onDelete(country),
              ),
            ],
          ),
        ];
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Gradovi
// ═══════════════════════════════════════════════════════════════════════════

class _CitiesTab extends StatefulWidget {
  const _CitiesTab();

  @override
  State<_CitiesTab> createState() => _CitiesTabState();
}

class _CitiesTabState extends State<_CitiesTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  Country? _selectedCountry;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<LocationProvider>().cityQuery;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCountry == null) return;

    setState(() => _submitting = true);
    final provider = context.read<LocationProvider>();

    try {
      final message = await provider.addCity(
        name: _nameController.text,
        countryId: _selectedCountry!.id,
      );
      if (!mounted) return;
      _nameController.clear();
      _formKey.currentState?.reset();
      setState(() => _selectedCountry = null);
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _editCity(City city, LocationProvider provider) async {
    final result = await showDialog<({String name, String countryId})>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _CityDialog(city: city, countries: provider.countries),
    );
    if (result == null || !mounted) return;

    try {
      final message = await provider.updateCity(
        id: city.id,
        name: result.name,
        countryId: result.countryId,
      );
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  Future<void> _deleteCity(City city, LocationProvider provider) async {
    final confirmed = await nConfirm(
      context,
      title: 'Delete city',
      message: 'Delete city "${city.name}"? The server will reject the deletion if the '
          'city has locations with properties on them.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    try {
      final message = await provider.deleteCity(city.id);
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final cities = provider.filteredCities;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: NSearchField(
                          controller: _searchController,
                          hint: 'Search cities by name',
                          onChanged: provider.setCityQuery,
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      NDropdown<String?>(
                        width: 220,
                        value: provider.cityCountryFilter,
                        hint: 'All countries',
                        onChanged: provider.setCityCountryFilter,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('All countries')),
                          for (final country in provider.countries)
                            DropdownMenuItem<String?>(
                              value: country.id,
                              child: Text(country.name),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.x4),
                  NCard(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: provider.isLoadingCities && cities.isEmpty
                        ? const NLoading(label: 'Loading cities…')
                        : provider.citiesError != null
                            ? NErrorState(
                                message: provider.citiesError!,
                                onRetry: provider.loadCities,
                              )
                            : _CityTable(
                                cities: cities,
                                onEdit: (city) => _editCity(city, provider),
                                onDelete: (city) =>
                                    _deleteCity(city, provider),
                              ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.x4),
            SizedBox(width: 300, child: _buildAddForm(context, provider)),
          ],
        );
      },
    );
  }

  Widget _buildAddForm(BuildContext context, LocationProvider provider) {
    final hasCountries = provider.countries.isNotEmpty;

    return NCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const NKicker('New city'),
            const SizedBox(height: AppSpace.x4),

            if (!hasCountries)
              NEmptyState(
                icon: PhosphorIcons.lockSimple(),
                message: 'First enter at least one country — '
                    'a city must be linked to a country.',
              )
            else ...[
              NField(
                label: 'Name',
                child: TextFormField(
                  controller: _nameController,
                  enabled: !_submitting,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(hintText: 'e.g. Zagreb'),
                  validator: _validateName,
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              NField(
                label: 'Country',
                child: DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: Icon(PhosphorIcons.caretDown(), size: 14),
                  style: Theme.of(context).textTheme.bodyMedium,
                  hint: Text(
                    'Select a country',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  items: [
                    for (final country in provider.countries)
                      DropdownMenuItem<Country>(
                        value: country,
                        child: Text(country.name),
                      ),
                  ],
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _selectedCountry = value),
                  validator: (value) =>
                      value == null ? 'Select a country from the list.' : null,
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              OutlinedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add city'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CityTable extends StatelessWidget {
  final List<City> cities;
  final void Function(City city) onEdit;
  final void Function(City city) onDelete;

  const _CityTable({
    required this.cities,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return NTable(
      columns: const [
        NColumn('City', flex: 3),
        NColumn('Country', flex: 3),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: cities.length,
      empty: const NEmptyState(
        message: 'No cities entered yet.',
      ),
      cellsBuilder: (context, index) {
        final city = cities[index];
        return [
          Text(city.name, overflow: TextOverflow.ellipsis),
          NMutedCell(city.countryName.isEmpty ? '—' : city.countryName),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Edit city',
                onPressed: () => onEdit(city),
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Delete city',
                color: AppColors.error,
                onPressed: () => onDelete(city),
              ),
            ],
          ),
        ];
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Dijalog za izmjenu naziva
// ═══════════════════════════════════════════════════════════════════════════

class _NameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String hint;

  const _NameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.hint,
  });

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(title: widget.title),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: widget.label,
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(hintText: widget.hint),
                    validator: _validateName,
                  ),
                ),
                const SizedBox(height: AppSpace.x8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityDialog extends StatefulWidget {
  final City city;
  final List<Country> countries;

  const _CityDialog({required this.city, required this.countries});

  @override
  State<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends State<_CityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  Country? _country;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.city.name);
    for (final country in widget.countries) {
      if (country.id == widget.city.countryId) {
        _country = country;
        break;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((name: _name.text.trim(), countryId: _country!.id));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const NDialogHeader(
                  title: 'Edit city',
                  subtitle: 'A city can be renamed and moved to another country.',
                ),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: 'City name',
                  child: TextFormField(
                    controller: _name,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'e.g. Banja Luka'),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'City name is required and must have 2 to 50 characters.';
                      }
                      if (text.length < 2 || text.length > 50) {
                        return 'City name must have between 2 and 50 characters.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'Country',
                  child: DropdownButtonFormField<Country>(
                    initialValue: _country,
                    isExpanded: true,
                    items: [
                      for (final country in widget.countries)
                        DropdownMenuItem<Country>(
                          value: country,
                          child: Text(country.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _country = value),
                    validator: (value) =>
                        value == null ? 'Select a country from the list.' : null,
                  ),
                ),
                const SizedBox(height: AppSpace.x6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: AppSpace.x3),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Lokacije
// ═══════════════════════════════════════════════════════════════════════════

class _LocationsTab extends StatefulWidget {
  const _LocationsTab();

  @override
  State<_LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<_LocationsTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<LocationProvider>().locationQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm(LocationProvider provider, {Location? location}) async {
    final message = await showDialog<String>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _LocationFormDialog(
        provider: provider,
        location: location,
        cities: provider.cities,
      ),
    );
    if (message != null && mounted) nToast(context, message);
  }

  Future<void> _delete(LocationProvider provider, Location location) async {
    final confirmed = await nConfirm(
      context,
      title: 'Delete location',
      message: location.accommodationCount == 0
          ? 'Delete location "${location.address}"? This action cannot be undone.'
          : 'Location "${location.address}" has '
              '${location.accommodationCount} properties on it. The server will '
              'reject the deletion until those properties are moved.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    try {
      final message = await provider.deleteLocation(location.id);
      if (!mounted) return;
      nToast(context, message);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final locations = provider.filteredLocations;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: NSearchField(
                    controller: _searchController,
                    hint: 'Search locations by address',
                    onChanged: provider.setLocationQuery,
                  ),
                ),
                const SizedBox(width: AppSpace.x3),
                NDropdown<String?>(
                  width: 220,
                  value: provider.locationCityFilter,
                  hint: 'All cities',
                  onChanged: provider.setLocationCityFilter,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('All cities')),
                    for (final city in provider.cities)
                      DropdownMenuItem<String?>(
                        value: city.id,
                        child: Text(city.name),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpace.x3),
                OutlinedButton.icon(
                  onPressed: provider.cities.isEmpty
                      ? null
                      : () => _openForm(provider),
                  icon: Icon(PhosphorIcons.plus(), size: 14),
                  label: const Text('New location'),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x4),
            NCard(
              padding: EdgeInsets.zero,
              clip: true,
              child: provider.isLoadingLocations && locations.isEmpty
                  ? const NLoading(label: 'Loading locations…')
                  : provider.locationsError != null
                      ? NErrorState(
                          message: provider.locationsError!,
                          onRetry: provider.loadLocations,
                        )
                      : NTable(
                          columns: const [
                            NColumn('Address', flex: 3),
                            NColumn('City, country', flex: 3),
                            NColumn('Coordinates', width: 180),
                            NColumn('Properties', width: 110,
                                align: Alignment.centerRight),
                            NColumn('', width: 76, align: Alignment.centerRight),
                          ],
                          rowCount: locations.length,
                          empty: const NEmptyState(
                            message: 'No locations entered yet.',
                          ),
                          cellsBuilder: (context, index) {
                            final location = locations[index];
                            return [
                              Text(location.address,
                                  overflow: TextOverflow.ellipsis),
                              NMutedCell(location.placeLabel),
                              NMutedCell(location.coordinatesLabel),
                              NMutedCell('${location.accommodationCount}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  NIconAction(
                                    icon: PhosphorIcons.pencilSimple(),
                                    tooltip: 'Edit location',
                                    onPressed: () => _openForm(provider,
                                        location: location),
                                  ),
                                  NIconAction(
                                    icon: PhosphorIcons.trash(),
                                    tooltip: 'Delete location',
                                    color: AppColors.error,
                                    onPressed: () => _delete(provider, location),
                                  ),
                                ],
                              ),
                            ];
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _LocationFormDialog extends StatefulWidget {
  final LocationProvider provider;
  final Location? location;
  final List<City> cities;

  const _LocationFormDialog({
    required this.provider,
    required this.cities,
    this.location,
  });

  @override
  State<_LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<_LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;

  City? _city;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.location != null;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(text: widget.location?.address ?? '');
    _latitude = widget.location?.latitude;
    _longitude = widget.location?.longitude;
    for (final city in widget.cities) {
      if (city.id == widget.location?.cityId) {
        _city = city;
        break;
      }
    }
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickCoordinates() async {
    final result = await showDialog<GeocodeResult>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _CoordinatePickerDialog(
        initialQuery: _address.text.trim().isEmpty
            ? (_city?.name ?? '')
            : '${_address.text.trim()}, ${_city?.name ?? ''}',
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_latitude == null || _longitude == null) {
      setState(() => _error = 'Select coordinates using the address search.');
      return;
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);

    try {
      final message = _isEdit
          ? await widget.provider.updateLocation(
              id: widget.location!.id,
              address: _address.text,
              latitude: _latitude!,
              longitude: _longitude!,
              cityId: _city!.id,
            )
          : await widget.provider.addLocation(
              address: _address.text,
              latitude: _latitude!,
              longitude: _longitude!,
              cityId: _city!.id,
            );
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
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(
                  title: _isEdit ? 'Edit location' : 'New location',
                  subtitle: 'Coordinates are chosen via address search, not typed in.',
                ),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: 'Address',
                  child: TextFormField(
                    controller: _address,
                    autofocus: true,
                    enabled: !_saving,
                    decoration:
                        const InputDecoration(hintText: 'e.g. Zmaja od Bosne 4'),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 5 || text.length > 50) {
                        return 'Address is required and must have between 5 and 50 '
                            'characters.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'City',
                  child: DropdownButtonFormField<City>(
                    initialValue: _city,
                    isExpanded: true,
                    items: [
                      for (final city in widget.cities)
                        DropdownMenuItem<City>(
                          value: city,
                          child: Text('${city.name}, ${city.countryName}'),
                        ),
                    ],
                    onChanged:
                        _saving ? null : (value) => setState(() => _city = value),
                    validator: (value) =>
                        value == null ? 'Select a city from the list.' : null,
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'Coordinates',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _latitude == null || _longitude == null
                              ? 'Not selected'
                              : '${_latitude!.toStringAsFixed(5)}, '
                                  '${_longitude!.toStringAsFixed(5)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _pickCoordinates,
                        icon: Icon(PhosphorIcons.mapPin(), size: 14),
                        label: const Text('Find on map'),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpace.x4),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpace.x6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: AppSpace.x3),
                    OutlinedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Adresa ide geokoderu, a korisnik bira jedan od ponuđenih rezultata.
class _CoordinatePickerDialog extends StatefulWidget {
  final String initialQuery;

  const _CoordinatePickerDialog({required this.initialQuery});

  @override
  State<_CoordinatePickerDialog> createState() =>
      _CoordinatePickerDialogState();
}

class _CoordinatePickerDialogState extends State<_CoordinatePickerDialog> {
  final _service = GeocodingService();
  late final TextEditingController _query;

  List<GeocodeResult> _results = const [];
  bool _searching = false;
  String? _error;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searching) return;
    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final results = await _service.search(_query.text);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    } on GeocodingException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Address search failed. Please try again.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const NDialogHeader(
                title: 'Select coordinates',
                subtitle: 'Enter an address or place name, then select a result.',
              ),
              const SizedBox(height: AppSpace.x4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                          hintText: 'e.g. Zmaja od Bosne 4, Sarajevo'),
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  OutlinedButton(
                    onPressed: _searching ? null : _search,
                    child: _searching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Search'),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpace.x3),
                Text(
                  _error!,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpace.x4),
              Flexible(
                child: _results.isEmpty
                    ? Text(
                        _searched
                            ? 'No location was found for that query.'
                            : 'Search results will be shown here.',
                        style: theme.textTheme.bodySmall,
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpace.x2),
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          return ListTile(
                            dense: true,
                            title: Text(result.displayName,
                                style: theme.textTheme.bodyMedium),
                            subtitle: Text(
                              '${result.latitude.toStringAsFixed(5)}, '
                              '${result.longitude.toStringAsFixed(5)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => Navigator.of(context).pop(result),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpace.x4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
