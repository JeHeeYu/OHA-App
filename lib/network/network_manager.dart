import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_response.dart';

class NetworkManager {
  Map<String, String> commonHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static final NetworkManager _instance = NetworkManager._internal();

  NetworkManager._internal();

  static NetworkManager get instance => _instance;

  Future<dynamic> get(String serverUrl) async {
    dynamic responseJson;

    try {
      final response = await http.get(Uri.parse(serverUrl));
      responseJson = returnResponse(response);

      responseJson = utf8.decode(response.bodyBytes);

      print("GET 성공: ${response.body}");

      return responseJson;
    } catch (error) {
      print("에러 발생: $error");
      return "";
    }
  }

  Future<dynamic> post(String serverUrl, Map<String, dynamic> userData) async {
    try {
      String jsonData = jsonEncode(userData);

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: commonHeaders,
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print("POST 성공: ${response.body}");
      } else {
        print("POST 실패: ${response.statusCode}");
      }

      return response;
    } catch (error) {
      print("에러 발생: $error");
      return "";
    }
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 0:
      case 200:
        return response.body;
      default:
        return ApiResponse.error;
    }
  }
}
