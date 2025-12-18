import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

//Storing if theyre in the "cart" or not
class _ProductCardState extends State<ProductCard> {
  bool isInMorningRoutine = false;
  bool isInNightRoutine = false;

  //UI panel for morning or night option (card for when + is clicked)
  void _openRoutineMenu(BuildContext context) {
    showModalBottomSheet(   //makes user interact with the popup
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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

                // Morning routine toggle
                ElevatedButton.icon(
                  icon: Icon(
                    isInMorningRoutine
                        ? Icons.remove_circle_outline
                        : Icons.wb_sunny_outlined,
                  ),
                  label: Text(
                    isInMorningRoutine
                        ? 'Remove from Morning Routine'
                        : 'Add to Morning Routine',
                  ),
                  onPressed: () {
                    setState(() {
                      isInMorningRoutine = !isInMorningRoutine;
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),

                // Night routine toggle
                ElevatedButton.icon(
                  icon: Icon(
                    isInNightRoutine
                        ? Icons.remove_circle_outline
                        : Icons.nightlight_round,
                  ),
                  label: Text(
                    isInNightRoutine
                        ? 'Remove from Night Routine'
                        : 'Add to Night Routine',
                  ),
                  onPressed: () {
                    setState(() {
                      isInNightRoutine = !isInNightRoutine;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdded = isInMorningRoutine || isInNightRoutine;

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
          // Image placeholder + add/remove button
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
          const SizedBox(height: 8),

          Row(
            children: [
              if (widget.product.rank != null)
                Chip(
                  label: Text('${widget.product.rank!.toStringAsFixed(1)} ★'),
                ),
              const SizedBox(width: 8),
              if (widget.product.price != null)
                Text('\$${widget.product.price!.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}
