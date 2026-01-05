
class AgentDetailsModel {
  double? dCreationTime;
  String? sId;
  String? avgDeliveryTime;
  double? completionRate;
  String? createdAt;
  int? deliveries;
  double? earnings;
  String? email;
  String? employeeId;
  String? fullName;
  String? licenseStatus;
  String? phone;
  double? rating;
  String? status;
  String? vehicleType;
  String? zone;

  AgentDetailsModel(
      {this.dCreationTime,
      this.sId,
      this.avgDeliveryTime,
      this.completionRate,
      this.createdAt,
      this.deliveries,
      this.earnings,
      this.email,
      this.employeeId,
      this.fullName,
      this.licenseStatus,
      this.phone,
      this.rating,
      this.status,
      this.vehicleType,
      this.zone});

  AgentDetailsModel.fromJson(Map<String, dynamic> json) {
    dCreationTime = json['_creationTime'];
    sId = json['_id'];
    avgDeliveryTime = json['avgDeliveryTime'];
    completionRate = json['completionRate'];
    createdAt = json['createdAt'];
    deliveries = json['deliveries'];
    earnings = json['earnings'];
    email = json['email'];
    employeeId = json['employeeId'];
    fullName = json['fullName'];
    licenseStatus = json['licenseStatus'];
    phone = json['phone'];
    rating = json['rating'];
    status = json['status'];
    vehicleType = json['vehicleType'];
    zone = json['zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_creationTime'] = this.dCreationTime;
    data['_id'] = this.sId;
    data['avgDeliveryTime'] = this.avgDeliveryTime;
    data['completionRate'] = this.completionRate;
    data['createdAt'] = this.createdAt;
    data['deliveries'] = this.deliveries;
    data['earnings'] = this.earnings;
    data['email'] = this.email;
    data['employeeId'] = this.employeeId;
    data['fullName'] = this.fullName;
    data['licenseStatus'] = this.licenseStatus;
    data['phone'] = this.phone;
    data['rating'] = this.rating;
    data['status'] = this.status;
    data['vehicleType'] = this.vehicleType;
    data['zone'] = this.zone;
    return data;
  }
}
