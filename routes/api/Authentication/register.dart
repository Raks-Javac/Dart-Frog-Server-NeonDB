import 'package:dart_frog/dart_frog.dart';

import '../../../lib/models/response/response_model.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: ApiResponseModel(
      isSuccessful: true,
      message: 'User logged in Successfully',
      status: 'success',
    ).toJson(),
  );
}
