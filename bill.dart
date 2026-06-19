class Bill {
  int? id;
  DateTime billDate;
  double subtotal;
  double grandTotal;

  Bill({
    this.id,
    required this.billDate,
    required this.subtotal,
    required this.grandTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billDate': billDate.toIso8601String(),
      'subtotal': subtotal,
      'grandTotal': grandTotal,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      billDate: DateTime.parse(map['billDate']),
      subtotal: map['subtotal'],
      grandTotal: map['grandTotal'],
    );
  }
}
