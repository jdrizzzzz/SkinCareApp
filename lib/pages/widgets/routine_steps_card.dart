import 'package:flutter/material.dart';
import '../../models/routine_step.dart';

class RoutineStepCard extends StatelessWidget {
  final int index;
  final RoutineStep step;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final VoidCallback onDeleteTap;

  const RoutineStepCard({
    super.key,
    required this.index,
    required this.step,
    required this.onTap,
    required this.onMoreTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final productName = step.selectedProduct == null
        ? 'Select a product'
        : (step.selectedProduct!.name ?? 'Selected product');

    final subtitleStyle = TextStyle(
      color: Colors.black.withOpacity(0.55),
      fontSize: 12,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Material(
        color: step.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [

                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ),

                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(step.icon, color: Colors.black87),
                ),

                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productName,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Delete button for cards
                IconButton(
                  tooltip: 'Delete step',
                  onPressed: onDeleteTap,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),

                // 3 dots - opening product list
                IconButton(
                  tooltip: 'Replace product',
                  onPressed: onMoreTap,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
