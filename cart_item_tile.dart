import 'package:flutter/material.dart';
import '../providers/bill_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cartItem.product.name),
      subtitle: Text('₹${cartItem.product.sellingPrice} x ${cartItem.quantity}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => onQuantityChanged(cartItem.quantity - 1),
          ),
          Text('${cartItem.quantity}'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onQuantityChanged(cartItem.quantity + 1),
          ),
        ],
      ),
    );
  }
}
