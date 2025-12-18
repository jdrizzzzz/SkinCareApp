
import 'package:flutter/material.dart';
import '../../models/product.dart';

//Creating each card for each product
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
          // Placeholder image
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

          const SizedBox(height: 12),

          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            product.brand,
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              if (product.rank != null)
                Chip(
                  label: Text('${product.rank!.toStringAsFixed(1)} ★'),
                ),
              const SizedBox(width: 8),
              if (product.price != null)
                Text('\$${product.price!.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}
