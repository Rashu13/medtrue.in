import 'package:get/get.dart';
import '../../core/app_constants.dart';

class ApiClient extends GetConnect implements GetxService {
  @override
  void onInit() {
    baseUrl = AppConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
    
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      return request;
    });

    super.onInit();
  }

  Future<Response> getData(String uri) async {
    try {
      Response response = await get(uri);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, dynamic body) async {
    try {
      Response response = await post(uri, body);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}
