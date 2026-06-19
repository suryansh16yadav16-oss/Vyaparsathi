class BillItem {
  int? id;
  int billId;
  int productId;
  int quantity;
  double price; // selling price at the time of billing

  BillItem({
    this.id,
    required this.billId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billId': billId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      id: map['id'],
      billId: map['billId'],
      productId: map['productId'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
