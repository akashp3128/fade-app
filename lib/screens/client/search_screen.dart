import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/barber.dart';
import '../../providers/barber_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isMapView = false;
  String? _selectedSpecialty;
  double _minRating = 0;
  
  // Map control variables
  GoogleMapController? _mapController;
  bool _showSearchAreaButton = false;
  LatLng? _lastSearchCenter;

  @override
  void initState() {
    super.initState();
    // Initial search on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(barberSearchProvider.notifier).search();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _performSearch() {
    ref.read(barberSearchProvider.notifier).search(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          specialty: _selectedSpecialty,
          minRating: _minRating > 0 ? _minRating : null,
        );
    setState(() => _showSearchAreaButton = false);
  }

  void _onSearchAreaPressed() async {
    if (_mapController == null) return;
    final region = await _mapController!.getVisibleRegion();
    final center = LatLng(
      (region.northeast.latitude + region.southwest.latitude) / 2,
      (region.northeast.longitude + region.southwest.longitude) / 2,
    );
    
    // In a real app, we'd update the search location provider
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(barberSearchProvider);
    final specialties = ref.watch(specialtiesProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header / App Bar Replacement
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EXPLORE',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_isMapView ? Icons.list : Icons.map_outlined),
                                onPressed: () => setState(() => _isMapView = !_isMapView),
                              ),
                              IconButton(
                                icon: const Icon(Icons.tune),
                                onPressed: () => _showFilters(specialties),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, specialty...', 
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          if (!_isMapView) _performSearch();
                        },
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
    
                    const SizedBox(height: AppSpacing.md),
    
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedSpecialty == null,
                            onTap: () {
                              setState(() => _selectedSpecialty = null);
                              _performSearch();
                            },
                          ),
                          ...specialties.take(4).map((specialty) => _FilterChip(
                                label: specialty,
                                isSelected: _selectedSpecialty == specialty,
                                onTap: () {
                                  setState(() {
                                    _selectedSpecialty =
                                        _selectedSpecialty == specialty ? null : specialty;
                                  });
                                  _performSearch();
                                },
                              )),
                        ],
                      ),
                    ),
    
                    const SizedBox(height: AppSpacing.md),
    
                    // Results
                    Expanded(
                      child: _isMapView
                          ? _buildMapView()
                          : _buildListView(searchState),
                    ),
                  ],
                ),
              ),
              
              // "Search This Area" Floating Button
              if (_isMapView && _showSearchAreaButton)
                Positioned(
                  top: 160,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _onSearchAreaPressed,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Search this area'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.accent,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          side: const BorderSide(color: AppColors.accent, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
    
              // Floating Bottom Navigation
              Positioned(
                bottom: AppSpacing.lg,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: _buildFloatingBottomNav(context),
              ),
            ],
          ),
        );
      }
    
      Widget _buildFloatingBottomNav(BuildContext context) {
        final String location = GoRouterState.of(context).matchedLocation;
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(icon: Icons.home_rounded, isSelected: location == Routes.clientHome, onTap: () => context.go(Routes.clientHome)),
                  _NavItem(icon: Icons.search_rounded, isSelected: location == Routes.search, onTap: () {}),
                  _NavItem(icon: Icons.play_circle_outline_rounded, isSelected: location == Routes.feed, onTap: () => context.go(Routes.feed)),
                  _NavItem(icon: Icons.school_outlined, isSelected: location == Routes.academy, onTap: () => context.go(Routes.academy)),
                  _NavItem(icon: Icons.person_rounded, isSelected: location == Routes.clientProfile, onTap: () => context.go(Routes.clientProfile)),
                ],
              ),
            ),
          ),
        );
      }
    
    
  void _showAISuggestion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'AI Style Matcher',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Upload a photo of your face, and our AI will suggest the best haircuts based on your head shape and hair type.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Scan Now (Coming Soon)'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BarberSearchState searchState) {
    // 1. AI Suggestion Card
    final aiCard = Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAISuggestion,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Not sure what to get?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Let AI find your perfect style',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );

    if (searchState.isLoading && searchState.results.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        itemCount: 6, // +1 for AI card
        itemBuilder: (context, index) {
          if (index == 0) return aiCard;
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: _BarberSearchCardSkeleton(),
          );
        },
      );
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Error: ${searchState.error}'),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Column(
        children: [
          aiCard,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No barbers found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: searchState.results.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return aiCard;
        final barber = searchState.results[index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: _BarberSearchCard(
            barber: barber,
            onTap: () => context.push('${Routes.barberDetail}/${barber.id}'),
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    final searchState = ref.watch(barberSearchProvider);
    final shopsAsync = ref.watch(shopsProvider);

    // Chicago Coordinates
    const initialPosition = CameraPosition(
      target: LatLng(41.8781, -87.6298),
      zoom: 12,
    );

    return shopsAsync.when(
      data: (shops) {
        final markers = <Marker>{};

        // Add Shop Markers (💈 Pole Style Placeholder)
        for (final shop in shops) {
          if (shop.latitude != null && shop.longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId('shop_${shop.id}'),
                position: LatLng(shop.latitude!, shop.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: InfoWindow(
                  title: '💈 ${shop.name}',
                  snippet: 'Click to see barbers',
                  onTap: () => _showShopDetails(shop),
                ),
              ),
            );
          }
        }

        // Add Independent Barber Markers (🟡 Nano Dots)
        for (final barber in searchState.results) {
          if (barber.isIndependent && barber.latitude != null && barber.longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId('barber_${barber.id}'),
                position: LatLng(barber.latitude!, barber.longitude!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                infoWindow: InfoWindow(
                  title: barber.displayName,
                  snippet: barber.specialties.take(2).join(', '),
                  onTap: () => context.push('${Routes.barberDetail}/${barber.id}'),
                ),
              ),
            );
          }
        }

        return GoogleMap(
          initialCameraPosition: initialPosition,
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          style: _mapStyle, // Premium Dark Theme
          onMapCreated: (controller) {
            // Optional: Set dark map style if needed
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading map: $err')),
    );
  }

  void _showShopDetails(Shop shop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Text('💈', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (shop.address != null)
                          Text(
                            shop.address!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barbers at this location',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Claiming flow initiated...')),
                      );
                    },
                    icon: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.accent),
                    label: const Text('Claim Business', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final barbersAsync = ref.watch(barbersByShopProvider(shop.id));
                  return barbersAsync.when(
                    data: (barbers) => ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: barbers.length,
                      itemBuilder: (context, index) => _BarberSearchCard(
                        barber: barbers[index],
                        onTap: () {
                          Navigator.pop(context);
                          context.push('${Routes.barberDetail}/${barbers[index].id}');
                        },
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Dark Map Style (JSON)
  final String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  void _showFilters(List<String> specialties) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedSpecialty = null;
                        _minRating = 0;
                      });
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Specialty',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: specialties.map((specialty) {
                  final isSelected = _selectedSpecialty == specialty;
                  return FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedSpecialty = selected ? specialty : null;
                      });
                      setState(() {});
                    },
                    selectedColor: AppColors.accent.withOpacity(0.2),
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Minimum Rating: ${_minRating > 0 ? _minRating.toStringAsFixed(0) : 'Any'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < _minRating ? Icons.star : Icons.star_border,
                      color: index < _minRating
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setModalState(() {
                        _minRating = (index + 1).toDouble();
                      });
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _performSearch();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withOpacity(0.2),
        checkmarkColor: AppColors.accent,
      ),
    );
  }
}

class _BarberSearchCard extends StatelessWidget {
  final BarberProfile barber;
  final VoidCallback onTap;

  const _BarberSearchCard({
    required this.barber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lowestPrice = barber.services?.isNotEmpty == true
        ? barber.services!.map((s) => s.price).reduce((a, b) => a < b ? a : b)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: barber.avatarUrl != null
                    ? Hero(
                        tag: 'barber_avatar_${barber.id}',
                        child: Image.network(
                          barber.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          barber.displayName,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: barber.isAvailable
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          barber.isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            color: barber.isAvailable
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        barber.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        ' (${barber.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (barber.address != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            barber.address!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (barber.specialties.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      barber.specialties.join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lowestPrice != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'From \$${lowestPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberSearchCardSkeleton extends StatelessWidget {
  const _BarberSearchCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? AppColors.textOnAccent : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}
