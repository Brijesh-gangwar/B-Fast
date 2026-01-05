
import 'package:b_fast_user_app/models/user_details_model.dart';

class OrderModel {
  double? dCreationTime;
  String? sId;
  UserAddress? address;
  int? createdAt;
  int? deliveryFee;
  List<Items>? items;
  String? orderId;
  String? orderStatus;
  String? paymentMethod;
  String? paymentStatus;
  String? storeId;
  int? taxes;
  int? total;
  String? userId;

  OrderModel(
      {this.dCreationTime,
      this.sId,
      this.address,
      this.createdAt,
      this.deliveryFee,
      this.items,
      this.orderId,
      this.orderStatus,
      this.paymentMethod,
      this.paymentStatus,
      this.storeId,
      this.taxes,
      this.total,
      this.userId});

  OrderModel.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    address =
        json['address'] != null ? UserAddress.fromJson(json['address']) : null;
    createdAt = json['createdAt'];
    deliveryFee = json['deliveryFee'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    orderId = json['orderId'];
    orderStatus = json['orderStatus'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    storeId = json['storeId'];
    taxes = json['taxes'];
    total = json['total'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_creationTime'] = dCreationTime;
    data['_id'] = sId;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['createdAt'] = createdAt;
    data['deliveryFee'] = deliveryFee;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['orderId'] = orderId;
    data['orderStatus'] = orderStatus;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['storeId'] = storeId;
    data['taxes'] = taxes;
    data['total'] = total;
    data['userId'] = userId;
    return data;
  }
}


class Items {
  String? category;
  String? color;
  String? image;
  String? name;
  int? price;
  String? productId;
  int? quantity;
  String? size;
  String? subCategory;

  Items(
      {this.category,
      this.color,
      this.image,
      this.name,
      this.price,
      this.productId,
      this.quantity,
      this.size,
      this.subCategory});

  Items.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    color = json['color'];
    image = json['image'];
    name = json['name'];
    price = json['price'];
    productId = json['productId'];
    quantity = json['quantity'];
    size = json['size'];
    subCategory = json['subCategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['color'] = color;
    data['image'] = image;
    data['name'] = name;
    data['price'] = price;
    data['productId'] = productId;
    data['quantity'] = quantity;
    data['size'] = size;
    data['subCategory'] = subCategory;
    return data;
  }
}
