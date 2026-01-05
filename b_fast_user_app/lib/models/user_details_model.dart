
import 'address_model.dart';


class UserDetails {
  double? dCreationTime;
  String? sId;
  List<Addresses>? addresses;
  String? email;
  String? name;
  String? phone;
  String? userId;
  String? userStatus;

  UserDetails(
      {this.dCreationTime,
      this.sId,
      this.addresses,
      this.email,
      this.name,
      this.phone,
      this.userId,
      this.userStatus});

  UserDetails.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    if (json['addresses'] != null) {
      addresses = <Addresses>[];
      json['addresses'].forEach((v) {
        addresses!.add(Addresses.fromJson(v));
      });
    }
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    userId = json['userId'];
    userStatus = json['userStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_creationTime'] = dCreationTime;
    data['_id'] = sId;
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    data['userId'] = userId;
    data['userStatus'] = userStatus;
    return data;
  }
}



class UserAddress {
  String? label;
  String? street;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? latitude;
  String? longitude;

  UserAddress(
      {this.label,
      this.street,
      this.city,
      this.state,
      this.zip,
      this.country,
      this.latitude,
      this.longitude});

  UserAddress.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    street = json['street'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
