import 'package:json_model_builder/fields.dart';
import 'package:json_model_builder/usable_type.dart';

typedef ModelInstanciator = Model Function(dynamic json);

abstract class Model {
  Model(dynamic json);
  // Fields
  /// List all availiable fields. This is super importante to complete.
  Iterable<Field> get fields;

  // Get field by key
  Field? get(String name);

  // Get name of field
  String nameOfField(Field field);

  // Gloabl model registration
  static final modelsByName = <String, ModelInstanciator>{};
  static final modelsNameByType = <Type, String>{};

  static bool isRegistering = false;

  /// This enables the [Model] class to instanciate model subclasses
  static void register(String name, ModelInstanciator modelInstanciator) {
    isRegistering = true;
    modelsByName[name] = modelInstanciator;
    modelsNameByType[modelInstanciator.call({}).runtimeType] = name;
    isRegistering = false;
  }

  static Model? createByName(String name, [dynamic json]) {
    return modelsByName[name]?.call(json);
  }

  static Model? createByType(Type type, [dynamic json]) {
    if (!modelsNameByType.containsKey(type)) return null;
    return modelsByName[modelsNameByType[type]!]?.call(json);
  }

  dynamic toJson();
}

class ModelList extends Model {
  ModelList(dynamic json, {this.type, Field Function(String name, dynamic json)? fieldInstanciator}) : super(null) {
    if (json is List) {
      for (int i = 0; i < json.length; i++) {
        _addField(json[i], fieldInstanciator);
      }
    }
  }

  bool _addField(dynamic json, Field Function(String name, dynamic json)? fieldInstanciator) {
    int index = length;
    final key = index.toString();
    if (fieldInstanciator != null) {
      _fields.add(fieldInstanciator(key, json));
      get(key)!.setFromJson(json);
      return true;
    }

    final usableType = UsableType(type ?? dynamic);

    if (usableType.isRegisteredModel) {
      _fields.add(ModelField(
        parent: this,
        options: FieldOptions.defaultOptions,
        useModelInstanciator: (json) => Model.createByType(type!, json)!,
      ));
      get(key)!.setFromJson(json);
      return true;
    }

    final value = usableType.createFromAny(json);
    if (!usableType.isDynamic && value == null) {
      return false;
    }

    _fields.add(DynamicField(parent: this, options: FieldOptions.defaultOptions).fixedType);
    get(key)!.setFromJson(value);
    return true;
  }

  final Type? type;

  int get length => values.length;
  Field<dynamic> get first => values.first;
  Field<dynamic> get last => values.last;

  @override
  Iterable<Field> get fields => _fields.toList();
  final List<Field> _fields = [];
  List<Field> get values => _fields;

  @override
  String nameOfField(Field field) => _fields.indexOf(field).toString();

  @override
  Field? get(String name) {
    int? index = int.tryParse(name);
    if (index == null) return null;
    return at(index);
  }

  bool set(int index, dynamic value) => at(index)?.setFromJson(value) ?? false;

  bool add(dynamic value) {
    return _addField(value, null);
  }

  Field? at(int index) {
    if (_fields.length <= index) return null;
    if (index < 0) return null;
    return _fields[index];
  }

  Field? operator [](int i) => at(i);
  void operator []=(int i, dynamic value) {
    if (i == length) {
      _addField(value, null);
    } else {
      set(i, value);
    }
  }

  @override
  toJson() => values.map((e) => e.toJson()).toList();
}

abstract class MapModelBasics implements Model {
  final Map<String, Field> _fields = {};

  @override
  String nameOfField(Field field) {
    for (final entry in _fields.entries) {
      if (identical(entry.value, field)) {
        return entry.key;
      }
    }
    throw Exception(
        'Field type `${field.runtimeType}` not found in model type `$runtimeType`. Check if your properly added field to model.');
  }

  Field registerField(String name, Field field) {
    if (_fields[name] != null && _fields[name].runtimeType == field.runtimeType) {
      return _fields[name]!;
    }
    _fields[name] = field;
    return field;
  }

  @override
  Field? get(String name) => _fields[name];

  bool set(String key, dynamic value) => _fields[key]?.setFromJson(value) ?? false;

  Iterable<Field> get values => _fields.values;
  Iterable<MapEntry<String, Field>> get entries => _fields.entries;

  @override
  toJson() {
    final map = <String, dynamic>{};
    for (final entry in entries) {
      map[entry.key] = entry.value.toJson();
    }
    return map;
  }

  Field? operator [](String key) => get(key);
  void operator []=(String key, dynamic vlaue) => set(key, vlaue);
}

class ModelMap extends Model with MapModelBasics {
  ModelMap(dynamic json, {this.type}) : super(null) {
    if (Model.isRegistering) return;
    if (json is Map) {
      for (final entry in json.entries) {
        final usableType = UsableType(type ?? dynamic);
        final value = usableType.createFromAny(entry.value);
        if (usableType.isRegisteredModel) {
          if (value != null) {
            _fields[entry.key] = ModelField(
                parent: this, options: FieldOptions.defaultOptions, useModelInstanciator: (json) => Model.createByType(type!, json)!);
          }
        } else if (!usableType.isDynamic) {
          if (value != null) _fields[entry.key] = DynamicField(parent: this, options: FieldOptions.defaultOptions).fixedType;
        } else {
          _fields[entry.key] = DynamicField(parent: this, options: FieldOptions.defaultOptions).fixedType;
        }

        _fields[entry.key]?.setFromJson(value);
      }
    }
  }

  @override
  Iterable<Field> get fields => values;

  final Type? type;
}

abstract class ModelBuilder extends Model with MapModelBasics {
  ModelBuilder(dynamic json) : super(null) {
    fields.toList();
    if (json is Map) {
      for (final entry in json.entries) {
        get(entry.key)?.setFromJson(entry.value);
      }
    }
  }

  /// MUST BE OVERRITEN
  @override
  Iterable<Field> get fields;

  IntField intField(String name, {FieldOptions options = FieldOptions.defaultOptions}) => _add(
      name,
      IntField(
        parent: this,
        options: options,
      ));

  DoubleField doubleField(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, DoubleField(parent: this, options: options));

  StringField stringField(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, StringField(parent: this, options: options));

  BoolField boolField(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, BoolField(parent: this, options: options));

  DateTimeField dateTimeField(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, DateTimeField(parent: this, options: options));

  ModelField<ModelList> listField<T>(String name, {Type? type, FieldOptions options = FieldOptions.defaultOptions}) => _add(
      name,
      ModelField<ModelList>(
        parent: this,
        options: options,
        useModelInstanciator: (json) => ModelList(json, type: type),
      ));

  ModelField<ModelMap> mapField<T>(String name, {Type? type, FieldOptions options = FieldOptions.defaultOptions}) => _add(
      name,
      ModelField<ModelMap>(
        parent: this,
        options: options,
        useModelInstanciator: (json) => ModelMap(json, type: type),
      ));

  ModelField<T> modelField<T>(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, ModelField<T>(parent: this, options: options));

  DynamicField dynamicField(String name, {FieldOptions options = FieldOptions.defaultOptions}) =>
      _add(name, DynamicField(parent: this, options: options));

  dynamic _add(String name, Field field) {
    if (_fields[name] != null) return _fields[name];
    _fields[name] = field;
    return field;
  }
}
