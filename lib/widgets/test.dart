import 'dart:convert';

import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/component_type.dart';
import 'package:crud_table/widgets/edit_view.dart';
import 'package:flutter/material.dart';

class ValidateInput {
  bool isPromoCodeExist({
    required EditType type,
    required List<DataModel> table,
    required Map<String, TextEditingController> controllers,
  }) {
    return type == EditType.add &&
        controllers.containsKey(ComponentType.promoCode) &&
        table
            .where(
              (element) =>
          element.toMap()[ComponentType.promoCode] ==
              controllers[ComponentType.promoCode]!.value.text,
        )
            .length ==
            1;
  }

  bool isFromAndToStationNameTheSame({
    required bool type,
    required Map<String, TextEditingController> controllers,
  }) {
    return type &&
        controllers.containsKey(ComponentType.fromStation) &&
        controllers.containsKey(ComponentType.toStation) &&
        controllers[ComponentType.fromStation]!.value.text ==
            controllers[ComponentType.toStation]!.value.text;
  }

  bool isFromAndToStationNameExist({
    required bool type,
    required List<DataModel> table,
    required Map<String, TextEditingController> controllers,
  }) {
    return type &&
        controllers.containsKey(ComponentType.fromStation) &&
        controllers.containsKey(ComponentType.toStation) &&
        table
            .where(
              (element) =>
          element.toMap()[ComponentType.fromStation] ==
              getTextEditingValue(
                map: controllers[ComponentType.fromStation]!
                    .value
                    .text,
                key: "name",
              ) &&
              element.toMap()[ComponentType.toStation] ==
                  getTextEditingValue(
                    map: controllers[ComponentType.toStation]!
                        .value
                        .text,
                    key: "name",
                  ),
        )
            .length ==
            1;
  }

  String getTextEditingValue({required String map, required String key}) {
    final Map<String, dynamic> value = jsonDecode(map);

    return value[key].toString();
  }
}