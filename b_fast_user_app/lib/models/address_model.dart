
class Addresses {
  String? addressId;
  String? city;
  String? country;
  String? label;
  String? latitude;
  String? longitude;
  String? state;
  String? street;
  String? zip;

  Addresses(
      {this.addressId,
      this.city,
      this.country,
      this.label,
      this.latitude,
      this.longitude,
      this.state,
      this.street,
      this.zip});

  Addresses.fromJson(Map<String, dynamic> json) {
    addressId = json['addressId'];
    city = json['city'];
    country = json['country'];
    label = json['label'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    state = json['state'];
    street = json['street'];
    zip = json['zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addressId'] = addressId;
    data['city'] = city;
    data['country'] = country;
    data['label'] = label;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['state'] = state;
    data['street'] = street;
    data['zip'] = zip;
    return data;
  }
}
