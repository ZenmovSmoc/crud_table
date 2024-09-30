import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/component_type.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView<T extends DataModel> extends StatefulWidget {
  /// The data model instance of type [T] that will be encoded into a QR code.
  final T data;

  /// A widget that displays a QR code for a specific data model entry.
  ///
  /// The [QRView] widget generates and displays a QR code representation of the data provided.
  /// The data must be of type [T], which extends [DataModel]. This is useful for visualizing
  /// data in a scannable format, such as for sharing or quick access to specific data.
  ///
  /// ### Type Parameter:
  /// - `T`: A type that extends [DataModel], representing the type of data encoded in the QR code.
  ///
  /// ### Constructor Parameters:
  ///
  /// #### Required:
  /// - [data]: The instance of type [T] that contains the data to be encoded into a QR code.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// QRView<UserModel>(
  ///   data: userData,
  /// );
  /// ```
  ///
  /// This widget is part of the CRUD system and allows for the generation of QR codes from
  /// any data model that extends [DataModel].
  const QRView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _QRViewState createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  late Map<String, Type> _parameters;

  final List<Widget> widgets = [];
  late Widget qrImage;

  @override
  void initState() {
    super.initState();

    _parameters = widget.data.getDisplayParamsList();

    final dataMap = widget.data.toMap();

    _parameters.forEach(
      (key, type) {
        widgets.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text("$key: ${dataMap[key]}"),
            ),
          ),
        );
      },
    );

    qrImage = QrImageView(
      data: dataMap[ComponentType.promoCode],
      size: 200.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400.0, maxHeight: 400.0),
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: qrImage,
              ),
            ),
            ...widgets,
          ],
        ),
      ),
    );
  }
}
