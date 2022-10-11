import 'package:json_model_builder/json_model_builder.dart';

class UsableType {
  UsableType(this.type) {
    if (Model.isRegistering) return;
    if (!isRegisteredModel && !isDynamic && !isAValidNonModel) {
      throwMissingModelTypeException(type);
    }
  }

  final Type type;

  bool get isDynamic => type == dynamic;
  bool get isRegisteredModel => Model.modelsNameByType[type] != null;
  bool get isAValidNonModel {
    final types = [int, String, double, DateTime, Null, bool, ModelList, List, ModelMap, Map];
    for (final testType in types) {
      if (type == testType) return true;
    }
    return false;
  }

  Field? _primitivField() {
    final options = FieldOptions.defaultOptions;
    final dummy = DummyModel({});
    if (type == int) return IntField(parent: dummy, options: options);
    if (type == double) return DoubleField(parent: dummy, options: options);
    if (type == String) return StringField(parent: dummy, options: options);
    if (type == bool) return BoolField(parent: dummy, options: options);
    if (type == DateTime) return DateTimeField(parent: dummy, options: options);
    if (type == List) return ListField(parent: dummy, options: options);
    if (type == Map) return MapField(parent: dummy, options: options);
    if (type == Model) {
      if (type == ModelList) return ListField(parent: dummy, options: options);
      if (type == ModelField) return MapField(parent: dummy, options: options);
    }
  }

  dynamic createFromAny(dynamic json) {
    if (isDynamic) return json;

    if (isRegisteredModel && json.runtimeType == type) {
      return json;
    }

    if (isRegisteredModel && json is! Model) {
      return Model.createByType(type, json);
    }

    if (isRegisteredModel && json is Model) {
      return Model.createByType(type, json.toJson());
    }

    if (isAValidNonModel) {
      final field = _primitivField();
      field?.setFromJson(json);
      if (field != null) return field.value;
    }

    return null;
  }

  static throwMissingModelTypeException(Type type) {
    throw Exception(
        "Type <T> (now: `$type`) must be a Registered Model or `ModelMap` or `ModelList`. If using custom `Model` subclass, use Model.register('your_model', (json) => YourModel(json)).");
  }
}

class DummyModel extends Model {
  DummyModel(super.json);

  @override
  Iterable<Field> get fields => throw UnimplementedError();

  @override
  Field? get(String name) {
    throw UnimplementedError();
  }

  @override
  String nameOfField(Field field) {
    throw UnimplementedError();
  }

  @override
  toJson() {
    throw UnimplementedError();
  }
}
