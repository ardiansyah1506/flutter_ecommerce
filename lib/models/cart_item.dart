class CartItem {
  final int productId;
  final String productName;
  final int price;
  final int quantity;
  final String? image;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      productName: json['product_name'],
      price: json['price'],
      quantity: json['quantity'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
