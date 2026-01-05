class Stores {
  double? dCreationTime;
  String? sId;
  Address? address;
  String? category;
  Contact? contact;
  int? createdAt;
  String? description;
  String? kycStatus;
  Media? media;
  Owner? owner;
  Settings? settings;
  String? storeName;
  String? storeStatus;
  List<String>? tags;
  int? updatedAt;

  Stores(
      {this.dCreationTime,
      this.sId,
      this.address,
      this.category,
      this.contact,
      this.createdAt,
      this.description,
      this.kycStatus,
      this.media,
      this.owner,
      this.settings,
      this.storeName,
      this.storeStatus,
      this.tags,
      this.updatedAt});

  Stores.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    category = json['category'];
    contact =
        json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
    createdAt = json['createdAt'];
    description = json['description'];
    kycStatus = json['kycStatus'];
    media = json['media'] != null ? new Media.fromJson(json['media']) : null;
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    storeName = json['storeName'];
    storeStatus = json['storeStatus'];
    tags = json['tags'].cast<String>();
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_creationTime'] = this.dCreationTime;
    data['_id'] = this.sId;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['category'] = this.category;
    if (this.contact != null) {
      data['contact'] = this.contact!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['description'] = this.description;
    data['kycStatus'] = this.kycStatus;
    if (this.media != null) {
      data['media'] = this.media!.toJson();
    }
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    if (this.settings != null) {
      data['settings'] = this.settings!.toJson();
    }
    data['storeName'] = this.storeName;
    data['storeStatus'] = this.storeStatus;
    data['tags'] = this.tags;
    data['updatedAt'] = this.updatedAt;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['country'] = this.country;
    data['state'] = this.state;
    data['street'] = this.street;
    data['zip'] = this.zip;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Media {
  List<Gallery>? gallery;

  Media({this.gallery});

  Media.fromJson(Map<String, dynamic> json) {
    if (json['gallery'] != null) {
      gallery = <Gallery>[];
      json['gallery'].forEach((v) {
        gallery!.add(new Gallery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gallery != null) {
      data['gallery'] = this.gallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gallery {
  String? publicId;
  String? url;

  Gallery({this.publicId, this.url});

  Gallery.fromJson(Map<String, dynamic> json) {
    publicId = json['public_id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['public_id'] = this.publicId;
    data['url'] = this.url;
    return data;
  }
}

class Owner {
  String? email;
  String? fullName;
  String? phone;

  Owner({this.email, this.fullName, this.phone});

  Owner.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    fullName = json['fullName'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['fullName'] = this.fullName;
    data['phone'] = this.phone;
    return data;
  }
}

class Settings {
  String? businessType;
  bool? status;
  String? storeType;

  Settings({this.businessType, this.status, this.storeType});

  Settings.fromJson(Map<String, dynamic> json) {
    businessType = json['businessType'];
    status = json['status'];
    storeType = json['storeType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['businessType'] = this.businessType;
    data['status'] = this.status;
    data['storeType'] = this.storeType;
    return data;
  }
}