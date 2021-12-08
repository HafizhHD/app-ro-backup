import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/content_rk_model.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/model/rk_schedule_model.dart';
import 'package:ruangkeluarga/model/rk_user_model.dart';
import 'package:ruangkeluarga/utils/api_service.dart';
import 'package:ruangkeluarga/utils/base_service/base_service.dart';
import 'package:ruangkeluarga/utils/base_service/rk_base_service.dart';
import 'package:ruangkeluarga/utils/rk_api_service.dart';

class MediaRepository {
  BaseService _mediaService = ApiService();
  RKBaseService _rkService = RKApiService();

  static Map<String, String> noAuthHeaders = {"Content-Type": "application/json"};

  static Map<String, String> authHeaders = {};

  Future<List<Media>> fetchMediaList(String value) async {
    dynamic response = await _mediaService.getResponse(value);
    final jsonData = response['results'] as List;
    List<Media> mediaList = jsonData.map((tagJson) => Media.fromJson(tagJson)).toList();
    return mediaList;
  }

  Future<List<User>> loginUser(String email, String gToken, String fcmToken, String version) async {
    dynamic response = await _rkService.getResponseLogin(email, gToken, fcmToken, version);
    final jsonData = response['results'] as List;
    List<User> userList = jsonData.map((tagJson) => User.fromJson(tagJson)).toList();
    return userList;
  }

  Future<Response> userLogin(String email, String gToken, String fcmToken, String version) async {
    var url = _rkService.baseUrl + '/user/userLogin';
    Map<String, String> json = {"emailUser": "$email", "googleToken": "$gToken", "fcmToken": "$fcmToken", "version": "$version"};
    print('param userLogin: $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> getParentChildData(String userID) async {
    var url = _rkService.baseUrl + '/user/view';
    Map<String, String> json = {
      "userId": "$userID", "appName": "keluarga hkbp",
    };
    print('param get parent child data : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<dynamic> uploadImage(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(http.MultipartFile('image', File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(), filename: filepath.split("/").last));
    var res = await request.send();
    return res;
  }

  Future<Response> registerParent(String email, String name, String token, String photo, nohp, String alamat, String status, String accessToken,
      String imgByte, String namaHKPB, String birthDate) async {
    var url = _rkService.baseUrl + '/user/register';
    Map<String, dynamic> json = {
      "emailUser": "$email",
      "name": "$name",
      "devices": {"device": "Android", "fcmToken": "$token", "versi": "1.0"},
      "photo": "$photo",
      "phoneNumber": "$nohp",
      "address": "$alamat",
      "parentStatus": "$status",
      "birdDate": "$birthDate",
      "namaHkbp": "$namaHKPB",
      "accessCode": "$accessToken"
    };
    if (imgByte != "") json["imagePhoto"] = imgByte;

    print('param register parent : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> inviteChild(String email,
      String childEmail,
      String nohp,
      String childName,
      int childAge,
      String childStudyLevel,
      int childOfNumber,
      int childNumber,
      String imgByte,
      String birthDate,
      String address) async {
    var url = _rkService.baseUrl + '/user/invite';
    Map<String, dynamic> json = {
      "emailUser": "$email",
      "childEmail": "$childEmail",
      "phoneNumber": "$nohp",
      "childName": "$childName",
      "childAge": childAge,
      "childStudyLevel": "$childStudyLevel",
      "childOfNumber": childOfNumber,
      "childNumber": childNumber,
      "birdDate": "$birthDate",
      "address": "$address"
    };
    if (imgByte != "") json["imagePhoto"] = imgByte;

    print('param register parent : $json');
    Response response = await post(Uri.parse(url),
        headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> removeUser(String id) async {
    var url = _rkService.baseUrl + '/user/remove';
    Map<String, dynamic> json = {"userId": "$id"};
    print('param remove user : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    print('response remove user : ${response.body}');
    return response;
  }

  Future<Response> editUser(String id, Map<String, dynamic> newValue) async {
    var url = _rkService.baseUrl + '/user/edit';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "$id"},
      "newValues": newValue,
    };
    print('param update user data : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    print('response update user data: ${response.body}');
    return response;
  }

  Future<Response> saveChildUsage(String email, List<dynamic> data) async {
    var url = _rkService.baseUrl + '/user/appUsage';
    final usageDate = now_yyyyMMdd();
    final usageHour = now_HHmm();
    Map<String, dynamic> json = {"emailUser": "$email", "appUsageDate": "$usageDate", "appUsageHour": "$usageHour", "appUsages": data};
    print('param child usage : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchAppUsageFilter(String email, String usageDate, {bool isDaily = false}) async {
    var url = _rkService.baseUrl + '/user/appUsageFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email", "appUsageDate": "$usageDate"}
    };
    if (isDaily) json['viewBy'] = 'daily';

    print('param app usage filter : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchAppUsageFilterRange(String email, String startDate, String endDate, {bool isDaily = false}) async {
    var url = _rkService.baseUrl + '/user/appUsageFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {
        "emailUser": "$email",
        "appUsageDate": {"\$gte": "$startDate", "\$lte": "$endDate"}
      }
    };
    if (isDaily) json['viewBy'] = 'daily';

    print('param app usage filter : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> saveContacts(String email, List<dynamic> contact) async {
    var url = _rkService.baseUrl + '/user/contactAdd';
    Map<String, dynamic> json = {"emailUser": "$email", "contacts": contact};
    print('param child contact : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchBlacklistedContact(String email) async {
    var url = _rkService.baseUrl + '/user/contactBlackListFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email"}
    };
    print('param fetch blacklisted contact : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchContact(String email) async {
    var url = _rkService.baseUrl + '/user/contactFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email"}
    };
    print('param fetch contact : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> saveAppList(String email, List<ApplicationInstalled> appName) async {
    var url = _rkService.baseUrl + '/user/appDeviceAdd';
    Map<String, dynamic> json = {"emailUser": "$email", "appName": appName.map((e) => e.toJson()).toList()};
    // print('param save appList : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchAppList(String email) async {
    var url = _rkService.baseUrl + '/user/appDeviceFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email"},
      "limit": 1000
    };
    print('param fetch appList : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  // Future<Response> saveUserLocation(String email, LocationData location, String dates) async {
  //   final coordinates = new Coordinates(location.latitude, location.longitude);
  //   var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var url = _rkService.baseUrl + '/user/timeLineAdd';
  //   var place = "";
  //   if (addresses[0].thoroughfare != null) {
  //     place = addresses[0].thoroughfare!;
  //   } else {
  //     place = addresses[0].addressLine!;
  //   }
  //   Map<String, dynamic> json = {
  //     "emailUser": "$email",
  //     "location": {
  //       "place": "$place",
  //       "type": "Point",
  //       "coordinates": ["${location.latitude}", "${location.longitude}"]
  //     },
  //     "dateTimeHistory": "$dates"
  //   };
  //   print('param save user location : $json');
  //   Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
  //   return response;
  // }

  Future<Response> saveUserLocationx(String email, Position location, String dates) async {
    final coordinates = new Coordinates(location.latitude, location.longitude);
    var addresses = [];
    try {
      addresses = await Geocoder.local.findAddressesFromCoordinates(
          coordinates);
    } finally {

    }
    var url = _rkService.baseUrl + '/user/timeLineAdd';
    var place = "";
    if (addresses.length > 0) {
      if (addresses[0].thoroughfare != null) {
        place = addresses[0].thoroughfare!;
      } else {
        place = addresses[0].addressLine!;
      }
    }
    Map<String, dynamic> json = {
      "emailUser": "$email",
      "location": {
        "place": "$place",
        "type": "Point",
        "coordinates": ["${location.latitude}", "${location.longitude}"]
      },
      "dateTimeHistory": "$dates"
    };
    print('param save user location : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchUserLocation(String email, String dates) async {
    var url = _rkService.baseUrl + '/user/timeLineFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email", "dateTimeHistory": "$dates"}
    };
    print('param fetch user location list : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchFilterUserLocation(String email, String startDate, String endDate) async {
    var url = _rkService.baseUrl + '/user/timeLineFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {
        "emailUser": "$email",
        "dateTimeHistory": {"\$gte": "$startDate", "\$lte": "$endDate"}
      }
    };
    print('param fetch filter user location list : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchCurrentUserLocation(String email, String childEmail) async {
    var url = _rkService.baseUrl + '/user/childCurrentLocationRequest';
    Map<String, dynamic> json = {"parentEmailUser": "$email", "childEmailUser": "$childEmail"};
    print('param fetch current user location : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> blackListContactAdd(String email, String name, String phoneNumber, String label) async {
    var url = _rkService.baseUrl + '/user/contactBlackListAdd';
    List phoneNums = phoneNumber.split(',');
    Map<String, dynamic> json = {
      "emailUser": email.trim(),
      "contact": {
        "name": name.trim(),
        "phones": phoneNums,
      },
      "label": "Test Black List",
    };
    print('param blacklist contact : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> blContactNotification(String email, String name, String phoneNumber, String contactTime, String contactType) async {
    var url = _rkService.baseUrl + '/user/contactBlackListNotification';
    Map<String, dynamic> json = {
      "emailUser": "$email",
      "contact": {
        "name": "$name",
        "phones": ["$phoneNumber"]
      },
      "contactTime": "$contactTime",
      "contactType": "$contactType"
    };
    print('param blacklist contact notif : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchParentInbox(String email) async {
    var url = _rkService.baseUrl + '/user/inboxFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {
        "emailUser": "$email",
      }
    };
    print('param fetchParentInbox: $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> updateReadNotif(String notifID) async {
    var url = _rkService.baseUrl + '/user/inboxUpdate';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "$notifID"},
      "newValues": {"status": "read"},
    };
    print('param updateReadNotif: $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> removeInboxNotif(String notifID) async {
    var url = _rkService.baseUrl + '/user/inboxRemove';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "$notifID"},
    };
    print('param removeInboxNotif: $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> saveIconApp(String email, String appName, String appId, String appIcon, String category) async {
    var url = _rkService.baseUrl + '/user/appIconAdd';
    Map<String, dynamic> json = {"emailUser": "$email", "appName": appName, "appId": appId, "appIcon": appIcon, "appCategory": category};
    print('param save icon app : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchAppIconList() async {
    var url = _rkService.baseUrl + '/user/appIconFilter';
    Map<String, dynamic> json = {"limit": 1000};
    print('param app icon list : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchUserSchedule(String email) async {
    var url = _rkService.baseUrl + '/user/deviceUsageScheduleFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email"}
    };
    print('param fetch user schedule list : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> saveSchedule(DeviceUsageSchedules data) async {
    final url = _rkService.baseUrl + '/user/deviceUsageScheduleAdd';
    final json = data.toJson();
    print('param save schedule : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> scheduleUpdate(DeviceUsageSchedules data) async {
    var url = _rkService.baseUrl + '/user/deviceUsageScheduleUpdate';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "${data.id}"},
      "newValues": data.toJson(),
    };
    print('param update schedule : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> scheduleUpdateStatus(String status, String id) async {
    var url = _rkService.baseUrl + '/user/deviceUsageScheduleUpdate';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "$id"},
      "newValues": {"status": '$status'},
    };
    print('param update schedule : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> scheduleRemove(String id) async {
    var url = _rkService.baseUrl + '/user/deviceUsageScheduleRemove';
    Map<String, dynamic> json = {
      "whereValues": {"_id": "$id"}
    };
    print('param remove schedule : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    print('response remove schedule : ${response.body}');
    return response;
  }

  Future<Response> addLimitUsage(String email, dynamic appCategory, int limit, String status) async {
    var url = _rkService.baseUrl + '/user/appUsageLimitAdd';
    Map<String, dynamic> json = {"emailUser": "$email", "appCategory": appCategory, "limit": limit, "status": status};
    print('param add limit usage : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> addLimitUsageAndBlockApp(String email, String appID, dynamic appCategory, int limit, String status) async {
    var url = _rkService.baseUrl + '/user/appUsageLimitAdd';
    Map<String, dynamic> json = {"emailUser": "$email", "appId": appID, "appCategory": appCategory, "limit": limit, "status": status};
    print('param add limit usage : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> fetchLimitUsageFilter(String email) async {
    var url = _rkService.baseUrl + '/user/appUsageLimitFilter';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email"}
    };
    print('param limit usage filter : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> removeAppLimit(String email, String category) async {
    var url = _rkService.baseUrl + '/user/appUsageLimitRemove';
    Map<String, dynamic> json = {
      "whereKeyValues": {"emailUser": "$email", "appCategory": '$category'}
      // "whereKeyValues": {"emailUser": "$email", "appCategory": '$category'}
    };
    print('param limit usage filter : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  Future<Response> postPanicSOS(String email, LocationData location, String base64Video) async {
    final coordinates = new Coordinates(location.latitude, location.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var url = _rkService.baseUrl + '/user/panicVideoSend';
    var place = "";
    if (addresses[0].thoroughfare != null) {
      place = addresses[0].thoroughfare!;
    } else {
      place = addresses[0].addressLine!;
    }
    Map<String, dynamic> json = {
      "emailUser": "$email",
      "location": {
        "place": "$place",
        "type": "Point",
        "coordinates": ["${location.latitude}", "${location.longitude}"]
      },
      "panicVideo": "$base64Video"
    };
    print('param panicSOS: $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    return response;
  }

  /// API COBRAND
  Future<Response> fetchGerejaHKBP() async {
    var url = _rkService.baseUrl + '/cobrand/HKBPDataFilter';
    Response response = await post(Uri.parse(url), headers: noAuthHeaders);
    return response;
  }

  Future<Response> fetchCoBrandContents() async {
    var url = _rkService.baseUrl + '/cobrand/contentFilter';
    print('fetchCoBrandContents');
    Map<String, dynamic> json = {
      "whereKeyValues": {
        "cobrandEmail": "hkbp@test.com",
        "status": 'active'
      }
    };
    print('param content filter : $json');
    Response response = await post(Uri.parse(url), headers: noAuthHeaders, body: jsonEncode(json));
    // Response response = await post(Uri.parse(url), headers: noAuthHeaders);
    return response;
  }
}
