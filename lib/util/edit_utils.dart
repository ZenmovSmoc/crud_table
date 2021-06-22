import 'package:google_maps_flutter/google_maps_flutter.dart';

String initTextEditingValue(Type type, dynamic data) {
  switch (type) {
    case LatLng:
      if (data != null) {
        final _data = data as LatLng;
        return '${_data.latitude},${_data.longitude}';
      } else {
        return '';
      }
    default:
      return data?.toString() ?? '';
  }
}
