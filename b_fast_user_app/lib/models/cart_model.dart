
class CartModel {
  double? dCreationTime;
  String? sId;
  int? addedAt;
  int? colorIndex;
  int? optionIndex;
  CartProduct? product;
  String? productId;
  int? quantity;
  String? userId;

  CartModel(
      {this.dCreationTime,
      this.sId,
      this.addedAt,
      this.colorIndex,
      this.optionIndex,
      this.product,
      this.productId,
      this.quantity,
      this.userId});

  CartModel.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    addedAt = json['addedAt'];
    colorIndex = json['colorIndex'];
    optionIndex = json['optionIndex'];
    product =
        json['product'] != null ? CartProduct.fromJson(json['product']) : null;
    productId = json['productId'];
    quantity = json['quantity'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_creationTime'] = dCreationTime;
    data['_id'] = sId;
    data['addedAt'] = addedAt;
    data['colorIndex'] = colorIndex;
    data['optionIndex'] = optionIndex;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['productId'] = productId;
    data['quantity'] = quantity;
    data['userId'] = userId;
    return data;
  }
}

class CartProduct {
  double? dCreationTime;
  String? sId;
  List<String>? availability;
  String? category;
  String? color;
  String? description;
  String? details;
  String? fabric;
  String? fit;
  List<Images>? images;
  String? materialCare;
  String? name;
  List<int>? price;
  List<int>? quantity;
  List<String>? size;
  String? status;
  String? storeId;
  String? subCategory;
  String? sustainable;
  List<String>? tags;

  CartProduct(
      {this.dCreationTime,
      this.sId,
      this.availability,
      this.category,
      this.color,
      this.description,
      this.details,
      this.fabric,
      this.fit,
      this.images,
      this.materialCare,
      this.name,
      this.price,
      this.quantity,
      this.size,
      this.status,
      this.storeId,
      this.subCategory,
      this.sustainable,
      this.tags});

  CartProduct.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    availability = json['availability'].cast<String>();
    category = json['category'];
    color = json['color'];
    description = json['description'];
    details = json['details'];
    fabric = json['fabric'];
    fit = json['fit'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    materialCare = json['materialCare'];
    name = json['name'];
    price = json['price'].cast<int>();
    quantity = json['quantity'].cast<int>();
    size = json['size'].cast<String>();
    status = json['status'];
    storeId = json['storeId'];
    subCategory = json['subCategory'];
    sustainable = json['sustainable'];
    tags = json['tags'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_creationTime'] = dCreationTime;
    data['_id'] = sId;
    data['availability'] = availability;
    data['category'] = category;
    data['color'] = color;
    data['description'] = description;
    data['details'] = details;
    data['fabric'] = fabric;
    data['fit'] = fit;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['materialCare'] = materialCare;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['size'] = size;
    data['status'] = status;
    data['storeId'] = storeId;
    data['subCategory'] = subCategory;
    data['sustainable'] = sustainable;
    data['tags'] = tags;
    return data;
  }
}

class Images {
  String? publicId;
  String? url;

  Images({this.publicId, this.url});

  Images.fromJson(Map<String, dynamic> json) {
    publicId = json['public_id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['public_id'] = publicId;
    data['url'] = url;
    return data;
  }
}
