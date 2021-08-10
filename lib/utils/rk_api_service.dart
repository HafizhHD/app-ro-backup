import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meta/meta.dart';

import 'api_exception.dart';
import 'base_service/rk_base_service.dart';

class RKApiService extends RKBaseService {
  @override
  Future getResponseLogin(String url, String gToken, String fcmToken, String version) async {
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(baseUrl + url));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @visibleForTesting
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException('Error occured while communication with server' + ' with status code : ${response.statusCode}');
    }
  }
}
