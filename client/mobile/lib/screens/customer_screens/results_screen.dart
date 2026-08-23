import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/filters_screen.dart';
import 'package:ebooking/widgets/results_container.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class SearchResultPage extends StatefulWidget {
  final List<AccommodationGET> accommodations;
  final int numberOfDays;

  const SearchResultPage(
      {super.key, required this.accommodations, required this.numberOfDays});

  @override
  SearchResultsState createState() => SearchResultsState();
}

class SearchResultsState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(PhosphorIcons.arrowLeft(),
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Search results', style: textTheme.titleMedium),
                        Text(
                          '${widget.numberOfDays} nights · ${widget.accommodations.length} stays',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.accentTint,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FiltersPage()));
                  },
                  icon: Icon(PhosphorIcons.slidersHorizontal(), size: 14),
                  label: const Text('Filters'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.accommodations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(PhosphorIcons.magnifyingGlass(),
                                size: 32, color: AppColors.textTertiary),
                            const SizedBox(height: 14),
                            Text(
                              'No stays match this search',
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try widening your dates or price range.',
                              style: textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: widget.accommodations.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.divider),
                      ),
                      itemBuilder: (context, index) {
                        final accommodation = widget.accommodations[index];
                        final image = accommodation.images.images.isNotEmpty
                            ? accommodation.images.images.first
                            : null;
                        final total =
                            accommodation.pricePerNight * widget.numberOfDays;
                        return SearchResultContainer(
                          image: image,
                          propertyName: accommodation.name,
                          pricePerNight: accommodation.pricePerNight,
                          reviewScore: accommodation.reviewScore,
                          totalPrice: '\$${total.toStringAsFixed(0)}',
                          address: accommodation.location.address,
                          sleeps: accommodation.accommodationDetails.numberOfBeds,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccommodationDetailsScreen(
                                            accommodation: accommodation)));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}
