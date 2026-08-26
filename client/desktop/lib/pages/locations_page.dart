import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Lokacije — CRUD nad referentnim podacima "države" i "gradovi".
///
/// Upute 2.2: "Aplikacija mora posjedovati forme za upravljanje (CRUD) svim
/// referentnim podacima, kao što su države, gradovi, kategorije, tipovi,
/// statusi i slično, bez obzira na to da li su navedeni u prijavi."
///
/// ZAMJENJUJE `pages/countries/manage_country.dart`. Stara stranica:
///  - imala je samo države (gradova nije bilo nigdje u desktop klijentu);
///  - zvala je `static CountryHttpService` direktno iz widgeta, bez providera;
///  - `_deleteCountry` je brisao BEZ potvrde (Upute 6 traže confirmation
///    dialog za nepovratne akcije);
///  - svi `catch (e) { }` blokovi su bili prazni sa komentarom
///    "Handle or show error" — greške se nikad nisu prikazivale;
///  - forma se nije čistila nakon uspješnog unosa (Upute 6).
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
            title: 'Lokacije',
            subtitle: 'Države i gradovi koji se koriste u adresama smještaja.',
            actions: [
              OutlinedButton.icon(
                onPressed: context.read<LocationProvider>().loadAll,
                icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                label: const Text('Osvježi'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          NTabs(
            labels: const ['Države', 'Gradovi'],
            selected: _tab,
            onChanged: (index) => setState(() => _tab = index),
          ),
          const SizedBox(height: AppSpace.x4),
          if (_tab == 0) const _CountriesTab() else const _CitiesTab(),
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
      // Upute 6: nakon uspješnog spašavanja polja se automatski čiste,
      // a lista prikazuje novi zapis bez ručnog osvježavanja
      // (`addCountry` interno ponovo učitava listu).
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
        title: 'Izmjena države',
        label: 'Naziv države',
        initialValue: country.name,
        hint: 'npr. Sjeverna Makedonija',
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
      title: 'Brisanje države',
      message: 'Država "${country.name}" bit će obrisana.\n\n'
          'Ako je neki grad još uvijek vezan za ovu državu, server će '
          'odbiti brisanje i objasniti razlog.',
      confirmLabel: 'Obriši',
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
                    hint: 'Pretraga država po nazivu',
                    onChanged: provider.setCountryQuery,
                  ),
                  const SizedBox(height: AppSpace.x4),
                  NCard(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: provider.isLoadingCountries && countries.isEmpty
                        ? const NLoading(label: 'Učitavanje država…')
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
            const NKicker('Nova država'),
            const SizedBox(height: AppSpace.x4),
            NField(
              label: 'Naziv',
              child: TextFormField(
                controller: _nameController,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'npr. Sjeverna Makedonija',
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
                  : const Text('Dodaj državu'),
            ),
            const SizedBox(height: AppSpace.x4),
            Text(
              'Država koju koristi barem jedan grad ne može biti obrisana.',
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

/// Upute 4: poruka o grešci mora navesti format i ograničenja unosa.
/// `Country.Name` je na backendu `[MaxLength(50)]` sa unique indeksom.
String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Naziv je obavezan.';
  if (text.length < 2) return 'Naziv mora imati najmanje 2 znaka.';
  if (text.length > 50) return 'Naziv može imati najviše 50 znakova.';
  if (!RegExp(r"^[\p{L}][\p{L}\s\-'’.]*$", unicode: true).hasMatch(text)) {
    return 'Dozvoljena su samo slova, razmak, crtica i apostrof.';
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
        NColumn('Država', flex: 3),
        NColumn('Gradova', width: 110, align: Alignment.centerRight),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: countries.length,
      empty: const NEmptyState(
        message: 'Još nema unesenih država. Dodajte prvu kroz formu desno.',
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
                tooltip: 'Izmijeni naziv',
                onPressed: () => onEdit(country),
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Obriši državu',
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
                          hint: 'Pretraga gradova po nazivu',
                          onChanged: provider.setCityQuery,
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      NDropdown<String?>(
                        width: 220,
                        value: provider.cityCountryFilter,
                        hint: 'Sve države',
                        onChanged: provider.setCityCountryFilter,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Sve države')),
                          for (final country in provider.countries)
                            DropdownMenuItem<String?>(
                              value: country.name,
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
                        ? const NLoading(label: 'Učitavanje gradova…')
                        : provider.citiesError != null
                            ? NErrorState(
                                message: provider.citiesError!,
                                onRetry: provider.loadCities,
                              )
                            : _CityTable(cities: cities),
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
            const NKicker('Novi grad'),
            const SizedBox(height: AppSpace.x4),

            // Upute 6: "Ne dozvoliti otvaranje forme za unos ukoliko preduslovi
            // nisu ispunjeni (npr. FK tabela nema zapisa)." Grad bez države
            // nema smisla, pa je forma zaključana dok ne postoji bar jedna.
            if (!hasCountries)
              NEmptyState(
                icon: PhosphorIcons.lockSimple(),
                message: 'Prvo unesite barem jednu državu — '
                    'grad se mora vezati za državu.',
              )
            else ...[
              NField(
                label: 'Naziv',
                child: TextFormField(
                  controller: _nameController,
                  enabled: !_submitting,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(hintText: 'npr. Zagreb'),
                  validator: _validateName,
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              NField(
                label: 'Država',
                child: DropdownButtonFormField<Country>(
                  initialValue: _selectedCountry,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: Icon(PhosphorIcons.caretDown(), size: 14),
                  style: Theme.of(context).textTheme.bodyMedium,
                  hint: Text(
                    'Odaberite državu',
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
                      value == null ? 'Odaberite državu iz liste.' : null,
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
                    : const Text('Dodaj grad'),
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

  const _CityTable({required this.cities});

  @override
  Widget build(BuildContext context) {
    return NTable(
      columns: const [
        NColumn('Grad', flex: 3),
        NColumn('Država', flex: 3),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: cities.length,
      empty: const NEmptyState(
        message: 'Još nema unesenih gradova.',
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
              // Upute 6: nedostupna akcija ostaje vidljiva, ali disabled,
              // sa objašnjenjem. `CityController` još nema Update ni Delete.
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Izmijeni grad',
                disabledReason: 'Izmjena grada još nije dostupna — backend '
                    'nema PATCH /api/City/Update endpoint.',
                onPressed: null,
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Obriši grad',
                color: AppColors.error,
                disabledReason: 'Brisanje grada još nije dostupno — backend '
                    'nema DELETE /api/City/Delete endpoint.',
                onPressed: null,
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

/// ZAMJENJUJE `pages/countries/modals/edit_country_modal.dart`.
/// Stari modal je bio `showModalBottomSheet` (mobilni obrazac na desktopu),
/// nije imao validaciju, nije čekao rezultat (`showModalBottomSheet` bez
/// `await`), i gutao je greške u praznom `catch`-u.
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
                      child: const Text('Odustani'),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('Sačuvaj'),
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
