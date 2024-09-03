import 'dart:convert';

import 'package:crud_table/crud_table.dart';
import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/edit_utils.dart';
import 'package:crud_table/util/strings.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EditType { add, update }

class EditView<T extends DataModel> extends StatefulWidget {
  final EditType type;
  final T data;
  final List<T> dataTable;
  final Map<Type, CustomEditHandlers>? customEditHandlers;

  const EditView({
    Key? key,
    required this.type,
    required this.data,
    required this.dataTable,
    this.customEditHandlers,
  }) : super(key: key);

  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _formControllers = {};

  late Map<String, Type> _parameters;

  final List<Widget> widgets = [];

  bool isPromoCodeExist = false;

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
        final controller = TextEditingController(
          text: initTextEditingValue(type, dataMap[key]),
        );
        _formControllers[key] = controller;

        bool enabled = true;

        if (widget.type == EditType.update && key == Strings.promoCode) {
          enabled = false;
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFieldWidget(
              keyType: key,
              type: type,
              textEditingController: controller,
              data: dataMap[key],
              customEditHandlers: widget.customEditHandlers,
              enabled: enabled,
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
                dense: true,
              ),
              const SizedBox(height: 32),
              ...widgets,
              const SizedBox(height: 32),
              if (isPromoCodeExist)
                const Center(
                  child: Text(
                    "That promotional code already exists!",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.type == EditType.add &&
                          _formControllers.containsKey(Strings.promoCode) &&
                          widget.dataTable
                                  .where(
                                    (element) =>
                                        element.toMap()[Strings.promoCode] ==
                                        _formControllers[Strings.promoCode]!
                                            .value
                                            .text,
                                  )
                                  .length ==
                              1) {
                        setState(() {
                          isPromoCodeExist = true;
                        });
                      } else {
                        DataModel data = widget.data;

                        _formControllers.forEach((key, value) {
                          data = data.setParameter(key, value.text);
                        });

                        Navigator.of(context).pop(data);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                  ),
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
  final TextEditingController textEditingController;

  final Map<Type, CustomEditHandlers>? customEditHandlers;
  final bool? enabled;

  const TextFieldWidget({
    Key? key,
    required this.keyType,
    required this.type,
    this.data,
    required this.textEditingController,
    this.customEditHandlers,
    this.enabled,
  }) : super(key: key);

  Widget textField() {
    return TextFormField(
      enabled: enabled ?? true,
      controller: textEditingController,
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
      controller: textEditingController,
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
    LatLng? location = data;
    late GoogleMapController controller;

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> onTap() async {
          final result = await showDialog<LatLng?>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            builder: (context) => MapPickerWidget(initialValue: location),
          );

          if (result != null) {
            final data = <String, String>{
              'latitude': '${result.latitude}',
              'longitude': '${result.longitude}',
            };

            textEditingController.text = json.encode(data);
            controller.moveCamera(CameraUpdate.newLatLng(result));
            setState(() => location = result);
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 230,
              width: 475,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                ),
                child: GoogleMap(
                  onMapCreated: (controler) {
                    controller = controler;
                  },
                  onTap: (_) async => onTap(),
                  initialCameraPosition: CameraPosition(
                    target: location ??
                        const LatLng(37.42796133580664, -122.085749655962),
                    zoom: 12,
                  ),
                  markers: {
                    if (location != null)
                      Marker(
                        markerId: MarkerId(location.toString()),
                        position: location!,
                      ),
                  },
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => ScaleGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: textEditingController,
              enableInteractiveSelection: false,
              readOnly: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: keyType,
                prefixIcon: const Icon(Icons.location_pin),
              ),
              onTap: onTap,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (customEditHandlers != null && customEditHandlers!.containsKey(type)) {
      return customEditHandlers![type]!.call(data, textEditingController);
    }

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
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

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
          color: Theme.of(context).scaffoldBackgroundColor,
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
                ),
              ),
              trailing: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
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
                              child: const Icon(
                                Icons.location_pin,
                                size: 50,
                                color: Colors.red,
                              ),
                            ),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
