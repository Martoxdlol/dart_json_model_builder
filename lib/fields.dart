import 'package:surrealize/models.dart';

/// We have different types of fields
///
/// This database model is based on json
///
/// But with extra things
///
/// Json normally have Number,String,Boolean,List,Map,Null
///
/// This adds Datetime and Sets
///
/// A user can also extend Field class to support custom types
///
abstract class Field<T> {
  Field(this.name, {required this.parent, required this.nullable});
  final String name;
  final bool nullable;
  final Model parent;

  /// Convert and set any json to `T`
  /// It doesn't crash if passed incorrect data type value
  /// If it fails to put value it returns `false`
  bool setFromJson(JSONTYPE json);

  /// Convert `T` to json compatible
  JSONTYPE toJson();

  // Field can be ulodad (ej: partial `select` sql query)
  bool _loaded = false;
  bool get isLoaded => _loaded;

  // Store the value privately
  T? _value;
  T? get value => _loaded ? _value : throw Exception('Value of field `$name` must be loaded first');
  bool get isNull => value == null;

  // Setter, this is more clear than using a native setter
  void set(T value) {
    _value = value;
    _loaded = true;
  }
}

typedef JSONTYPE = dynamic;

/// Model field for native `int` type
class IntField extends Field<int> {
  IntField(super.name, {required super.parent, required super.nullable});

  @override
  bool setFromJson(json) {
    _loaded = false;
    if (json is int) set(json);
    if (json is double) set(json.toInt());
    if (json is String && int.tryParse(json) != null) set(int.parse(json));
    if (json is bool) set(json ? 1 : 0);
    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}

/// Model field for native `int` type
class DoubleField extends Field<double> {
  DoubleField(super.name, {required super.parent, required super.nullable});

  @override
  bool setFromJson(json) {
    _loaded = false;
    if (json is double) set(json);
    if (json is int) set(json.toDouble());
    if (json is String && double.tryParse(json) != null) {
      set(double.parse(json));
    }
    if (json is bool) set(json ? 1.0 : 0.0);
    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}

/// Model field for native `String` type
class StringField extends Field<String> {
  StringField(super.name, {required super.parent, required super.nullable});

  @override
  bool setFromJson(json) {
    _loaded = false;
    if (json is String) set(json);
    if (json is double) set(json.toString());
    if (json is int) set(json.toString());
    if (json is bool) set(json.toString());
    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}

/// Model field for native `bool` type
class BoolField extends Field<bool> {
  BoolField(super.name, {required super.parent, required super.nullable});

  @override
  bool setFromJson(json) {
    _loaded = false;
    if (json is bool) set(json);
    if (json is String) set(json == 'true');
    if (json is double) set(json > 0);
    if (json is int) set(json > 0);
    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}

/// Model field for native `bool` type
class DynamicField extends Field<dynamic> {
  DynamicField(super.name, {required super.parent, required super.nullable});

  Field<dynamic>? _internalField;
  Model? _modelValue;

  @override
  get value => _modelValue ?? _internalField?.value;

  @override
  bool get isLoaded => _modelValue != null || (_internalField?.isLoaded ?? false);

  @override
  bool setFromJson(json) {
    _internalField = null;
    _modelValue = null;
    if (json is int) _internalField = IntField(name, parent: parent, nullable: nullable);
    if (json is double) _internalField = DoubleField(name, parent: parent, nullable: nullable);
    if (json is String) _internalField = StringField(name, parent: parent, nullable: nullable);
    if (json is bool) _internalField = BoolField(name, parent: parent, nullable: nullable);
    if (json is List) _internalField = ModelField<ModelList>(name, parent: parent, nullable: nullable);
    if (json is Map) _internalField = ModelField<ModelMap>(name, parent: parent, nullable: nullable);
    if (json is Model) {
      if (json is ModelList) _internalField = ModelField<ModelList>(name, parent: parent, nullable: nullable);
      if (json is ModelField) _internalField = ModelField<ModelMap>(name, parent: parent, nullable: nullable);
      if (_internalField == null) {
        _modelValue = json;
        return true;
      }
    }

    _internalField?.setFromJson(json);
    return isLoaded;
  }

  @override
  void set(value) {
    if (!setFromJson(value)) {
      throw Exception(
          'Cannot set value of type `${value.runtimeType}` to dynamic field. It must be a JSON primitive or `Model` subclass.');
    }
  }

  void useField(Field field) {
    _internalField = field;
  }

  @override
  JSONTYPE toJson() => value;

  Field get fixedType => _internalField ?? this; 
}

/// Model field for native `bool` type
class ModelField<T> extends Field<Model> {
  bool _isMap = false;
  bool _isList = false;
  ModelField(super.name, {required super.parent, required super.nullable}) {
    if (T == ModelList) _isList = true;
    if (T == ModelMap) _isMap = true;
    if (Model.modelsNameByType[T] == null) {
      throw Exception("Type <T> must be a Registered Model or `ModelMap` or `ModelList`");
    }
  }

  @override
  bool setFromJson(json) {
    _loaded = false;

    if (_isList) {
      set(ModelList(json));
    } else if (_isMap) {
      set(ModelMap(json));
    } else {
      final value = Model.createByType(T, json);
      if (value != null) set(value);
    }

    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}
