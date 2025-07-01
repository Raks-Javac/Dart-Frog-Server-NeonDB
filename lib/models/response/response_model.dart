// ignore_for_file: public_member_api_docs

class ApiResponseModel {
  ApiResponseModel({this.isSuccessful, this.data, this.status, this.message});

  ApiResponseModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['IsSuccessful'] as bool?;
    data = json['Data'];
    status = json['Status'] as String?;
    message = json['Message'] as String?;
  }
  bool? isSuccessful;
  dynamic data;
  String? status;
  String? message;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['IsSuccessful'] = isSuccessful;
    data['Data'] = this.data;
    data['Status'] = status;
    data['Message'] = message;
    return data;
  }
}
