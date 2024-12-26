import 'dart:convert';

import 'package:crud_table/crud_table.dart';
import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/util/component_type.dart';
import 'package:crud_table/util/edit_utils.dart';
import 'package:crud_table/util/strings.dart';
import 'package:crud_table/util/validator.dart';
import 'package:crud_table/widgets/test.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EditType { add, update }

class EditView<T extends DataModel> extends StatefulWidget {
  /// The type of editing operation (e.g., create, update, delete).
  final EditType type;

  /// The data model instance of type [T] that is being edited.
  final T data;

  /// A list of data models that includes the data being edited.
  final List<T> dataTable;

  /// A map of custom handlers for editing specific data types.
  final Map<Type, CustomEditHandlers>? customEditHandlers;

  /// A widget that provides an interface for editing a specific data model entry.
  ///
  /// The [EditView] widget is designed to edit a single entry of type [T] from a table of data models.
  /// It can handle different types of editing through the [EditType] enum and supports custom
  /// editing handlers for specific data types. The widget can be customized to manage complex
  /// editing logic with a combination of built-in and custom handlers.
  ///
  /// ### Type Parameter:
  /// - `T`: A type that extends [DataModel], representing the type of data being edited.
  ///
  /// ### Constructor Parameters:
  ///
  /// #### Required:
  /// - [type]: The [EditType] representing the type of editing operation (e.g., create, update).
  /// - [data]: The instance of type [T] that holds the data being edited.
  /// - [dataTable]: A [List] of data entries, including the current data being edited.
  ///
  /// #### Optional:
  /// - [customEditHandlers]: A map of custom handlers for editing specific types of data. The key is
  ///   the type of data and the value is the associated [CustomEditHandlers].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// EditView<UserModel>(
  ///   type: EditType.update,
  ///   data: userData,
  ///   dataTable: userDataList,
  ///   customEditHandlers: {
  ///     CustomFieldType: (data, controller) => CustomFieldEditWidget(data, controller),
  ///   },
  /// );
  /// ```
  ///
  /// This widget is part of the CRUD system and allows for flexible editing of data models.
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
  bool isFromAndToStationTheSame = false;
  bool isFromAndToStationExisting = false;
  bool isUnlimitedPeriodOneExist = false;

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

        if (widget.type == EditType.update && key == ComponentType.promoCode) {
          enabled = false;
        } else if (widget.type == EditType.update &&
            key == ComponentType.fromStation) {
          enabled = false;
        } else if (widget.type == EditType.update &&
            key == ComponentType.toStation) {
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
              errorWidget(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // This will prevent the user from adding an existing promo code
                      if (ValidateInput().isPromoCodeExist(
                        type: widget.type,
                        table: widget.dataTable,
                        controllers: _formControllers,
                      )) {
                        setState(() {
                          isPromoCodeExist = true;
                          isFromAndToStationTheSame = false;
                          isFromAndToStationExisting = false;
                        });
                      }
                      if(ValidateInput().containsUnlimitedPass(
                          ticketType: widget.data.toString()
                      )) {
                        setState(() {
                          isUnlimitedPeriodOneExist = true;
                        });
                      }
                      // This will prevent user from adding or updating a record with same From Station and To Station
                      else if (ValidateInput().isFromAndToStationNameTheSame(
                        type: widget.type == EditType.add ||
                            widget.type == EditType.update,
                        controllers: _formControllers,
                      )) {
                        setState(() {
                          isPromoCodeExist = false;
                          isFromAndToStationTheSame = true;
                          isFromAndToStationExisting = false;
                        });
                        // This will prevent user from adding or updating a record with same From Station and To Station that is existing in the DataTable
                      } else if (ValidateInput().isFromAndToStationNameExist(
                        type: widget.type == EditType.add ||
                            widget.type == EditType.update,
                        table: widget.dataTable,
                        controllers: _formControllers,
                      )) {
                        setState(() {
                          isPromoCodeExist = false;
                          isFromAndToStationTheSame = false;
                          isFromAndToStationExisting = true;
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

  Widget errorWidget() {
    String errMessage = "";
    if (isPromoCodeExist) {
      errMessage = Strings.existingPromoCodeErrorMessage;
    } else if (isFromAndToStationTheSame) {
      errMessage = Strings.fromAndToStationErrorMessage;
    } else if (isFromAndToStationExisting) {
      errMessage = Strings.existingFromAndToStationErrorMessage;
    }

    return Center(
      child: Text(
        errMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class TextFieldWidget extends StatefulWidget {
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

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool passwordVisible = false;
  Widget textField() {
    return TextFormField(
      enabled: widget.enabled ?? true,
      controller: widget.textEditingController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType:
          widget.type == num ? TextInputType.number : TextInputType.text,
      obscureText: (widget.keyType == ComponentType.passwordTypeUpperCase ||
              widget.keyType == ComponentType.passwordTypeLowerCase) &&
          !passwordVisible,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorMaxLines: 3,
        labelText: widget.keyType,
        suffixIcon: widget.keyType == ComponentType.passwordTypeUpperCase ||
                widget.keyType == ComponentType.passwordTypeLowerCase
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (widget.keyType == ComponentType.passwordTypeUpperCase ||
            widget.keyType == ComponentType.passwordTypeLowerCase) {
          return Validator.validatePassword(value);
        }
        if ((widget.keyType == ComponentType.emailTypeUpperCase ||
                widget.keyType == ComponentType.emailTypeLowerCase) &&
            !Validator.validateEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget dateTimeTextField() {
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.keyType,
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
    LatLng? location = widget.data;
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

            widget.textEditingController.text = json.encode(data);
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
              controller: widget.textEditingController,
              enableInteractiveSelection: false,
              readOnly: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.keyType,
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
    if (widget.customEditHandlers != null &&
        widget.customEditHandlers!.containsKey(widget.type)) {
      return widget.customEditHandlers![widget.type]!
          .call(widget.data, widget.textEditingController);
    }

    switch (widget.type) {
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
