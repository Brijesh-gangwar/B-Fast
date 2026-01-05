import 'product_model.dart';

class WishlistModel {
  double? dCreationTime;
  String? sId;
  int? createdAt;
  Product? product;
  String? productId;
  String? userId;

  WishlistModel(
      {this.dCreationTime,
      this.sId,
      this.createdAt,
      this.product,
      this.productId,
      this.userId});

  WishlistModel.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
    productId = json['productId'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_creationTime'] = dCreationTime;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['productId'] = productId;
    data['userId'] = userId;
    return data;
  }
}
