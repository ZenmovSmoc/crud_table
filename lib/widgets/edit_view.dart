import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/edit_utils.dart';
import 'package:flutter/material.dart';

enum EditType { add, update }

class EditView<T extends DataModel> extends StatefulWidget {
  final EditType type;
  final T data;

  const EditView({
    Key? key,
    required this.type,
    required this.data,
  }) : super(key: key);

  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _formControllers = {};

  late Map<String, Type> _parameters;

  final List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();

    if (widget.type == EditType.add) {
      _parameters = widget.data.getCreateParamsList();
    } else {
      _parameters = widget.data.getEditableParamsList();
    }

    final dataMap = widget.data.toMap();

    _parameters.forEach(
      (key, type) {
        final _controller = TextEditingController(
            text: initTextEditingValue(type, dataMap[key]));
        _formControllers[key] = _controller;

        widgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFieldWidget(
              keyType: key,
              type: type,
              controller: _controller,
              data: dataMap[key],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            children: [
              ListTile(
                title: Center(
                  child: Text(
                    widget.type == EditType.add ? 'New Data' : 'Update Data',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      letterSpacing: 2,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(Icons.close),
                  padding: const EdgeInsets.all(0),
                ),
                dense: true,
              ),
              const SizedBox(height: 32),
              ...widgets,
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      DataModel _data = widget.data;

                      _formControllers.forEach((key, value) {
                        _data = _data.setParameter(key, value.text);
                      });

                      Navigator.of(context).pop(_data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  )),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String keyType;
  final Type type;
  final dynamic data;
  final TextEditingController controller;

  const TextFieldWidget({
    Key? key,
    required this.keyType,
    required this.type,
    this.data,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // switch (type) {
    //   // case DateTime:
    //   //   return _createDateTimeField(context, key, data, controller);
    //   // case ReservationsStatus:
    //   //   return _createReservationStatusField(context, key, controller);
    //   // case Image:
    //   //   return _createImageArea(context, key, data, controller);
    //   // case GeoPoint:
    //   //   return _createLocationMapArea(context, key, data, controller);
    //   // case List:
    //   //   return _createAreaMap(context, key, data, controller);
    //   // case num:
    //   //   return _createNumField(key, controller);
    //   // default:
    //   //   return _createTextField(data, key, controller);
    // }

    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: keyType,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
}
