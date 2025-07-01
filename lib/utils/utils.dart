// ignore_for_file: public_member_api_docs

import 'package:dart_frog_jwt_neon/models/response/response_model.dart';

ApiResponseModel failedResponse(
  String message,
) {
  return ApiResponseModel(
    isSuccessful: false,
    message: message,
    status: 'failed',
  );
}

ApiResponseModel succcessResponse(
  String message,
  dynamic data,
) {
  return ApiResponseModel(
    isSuccessful: true,
    message: message,
    data: data,
    status: 'success',
  );
}
