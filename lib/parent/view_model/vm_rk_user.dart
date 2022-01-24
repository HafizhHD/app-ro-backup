import 'package:flutter/material.dart';
import 'package:ruangkeluarga/model/rk_user_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/utils/response/api_response.dart';

class UserViewModel extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  User? _user;

  ApiResponse get response {
    return _apiResponse;
  }

  User? get user {
    return _user;
  }

  /// Call the media service and gets the data of requested media data of
  /// an artist.
  Future<void> fetchLoginUser(String email, String gToken, String fcmToken,
      String version) async {
    _apiResponse = ApiResponse.loading('Fetching artist data');
    notifyListeners();
    try {
      List<User> userList = await MediaRepository().loginUser(email,gToken,fcmToken,version);
      _apiResponse = ApiResponse.completed(userList);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      print(e);
    }
    notifyListeners();
  }

  void setSelectedMedia(User? user) {
    _user = user;
    notifyListeners();
  }
}