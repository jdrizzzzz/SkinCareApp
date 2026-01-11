import 'package:flutter/material.dart';
import 'package:skincare_project/pages/widgets/product_card.dart';
import '../models/product.dart';
import '../services/recommendation_store.dart';
import '../services/products_cache.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late final Future<List<Product>> _productsFuture;
  final RecommendationStore _recommendationStore =
      RecommendationStore.instance;

  // Filter state
  String? _selectedBrand;                                 // null = All
  String? _selectedLabel;                                 // null = All (cleanser/toner/etc.)
  RangeValues _priceRange = const RangeValues(0, 200);    // will be clamped safely

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductsCache.instance.getProducts(limit: 200);
  }

  bool _matchesFilters(Product p) {
    // Brand filter
    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
      if (p.brand.trim() != _selectedBrand) return false;
    }

    // Label filter (cleanser/toner/moisturizer/etc.)
    if (_selectedLabel != null && _selectedLabel!.isNotEmpty) {
      if (p.label.trim() != _selectedLabel) return false;
    }

    // Price filter
    final price = p.price ?? 0;
    if (price < _priceRange.start || price > _priceRange.end) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Your Recommendations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [

            // FILTER PANEL
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(height: 120);
                  }

                  final products = snapshot.data ?? [];
                  final baseProducts = _recommendationStore.hasRecommendations
                      ? _recommendationStore.recommended
                      : products;

                  if (baseProducts.isEmpty) return const SizedBox.shrink();

                  // Brand options
                  final brands = baseProducts
                      .map((p) => p.brand.trim())
                      .where((b) => b.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();

                  // Label options (cleanser/toner/etc.)
                  final labels = baseProducts
                      .map((p) => p.label.trim())
                      .where((l) => l.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();

                  // Extract all valid prices (ignore null)
                  final prices = products
                      .map((p) => p.price)
                      .whereType<double>()
                      .toList();

                  double minPrice = 0;
                  double maxPrice = 200;

                  // Calculate real min/max from product data
                  if (prices.isNotEmpty) {
                    prices.sort();
                    minPrice = prices.first.floorToDouble();
                    maxPrice = prices.last.ceilToDouble();

                    // If all products have same price, expand max a bit so slider works
                    if (minPrice == maxPrice) {
                      maxPrice = minPrice + 10;
                    }
                  }

                  // Clamp current slider values inside the new min/max
                  final clampedStart =
                  _priceRange.start.clamp(minPrice, maxPrice).toDouble();
                  final clampedEnd =
                  _priceRange.end.clamp(minPrice, maxPrice).toDouble();

                  final safeRange = (clampedStart <= clampedEnd)
                      ? RangeValues(clampedStart, clampedEnd)
                      : RangeValues(clampedEnd, clampedStart);

                  // Update state AFTER build if needed (prevents RangeSlider crash)
                  if (safeRange != _priceRange) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _priceRange = safeRange;
                      });
                    });
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Brand + Clear
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedBrand,
                                decoration: const InputDecoration(
                                  labelText: 'Brand',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All brands'),
                                  ),
                                  ...brands.map((b) => DropdownMenuItem<String>(
                                    value: b,
                                    child: Text(b),
                                  )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBrand = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedBrand = null;
                                  _selectedLabel = null;
                                  _priceRange = RangeValues(minPrice, maxPrice);
                                });
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Label dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedLabel,
                          decoration: const InputDecoration(
                            labelText: 'Label (Cleanser, Toner, etc.)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All labels'),
                            ),
                            ...labels.map((l) => DropdownMenuItem<String>(
                              value: l,
                              child: Text(l),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLabel = value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Price slider
                        Text(
                          'Price: \$${safeRange.start.toStringAsFixed(0)} - \$${safeRange.end.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        RangeSlider(
                          values: safeRange,
                          min: minPrice,
                          max: maxPrice,
                          divisions: (maxPrice - minPrice).round().clamp(1, 200),
                          labels: RangeLabels(
                            '\$${safeRange.start.toStringAsFixed(0)}',
                            '\$${safeRange.end.toStringAsFixed(0)}',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // PRODUCT LIST
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final products = snapshot.data ?? [];
                  final baseProducts = _recommendationStore.hasRecommendations
                      ? _recommendationStore.recommended
                      : products;

                  if (baseProducts.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  final filteredProducts =
                  baseProducts.where(_matchesFilters).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text('No products match your filters.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.amber[500],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 2,
        onTap: (index) {
          final routes = ['/weatherpage', '/routine', '/products', '/profile'];
          Navigator.pushNamed(context, routes[index]);
        },
      ),
    );
  }
}
