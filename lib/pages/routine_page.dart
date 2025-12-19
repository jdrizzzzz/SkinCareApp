import 'package:flutter/material.dart';
import 'package:skincare_project/pages/widgets/routine_steps_card.dart';
import '../models/product.dart';
import '../models/routine_step.dart';
import '../services/product_service.dart';
import '../utils/routine_defaults.dart';

import 'widgets/replace_product_sheet.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final ProductService _productService = ProductService();

  RoutineType _routineType = RoutineType.morning;

  Future<List<Product>>? _productsFuture;

  // lists for each moring/night
  late List<RoutineStep> _morningSteps;
  late List<RoutineStep> _nightSteps;

  List<RoutineStep> get _currentSteps =>
      _routineType == RoutineType.morning ? _morningSteps : _nightSteps;

  @override
  //setting state
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProducts(limit: 200);

    _morningSteps = buildMorningSteps();
    _nightSteps = buildNightSteps();
  }

  void _switchRoutine(RoutineType type) {
    setState(() => _routineType = type);
  }

  //Reorder the cards
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _currentSteps.removeAt(oldIndex);
      _currentSteps.insert(newIndex, item);
    });
  }

  Future<void> _openReplaceSheet(RoutineStep step) async {
    final products = await _productsFuture!;
    if (!mounted) return;

    final selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return ReplaceProductSheet(
          title: step.title,
          products: products,
          currentlySelected: step.selectedProduct,
        );
      },
    );

    if (selected != null) {
      setState(() => step.selectedProduct = selected);
    }
  }

  //Adding a new step
  void _addStep() {
    final newId = '${_routineType.name}_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _currentSteps.add(
        RoutineStep(
          id: newId,
          title: 'New Step',
          icon: Icons.add_circle_outline,
          cardColor: _routineType == RoutineType.morning
              ? const Color(0xFFF3D7D7)
              : const Color(0xFFE6E0F2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _routineType == RoutineType.morning
        ? 'My Morning Routine'
        : 'My Night Routine';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<RoutineType>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: _switchRoutine,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: RoutineType.morning,
                child: Row(
                  children: [
                    Icon(
                      _routineType == RoutineType.morning
                          ? Icons.check
                          : Icons.wb_sunny_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text('Morning routine'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: RoutineType.night,
                child: Row(
                  children: [
                    Icon(
                      _routineType == RoutineType.night
                          ? Icons.check
                          : Icons.nightlight_round,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text('Night routine'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _currentSteps.length,
              onReorder: _onReorder,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final step = _currentSteps[index];
                return RoutineStepCard(
                  key: ValueKey(step.id),
                  index: index,
                  step: step,

                  // Tap card
                  onTap: () => _openReplaceSheet(step),

                  // 3 dots - list of products
                  onMoreTap: () => _openReplaceSheet(step),

                  // Delete button (trash icon)
                  onDeleteTap: () {
                    setState(() {
                      _currentSteps.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFFD9CFCB), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),


      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.amber[500],
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.calendar_month), label: 'Routine'),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.shopping_basket), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          final routes = ['/weatherpage', '/routine', '/products', '/profile'];
          Navigator.pushNamed(context, routes[index]);
        },
      ),
    );
  }
}
