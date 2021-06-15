import 'package:intl/intl.dart';

String initTextEditingValue(Type type, dynamic data) {
  switch (type) {
    case DateTime:
      final dateString =
          DateFormat('yyyy/MM/dd HH:mm').format(data ?? DateTime.now());
      return dateString;
    // NOTE 必要だったら個別に定義
    // case Image:
    //   return data?.toString() ?? '';
    // case GeoPoint:
    //   return data?.toString() ?? '';
    // case List:
    //   return data?.toString() ?? '';
    // case num:
    //   return data?.toString() ?? '';
    default:
      return data?.toString() ?? '';
  }
}
