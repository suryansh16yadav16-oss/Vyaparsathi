import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductForm(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                productProvider.searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Slidable(
                  key: Key(product.id.toString()),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showProductForm(context, product),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(context, product.id!),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.quantity} ${product.unit} | ₹${product.sellingPrice}'),
                    trailing: Text(product.category),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, Product? existingProduct) {
    final isEditing = existingProduct != null;
    final nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final categoryCtrl = TextEditingController(text: existingProduct?.category ?? '');
    final buyingCtrl = TextEditingController(text: existingProduct?.buyingPrice.toString() ?? '');
    final sellingCtrl = TextEditingController(text: existingProduct?.sellingPrice.toString() ?? '');
    final qtyCtrl = TextEditingController(text: existingProduct?.quantity.toString() ?? '');
    final unitCtrl = TextEditingController(text: existingProduct?.unit ?? '');
    final barcodeCtrl = TextEditingController(text: existingProduct?.barcode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Product' : 'Add Product',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: buyingCtrl, decoration: const InputDecoration(labelText: 'Buying Price'), keyboardType: TextInputType.number),
                TextField(controller: sellingCtrl, decoration: const InputDecoration(labelText: 'Selling Price'), keyboardType: TextInputType.number),
                TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
                TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (Piece/Kg/Litre)')),
                TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Barcode (optional)')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final product = Product(
                      id: existingProduct?.id,
                      name: nameCtrl.text,
                      category: categoryCtrl.text,
                      buyingPrice: double.parse(buyingCtrl.text),
                      sellingPrice: double.parse(sellingCtrl.text),
                      quantity: int.parse(qtyCtrl.text),
                      unit: unitCtrl.text,
                      barcode: barcodeCtrl.text.isEmpty ? null : barcodeCtrl.text,
                    );
                    final provider = Provider.of<ProductProvider>(context, listen: false);
                    if (isEditing) {
                      await provider.updateProduct(product);
                    } else {
                      await provider.addProduct(product);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
