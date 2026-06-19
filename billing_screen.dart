import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/bill_provider.dart';
import '../models/product.dart';
import '../widgets/cart_item_tile.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

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
    final billProvider = Provider.of<BillProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => billProvider.clearCart(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Search product...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          productProvider.searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => productProvider.searchProducts(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('₹${product.sellingPrice} | Stock: ${product.quantity} ${product.unit}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: product.quantity > 0
                        ? () {
                            billProvider.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${product.name} to cart')),
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
          // Cart summary
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (billProvider.cart.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: billProvider.cart.length,
                      itemBuilder: (context, index) {
                        final cartItem = billProvider.cart[index];
                        return CartItemTile(
                          cartItem: cartItem,
                          onQuantityChanged: (newQty) {
                            billProvider.updateCartQuantity(cartItem.product.id!, newQty);
                          },
                        );
                      },
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal: ₹${billProvider.subtotal.toStringAsFixed(2)}'),
                    Text('Grand Total: ₹${billProvider.grandTotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: billProvider.cart.isEmpty
                      ? null
                      : () async {
                          try {
                            await billProvider.generateBill(productProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bill generated successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  icon: const Icon(Icons.receipt),
                  label: const Text('Generate Bill'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
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
