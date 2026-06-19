import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../database/database_helper.dart';
import 'product_provider.dart';

class BillProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<CartItem> _cart = [];
  double _subtotal = 0.0;
  double _grandTotal = 0.0;

  List<CartItem> get cart => _cart;
  double get subtotal => _subtotal;
  double get grandTotal => _grandTotal;

  void addToCart(Product product, {int quantity = 1}) {
    final existing = _cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    final index = _cart.indexOf(existing);
    if (index != -1) {
      _cart[index] = CartItem(
        product: product,
        quantity: existing.quantity + quantity,
      );
    } else {
      _cart.add(CartItem(product: product, quantity: quantity));
    }
    _calculateTotals();
    notifyListeners();
  }

  void updateCartQuantity(int productId, int newQuantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = CartItem(
          product: _cart[index].product,
          quantity: newQuantity,
        );
      }
      _calculateTotals();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _subtotal = 0.0;
    _grandTotal = 0.0;
    notifyListeners();
  }

  void _calculateTotals() {
    _subtotal = _cart.fold(0.0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));
    _grandTotal = _subtotal; // No tax for now
  }

  Future<void> generateBill(ProductProvider productProvider) async {
    if (_cart.isEmpty) return;

    // Create bill
    final bill = Bill(
      billDate: DateTime.now(),
      subtotal: _subtotal,
      grandTotal: _grandTotal,
    );
    final billId = await _db.insertBill(bill);

    // Insert bill items and reduce stock
    for (var item in _cart) {
      final billItem = BillItem(
        billId: billId,
        productId: item.product.id!,
        quantity: item.quantity,
        price: item.product.sellingPrice,
      );
      await _db.insertBillItem(billItem);
      // Reduce stock
      await productProvider.reduceStock(item.product.id!, item.quantity);
    }

    clearCart();
    // Refresh products
    await productProvider.loadProducts();
  }

  // Get today's sales summary
  Future<Map<String, dynamic>> getTodaySales() async {
    final bills = await _db.getTodaysBills();
    double revenue = 0.0;
    int totalItems = 0;
    for (var bill in bills) {
      revenue += bill.grandTotal;
      final items = await _db.getBillItems(bill.id!);
      totalItems += items.fold(0, (sum, item) => sum + item.quantity);
    }
    return {
      'revenue': revenue,
      'billCount': bills.length,
      'productsSold': totalItems,
    };
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
