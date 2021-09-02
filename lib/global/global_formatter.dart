import 'package:intl/intl.dart';

String weekdayToDayName(int pWeekday) {
  switch (pWeekday) {
    case 0:
      return "Minggu";
      break;
    case 1:
      return "Senin";
      break;
    case 2:
      return "Selasa";
      break;
    case 3:
      return "Rabu";
      break;
    case 4:
      return "Kamis";
      break;
    case 5:
      return "Jumat";
      break;
    case 6:
      return "Sabtu";
      break;
    default:
      return "";
  }
}

///TEXT FORMAT
String limitChar(String text, int limit, {bool dots = true}) =>
    text != null && text != '' && text.length > limit ? text.substring(0, limit - 3) + (dots ? '...' : '') : text;

///NUMBERFORMAT
double getDiffPercent(num a, num b) {
  return ((a - b) / (b > 0 ? b : 1).toDouble()) * 100;
}

String shrinkNum(num value) {
  ///Shrinks number rounding
  ///123456  > 123,5K
  ///123579  > 123,6K
  ///1234567 > 1,2M
  if (value >= 1000000) return '${(value.toDouble() / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value.toDouble() / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(1);
}

///CURRENCY FORMAT
String toRupiah(num value, {bool spaces = false}) {
  var rupiah = NumberFormat("#,##0", "en_US");
  var formatted = rupiah.format(value.abs()).replaceAll(',', '.');
  return (value >= 0 ? "" : "- ") + (spaces ? "Rp $formatted" : "Rp$formatted");
}

String numSeparator(num value) {
  var rupiah = NumberFormat("#,##0", "en_US");
  return rupiah.format(value).replaceAll(',', '.');
}

String moneyFormat(String price) {
  if (price.length > 0) {
    var value = price;
    value = value.replaceAll(RegExp(r'\D'), '');
    value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return value;
  } else {
    return "";
  }
}

///DATETIME FORMAT
final locale = "id";

String now_ddMMMyyyyHHmmss() {
  var now = DateTime.now();
  final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm:ss');
  return formatter.format(now);
}

String now_ddMMMMyyyy() {
  var now = DateTime.now();
  final DateFormat formatter = DateFormat('dd MMMM yyyy');
  return formatter.format(now);
}

String now_ddMMMyyyy({String separator = ' '}) {
  var now = DateTime.now();
  final DateFormat formatter = DateFormat('dd${separator}MMM${separator}yyyy');
  return formatter.format(now);
}

int nowEpoch() {
  return DateTime.now().millisecondsSinceEpoch;
}

int datetimeToEpoch(DateTime time) {
  var date = time.millisecondsSinceEpoch;
  return date.toInt();
}

String dateFormat(DateTime time) {
  var formatter = new DateFormat("E, dd MMM yyyy");
  String formatted = formatter.format(time);

  return formatted;
}

String dateFormat_EDMYHM(DateTime time) {
  var formatter = new DateFormat("EEEE, dd MMMM yyyy HH:mm");
  String formatted = formatter.format(time);

  return formatted;
}

String dateTimeTo_ddMMMMyyyy(DateTime date) {
  final DateFormat formatter = DateFormat('dd MMMM yyyy', locale);
  return formatter.format(date);
}

///FROM STRING
String strToDayDDMMMYYYY(String str) {
  if (str == null || str == "") return "";
  var formatter = new DateFormat("E, dd MMM yyyy");
  var time = DateTime.parse(str);
  String formatted = formatter.format(time);

  return formatted;
}

String strToDate_EddMMMyyyyHHmm(String str) {
  var formatter = new DateFormat("E, dd MMM yyyy HH:mm");
  var time = DateTime.parse(str);
  String formatted = formatter.format(time);

  return formatted;
}

String strToDate_ddMMMyyyyHHmm(String str) {
  var formatter = new DateFormat("dd MMM yyyy HH:mm");
  var time = DateTime.parse(str);
  String formatted = formatter.format(time);

  return formatted;
}

String strToHumanDate(String str) {
  var formatter = new DateFormat("dd MMMM yyyy HH:mm:ss", locale);
  var time = DateTime.tryParse(str);
  String formatted = formatter.format(time!);

  return formatted;
}

String strTo_ddMMMMyyyy(String str) {
  var formatter = new DateFormat("dd MMMM yyyy", locale);
  var time = DateTime.parse(str);
  String formatted = formatter.format(time);

  return formatted;
}

String strToDate_yyyy_MM_dd(String str) {
  var formatter = new DateFormat("yyyy-MM-dd");
  var time = DateTime.parse(str);
  String formatted = formatter.format(time);

  return formatted;
}

///FROM NUM TYPE
//https://stackoverflow.com/questions/50632217/dart-flutter-converting-the-timestamp
String epochToStrDate_ddMMMyyyyHHmmss(num epoch) {
  var epochDate = DateTime.fromMillisecondsSinceEpoch(epoch.toInt());
  final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm:ss');
  return formatter.format(epochDate);
}

String epochToStrDate_ddMMyyHHmm(num epoch) {
  var epochDate = DateTime.fromMillisecondsSinceEpoch(epoch.toInt());
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');
  return formatter.format(epochDate);
}

String epochToHumanStr(num epoch) {
  var epochDate = DateTime.fromMillisecondsSinceEpoch(epoch.toInt());

  final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm:ss');
  String dateTime = formatter.format(epochDate);
  String dayName = weekdayToDayName(epochDate.weekday);
  return '$dayName, $dateTime';
}

String readTimestamp(num timestamp) {
  var format = new DateFormat("yMd");
  var date = new DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).round());
  String formatted = format.format(date);

  return formatted;
}

String readTimestampSecond(num epoch) {
  var format = new DateFormat("E, dd MMM yyyy");
  var date = new DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round());
  String formatted = format.format(date);

  return formatted;
}

String epochToDayDDMMMYYYY(num epoch) {
  var format = new DateFormat("E, dd MMM yyyy");
  var date = new DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round());
  String formatted = format.format(date);

  return formatted;
}

String epochToDayDMYHM(num epoch) {
  var format = new DateFormat("E, dd MMM yyyy HH:mm");
  var date = new DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round());
  String formatted = format.format(date);

  return formatted;
}

String millisecondsToyyyyMMdd(num timestamp) {
  var format = new DateFormat("yyyy-MM-dd");
  var date = new DateTime.fromMillisecondsSinceEpoch((timestamp).round());
  String formatted = format.format(date);

  return formatted;
}

String millisecondsToddMMMMyyyy(num timestamp) {
  var format = new DateFormat("dd MMMM yyyy", locale);
  var date = new DateTime.fromMillisecondsSinceEpoch((timestamp).round());
  String formatted = format.format(date);

  return formatted;
}

String currentDatetimeGolangFormat() {
  //2012-11-01T22:08:41+00:00"
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss+07:00');
  final String formatted = formatter.format(now);
  print(formatted);
  return formatted;
}

///END - DATE FORMAT

extension ParseToString on Object {
  String toEnumString() {
    return this.toString().split('.').last;
  }
}
