import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/widgets/suggestion_container.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<AccommodationGET> _items = [];
  int _page = 0;
  int _totalPages = 1;
  bool _loadingFirst = true;
  bool _loadingMore = false;
  String? _error;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirst();
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

  Future<void> _loadFirst() async {
    setState(() {
      _loadingFirst = true;
      _error = null;
    });
    try {
      final result = await Provider.of<AccommodationProvider>(
        context,
        listen: false,
      ).fetchNearbyAccommodationsPage(widget.latitude, widget.longitude);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _page = result.page;
        _totalPages = result.totalPages;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingFirst = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await Provider.of<AccommodationProvider>(
        context,
        listen: false,
      ).fetchNearbyAccommodationsPage(
        widget.latitude,
        widget.longitude,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...result.items];
        _page = result.page;
        _totalPages = result.totalPages;
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

  double _distanceKm(AccommodationGET accommodation) {
    return Geolocator.distanceBetween(
          widget.latitude,
          widget.longitude,
          accommodation.location.latitude,
          accommodation.location.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Near you')),
      body: _loadingFirst
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loadFirst,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(),
                      size: 32,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 14),
                    Text('Nothing nearby', style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'There are no accommodations within 10 km of where you '
                      'are right now.',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final accommodation = _items[index];
                return SuggestionContainer(
                  imageUrl: accommodation.firstImageUrl,
                  propertyName: accommodation.name,
                  pricePerNight: accommodation.pricePerNight,
                  reviewScore: accommodation.reviewScore,
                  address: accommodation.location.address,
                  distanceKm: _distanceKm(accommodation),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccommodationDetailsScreen(
                          accommodation: accommodation,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
