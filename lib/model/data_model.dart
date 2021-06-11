abstract class DataModel {
  // final String id;

  Map<String, Type> getDisplayParamsList();

  Map<String, Type> getCreateParamsList();

  Map<String, Type> getEditableParamsList();

  Map<String, dynamic> toMap();

  void setParameter(String key, dynamic value);
}
