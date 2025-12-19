import 'package:flutter/material.dart';
import '../../models/product.dart';

class ReplaceProductSheet extends StatefulWidget {
  final String title;
  final List<Product> products;
  final Product? currentlySelected;

  const ReplaceProductSheet({
    super.key,
    required this.title,
    required this.products,
    required this.currentlySelected,
  });

  @override
  State<ReplaceProductSheet> createState() => _ReplaceProductSheetState();
}

class _ReplaceProductSheetState extends State<ReplaceProductSheet> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.products
        : widget.products.where((p) {
      final name = (p.name ?? '').toLowerCase();
      final brand = (p.brand ?? '').toLowerCase();
      return name.contains(query) || brand.contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replace ${widget.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search product name or brand...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6DEDA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6DEDA)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final isSelected = widget.currentlySelected?.id == p.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(p.name ?? 'Unnamed product'),
                    subtitle: Text(p.brand ?? ''),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
