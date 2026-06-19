class Product {
  int? id;
  String name;
  String category;
  double buyingPrice;
  double sellingPrice;
  int quantity;
  String unit; // Piece, Kg, Litre
  String? barcode;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.unit,
    this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'unit': unit,
      'barcode': barcode,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      quantity: map['quantity'],
      unit: map['unit'],
      barcode: map['barcode'],
    );
  }
}
