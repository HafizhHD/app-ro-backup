abstract class RKBaseService {
  // final String baseUrl = "https://rk.defghi.biz.id:8080/api"; // dev
  final String baseUrl = "https://as01.prod.ruangortu.id:8080/api"; //prrod
  Future<dynamic> getResponseLogin(String email, String gToken, String fcmToken, String version);
}
