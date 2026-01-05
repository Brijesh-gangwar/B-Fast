

class Product {
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
  String? productId;
  List<String>? size;
  String? status;
  Store store; // 🔹 not nullable now
  String? subCategory;
  String? sustainable;
  List<String>? tags;

  Product({
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
    this.productId,
    this.size,
    this.status,
    required this.store, // 🔹 required in constructor
    this.subCategory,
    this.sustainable,
    this.tags,
  });

  Product.fromJson(Map<String, dynamic> json)
      : store = Store.fromJson(json['store'] ?? {}) { // 🔹 force store to exist
    availability = (json['availability'] as List?)?.cast<String>();
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
    price = (json['price'] as List?)?.cast<int>();
    productId = json['productId'];
    size = (json['size'] as List?)?.cast<String>();
    status = json['status'];
    subCategory = json['subCategory'];
    sustainable = json['sustainable'];
    tags = (json['tags'] as List?)?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
    data['productId'] = productId;
    data['size'] = size;
    data['status'] = status;
    data['store'] = store.toJson(); // 🔹 always present
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

class Store {
  Address? address;
  String? category;
  Contact? contact;
  String? storeId;
  String? storeName;
  String? storeStatus;

  Store(
      {this.address,
      this.category,
      this.contact,
      this.storeId,
      this.storeName,
      this.storeStatus});

  Store.fromJson(Map<String, dynamic> json) {
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    category = json['category'];
    contact =
        json['contact'] != null ? Contact.fromJson(json['contact']) : null;
    storeId = json['storeId'];
    storeName = json['storeName'];
    storeStatus = json['storeStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['category'] = category;
    if (contact != null) {
      data['contact'] = contact!.toJson();
    }
    data['storeId'] = storeId;
    data['storeName'] = storeName;
    data['storeStatus'] = storeStatus;
    return data;
  }
}

class Address {
  String? city;
  String? country;
  String? state;
  String? street;
  String? zip;

  Address({this.city, this.country, this.state, this.street, this.zip});

  Address.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    state = json['state'];
    street = json['street'];
    zip = json['zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['country'] = country;
    data['state'] = state;
    data['street'] = street;
    data['zip'] = zip;
    return data;
  }
}

class Contact {
  String? email;
  String? phone;

  Contact({this.email, this.phone});

  Contact.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}
