abstract class DataModel {
  // final String id;

  Map<String, Type> getDisplayParamsList();

  Map<String, Type> getCreateParamsList();

  Map<String, Type> getEditableParamsList();

  Map<String, dynamic> toMap();

  DataModel setParameter(String key, dynamic value);
}
