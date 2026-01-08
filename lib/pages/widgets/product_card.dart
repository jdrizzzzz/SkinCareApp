import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/routine_store.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final RoutineStore _store = RoutineStore.instance;

  void _openRoutineMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {

        return ValueListenableBuilder<Map<String, String>>(
          valueListenable: _store.morningSelections,
          builder: (context, _, __) {
            return ValueListenableBuilder<Map<String, String>>(
              valueListenable: _store.nightSelections,
              builder: (context, __, ___) {
                final label = widget.product.label.trim();

                final isInMorning = _store.isInMorningForLabel(
                  label: label,
                  productId: widget.product.id,
                );

                final isInNight = _store.isInNightForLabel(
                  label: label,
                  productId: widget.product.id,
                );

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),

                        ElevatedButton.icon(
                          icon: Icon(
                            isInMorning
                                ? Icons.remove_circle_outline
                                : Icons.wb_sunny_outlined,
                          ),
                          label: Text(
                            isInMorning
                                ? 'Remove from Morning Routine'
                                : 'Add to Morning Routine',
                          ),
                          onPressed: () {
                            if (label.isEmpty) {
                              Navigator.pop(context);
                              return;
                            }

                            // Sync with routineStore (morning and night)
                            if (isInMorning) {
                              _store.removeMorning(label: label);
                            } else {
                              _store.setMorning(
                                label: label,
                                productId: widget.product.id,
                              );
                            }

                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 10),

                        ElevatedButton.icon(
                          icon: Icon(
                            isInNight
                                ? Icons.remove_circle_outline
                                : Icons.nightlight_round,
                          ),
                          label: Text(
                            isInNight
                                ? 'Remove from Night Routine'
                                : 'Add to Night Routine',
                          ),
                          onPressed: () {
                            if (label.isEmpty) {
                              Navigator.pop(context);
                              return;
                            }

                            if (isInNight) {
                              _store.removeNight(label: label);
                            } else {
                              _store.setNight(
                                label: label,
                                productId: widget.product.id,
                              );
                            }

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: _store.morningSelections,
      builder: (context, _, __) {
        return ValueListenableBuilder<Map<String, String>>(
          valueListenable: _store.nightSelections,
          builder: (context, __, ___) {

            final bool isAdded = _store.isInMorning(widget.product.id) ||
                _store.isInNight(widget.product.id);

            final label = widget.product.label.trim();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.spa, color: Colors.black26, size: 40),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () => _openRoutineMenu(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isAdded ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isAdded ? Icons.check : Icons.add,
                              size: 20,
                              color: isAdded ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    widget.product.brand,
                    style: const TextStyle(color: Colors.black54),
                  ),

                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(label),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      if (widget.product.rank != null)
                        Chip(label: Text('${widget.product.rank!.toStringAsFixed(1)} ★')),
                      const SizedBox(width: 8),
                      if (widget.product.price != null)
                        Text('\$${widget.product.price!.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
