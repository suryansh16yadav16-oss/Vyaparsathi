import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;

  Future<void> loadProducts() async {
    _products = await _db.getAllProducts();
    _filteredProducts = [];
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _db.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _db.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await loadProducts();
  }

  void searchProducts(String query) async {
    if (query.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = await _db.searchProducts(query);
    }
    notifyListeners();
  }

  Future<Product?> getProductById(int id) async {
    return await _db.getProductById(id);
  }

  // Update quantity after billing
  Future<void> reduceStock(int productId, int quantity) async {
    final product = await _db.getProductById(productId);
    if (product != null) {
      final newQty = product.quantity - quantity;
      if (newQty < 0) throw Exception('Insufficient stock');
      await _db.updateProductQuantity(productId, newQty);
      await loadProducts();
    }
  }
}
