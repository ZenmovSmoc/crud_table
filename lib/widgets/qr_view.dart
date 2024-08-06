import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView<T extends DataModel> extends StatefulWidget {
  final T data;

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
      data: dataMap[Strings.promoCode],
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
