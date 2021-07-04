abstract class RKBaseService {
  final String baseUrl = "https://rk.defghi.biz.id:8080/api";

  Future<dynamic> getResponseLogin(String email, String gToken, String fcmToken, String version);
}