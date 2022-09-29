import 'package:json_model_builder/models.dart';

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
  Field({required this.parent, required this.options});
  final FieldOptions options;
  final Model parent;

  // Field name
  String get name => parent.nameOfField(this);

  // Field type (ex: String, ex: Model, ex: ModelMap)
  Type get type => T;

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
  T? get value => _loaded ? _value : null;
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
  IntField({required super.parent, required super.options});

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
  DoubleField({required super.parent, required super.options});

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
  StringField({required super.parent, required super.options});

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
  BoolField({required super.parent, required super.options});

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
class DateTimeField extends Field<DateTime> {
  DateTimeField({required super.parent, required super.options});

  @override
  bool setFromJson(json) {
    _loaded = false;
    int? ms;
    if (json is DateTime) set(json);
    if (json is int) ms = json;
    if (json is double) ms = json.toInt();
    if (ms != null) {
      final datetime = DateTime.fromMillisecondsSinceEpoch(ms);
      set(datetime);
    } else if (json is String) {
      final datetime = DateTime.tryParse(json);
      if (datetime != null) set(datetime);
    }
    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value;
}

/// Model field for native `dynamic` type
class DynamicField extends Field<dynamic> {
  DynamicField({required super.parent, required super.options});

  Field<dynamic>? _internalField;
  Model? _modelValue;

  @override
  Type get type => _modelValue != null ? Model : (_internalField?.type ?? dynamic);

  @override
  get value => _modelValue ?? _internalField?.value;

  @override
  bool get isLoaded => _modelValue != null || (_internalField?.isLoaded ?? false);

  @override
  bool setFromJson(json) {
    _internalField = null;
    _modelValue = null;
    if (json is int) _internalField = IntField(parent: parent, options: options);
    if (json is double) _internalField = DoubleField(parent: parent, options: options);
    if (json is String) _internalField = StringField(parent: parent, options: options);
    if (json is bool) _internalField = BoolField(parent: parent, options: options);
    if (json is DateTime) _internalField = DateTimeField(parent: parent, options: options);
    if (json is List) _internalField = ListField(parent: parent, options: options);
    if (json is Map) _internalField = MapField(parent: parent, options: options);
    if (json is Model) {
      if (json is ModelList) _internalField = ListField(parent: parent, options: options);
      if (json is ModelField) _internalField = MapField(parent: parent, options: options);
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
  JSONTYPE toJson() => _modelValue != null ? _modelValue!.toJson() : _internalField?.toJson();

  Field get fixedType => _internalField ?? this;
}

/// Model field for native `bool` type
class ModelField<T> extends Field<Model> {
  bool _isMap = false;
  bool _isList = false;
  ModelField({required super.parent, required super.options, this.useModelInstanciator}) {
    if (type == ModelList) _isList = true;
    if (type == ModelMap) _isMap = true;
    if (!_isList && !_isMap && !Model.isRegistering && Model.modelsNameByType[type] == null) {
      throw Exception(
          "Type <T> (now: `$type`) must be a Registered Model or `ModelMap` or `ModelList`. If using custom `Model` subclass, use Model.register('your_model', (json) => YourModel(json)).");
    }
  }

  ModelInstanciator? useModelInstanciator;

  @override
  Type get type => useModelInstanciator != null ? useModelInstanciator!.call({}).runtimeType : T;
  T? get current => super.value as T?;

  @override
  bool setFromJson(json) {
    _loaded = false;

    if (json.runtimeType == type) {
      set(json);
    } else if (useModelInstanciator != null) {
      set(useModelInstanciator!.call(json));
      return isLoaded;
    }

    if (_isList) {
      set(ModelList(
        json,
      ));
    } else if (_isMap) {
      set(ModelMap(
        json,
      ));
    } else if (json is Model) {
      final value = Model.createByType(type, json.toJson());
      if (value != null) set(value);
    } else {
      final value = Model.createByType(type, json);
      if (value != null) set(value);
    }

    return isLoaded;
  }

  @override
  JSONTYPE toJson() => value?.toJson();
}

typedef ListField = ModelField<ModelList>;
typedef MapField = ModelField<ModelMap>;

typedef FieldValueValidator<T> = bool Function(T value);

class FieldOptions {
  const FieldOptions({this.nullable = true, this.validator});
  final bool nullable;
  final FieldValueValidator? validator;
  static const defaultOptions = FieldOptions();
}
