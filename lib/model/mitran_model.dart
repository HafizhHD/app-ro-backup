class MidtranAuthModel {
  final String? token;

  MidtranAuthModel(
  {this.token});


  factory MidtranAuthModel.fromJson(Map<String, dynamic> json) {
    return MidtranAuthModel(
      token: json['token'] as String?
    );
  }
}