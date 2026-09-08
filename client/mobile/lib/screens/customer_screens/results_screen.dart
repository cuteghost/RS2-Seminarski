import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/providers/search_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/customer_screens/filters_screen.dart';
import 'package:ebooking/widgets/results_container.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class SearchResultPage extends StatefulWidget {
  final SearchCriteria criteria;
  final Paged<AccommodationGET> firstPage;
  final int numberOfDays;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const SearchResultPage({
    super.key,
    required this.criteria,
    required this.firstPage,
    required this.numberOfDays,
    this.checkIn,
    this.checkOut,
  });

  @override
  SearchResultsState createState() => SearchResultsState();
}

class SearchResultsState extends State<SearchResultPage> {
  late SearchCriteria _criteria;
  late List<AccommodationGET> _items;
  late int _page;
  late int _totalPages;
  late int _totalCount;
  bool _loadingMore = false;
  AccommodationFilters? _filters;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _criteria = widget.criteria;
    _items = widget.firstPage.items;
    _page = widget.firstPage.page;
    _totalPages = widget.firstPage.totalPages;
    _totalCount = widget.firstPage.totalCount;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasMore => _page < _totalPages;

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = await Provider.of<SearchProvider>(
        context,
        listen: false,
      ).search(_criteria, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...next.items];
        _page = next.page;
        _totalPages = next.totalPages;
        _totalCount = next.totalCount;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  static const _maxSelectablePrice = 500.0;

  Future<void> _applyFilters(AccommodationFilters filters) async {
    final maxPrice = filters.maxPrice;
    final criteria = _criteria.copyWith(
      priceFrom: filters.minPrice,
      priceTo: maxPrice != null && maxPrice >= _maxSelectablePrice
          ? 0
          : maxPrice,
      accommodationTypeId: filters.typeId,
      minReviewScore: filters.minRating,
      amenityIds: filters.amenityIds,
    );
    setState(() {
      _filters = filters;
      _criteria = criteria;
      _loadingMore = true;
    });
    try {
      final firstPage = await Provider.of<SearchProvider>(
        context,
        listen: false,
      ).search(criteria);
      if (!mounted) return;
      setState(() {
        _items = firstPage.items;
        _page = firstPage.page;
        _totalPages = firstPage.totalPages;
        _totalCount = firstPage.totalCount;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

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
                    icon: Icon(
                      PhosphorIcons.arrowLeft(),
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Search results', style: textTheme.titleMedium),
                        Text(
                          '${widget.numberOfDays} nights · $_totalCount stays',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push<AccommodationFilters>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FiltersPage(initial: _filters),
                      ),
                    );
                    if (result != null) await _applyFilters(result);
                  },
                  icon: Icon(PhosphorIcons.slidersHorizontal(), size: 14),
                  label: const Text('Filters'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.magnifyingGlass(),
                              size: 32,
                              color: AppColors.textTertiary,
                            ),
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
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.divider),
                      ),
                      itemBuilder: (context, index) {
                        if (index >= _items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        final accommodation = _items[index];
                        final total =
                            accommodation.pricePerNight * widget.numberOfDays;
                        return SearchResultContainer(
                          imageUrl: accommodation.firstImageUrl,
                          propertyName: accommodation.name,
                          pricePerNight: accommodation.pricePerNight,
                          reviewScore: accommodation.reviewScore,
                          totalPrice: '\$${total.toStringAsFixed(0)}',
                          address: accommodation.location.address,
                          sleeps:
                              accommodation.accommodationDetails.numberOfBeds,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AccommodationDetailsScreen(
                                      accommodation: accommodation,
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                    ),
                              ),
                            );
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
