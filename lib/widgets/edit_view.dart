import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/edit_utils.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
                        final type = _parameters[key];

                        switch (type) {
                          case DateTime:
                            _data = _data.setParameter(
                                key, DateTime.parse(value.text));
                            break;
                          case LatLng:
                            final data = value.text.split(',');
                            _data = _data.setParameter(
                                key,
                                LatLng(double.parse(data[0]),
                                    double.parse(data[1])));
                            break;
                          default:
                            _data = _data.setParameter(key, value.text);
                            break;
                        }
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

  Widget textField() {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type == num ? TextInputType.number : TextInputType.text,
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

  Widget dateTimeTextField() {
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: keyType,
        prefixIcon: const Icon(Icons.event),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget mapTextField(BuildContext context) {
    return TextFormField(
      controller: controller,
      enableInteractiveSelection: false,
      readOnly: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type == num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: keyType,
        prefixIcon: const Icon(Icons.location_pin),
      ),
      onTap: () async {
        final result = await showDialog<LatLng?>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (context) => MapPickerWidget(initialValue: data),
        );

        if (result != null) {
          controller.text = '${result.latitude},${result.longitude}';
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DateTime:
        return dateTimeTextField();
      case LatLng:
        return mapTextField(context);
      default:
        return textField();
    }
  }
}

class MapPickerWidget extends StatefulWidget {
  final LatLng? initialValue;

  const MapPickerWidget({Key? key, this.initialValue}) : super(key: key);

  @override
  _MapPickerWidgetState createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late LatLng _initialLocation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _initialLocation = widget.initialValue ??
        const LatLng(37.42796133580664, -122.085749655962);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void mapMoving() {
    if (!animationController.isCompleted || !animationController.isAnimating) {
      animationController.forward();
    }
  }

  void mapFinishedMoving() {
    animationController.reverse();
  }

  late CameraPosition cameraPosition;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Center(
                child: Text(
                  'Select Location on map',
                  style: TextStyle(
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
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _initialLocation, zoom: 12),
                    onCameraMove: (val) {
                      cameraPosition = val;
                    },
                    onCameraMoveStarted: () {
                      mapMoving();
                    },
                    onCameraIdle: () async {
                      mapFinishedMoving();
                    },
                  ),
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, snapshot) {
                      return Align(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset:
                                  Offset(0, -10 * animationController.value),
                              child: const Icon(Icons.location_pin,
                                  size: 50, color: Colors.red),
                            ),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(cameraPosition.target);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
