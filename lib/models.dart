import 'package:surrealize/fields.dart';

typedef ModelInstanciator = Model Function(dynamic json);

abstract class Model {
  Model(dynamic json);
  // Fields
  /// List all availiable fields. This is super importante to complete.
  Iterable<Field> get fields;

  // Get field by key
  Field? get(String name);

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
  ModelList(dynamic json, {Field Function(String name, dynamic json)? fieldInstanciator}) : super(null) {
    if (json is List) {
      for (int i = 0; i < json.length; i++) {
        if (fieldInstanciator != null) {
          _fields.add(fieldInstanciator(i.toString(), json));
        } else {
          _fields.add(DynamicField(i.toString(), parent: this, nullable: true).fixedType);
        }
      }
    }
  }

  @override
  Iterable<Field> get fields => _fields.toList();
  final List<Field> _fields = [];
  List<Field> get values => _fields;

  @override
  Field? get(String name) {
    int? index = int.tryParse(name);
    if (index == null) return null;
    return at(index);
  }

  Field? at(int index) {
    if (_fields.length <= index) return null;
    if (index < 0) return null;
    return _fields[index];
  }

  @override
  toJson() => values.map((e) => e.toJson()).toList();
}

class ModelMap extends Model {
  ModelMap(dynamic json) : super(null) {
    if (json is Map) {
      for (final entry in json.entries) {
        _fields[entry.key] = DynamicField(entry.key, parent: this, nullable: true).fixedType;
        _fields[entry.key]?.setFromJson(entry.value);
      }
    }
  }

  final Map<String, Field> _fields = {};

  @override
  Iterable<Field> get fields => values;

  @override
  Field? get(String name) => _fields[name];

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

  operator [](String key) => get(key);
}

abstract class ModelBuilder extends Model {
  ModelBuilder(dynamic json) : super(null) {
    fields.toList();
    if (json is Map) {
      for (final entry in json.entries) {
        get(entry.key)?.setFromJson(entry.value);
      }
    }
  }

  final Map<String, Field> _fields = {};

  /// MUST BE OVERRITEN
  @override
  Iterable<Field> get fields;

  IntField intField(String name, {bool nullable = true}) => _add(IntField(name, parent: this, nullable: nullable));
  DoubleField doubleField(String name, {bool nullable = true}) =>
      _add(DoubleField(name, parent: this, nullable: nullable));
  StringField stringField(String name, {bool nullable = true}) =>
      _add(StringField(name, parent: this, nullable: nullable));
  BoolField boolField(String name, {bool nullable = true}) => _add(BoolField(name, parent: this, nullable: nullable));
  DateTimeField dateTimeField(String name, {bool nullable = true}) =>
      _add(DateTimeField(name, parent: this, nullable: nullable));
  ModelField<ModelList> listField(String name, {bool nullable = true}) =>
      _add(ModelField<ModelList>(name, parent: this, nullable: nullable));
  ModelField<ModelMap> mapField(String name, {bool nullable = true}) =>
      _add(ModelField<ModelMap>(name, parent: this, nullable: nullable));
  ModelField<T> modelField<T>(String name, {bool nullable = true}) =>
      _add(ModelField<T>(name, parent: this, nullable: nullable));
  DynamicField dynamicField(String name, {bool nullable = true}) =>
      _add(DynamicField(name, parent: this, nullable: nullable));

  dynamic _add(Field field) {
    if (_fields[field.name] != null) return _fields[field.name];
    _fields[field.name] = field;
    return field;
  }

  @override
  Field? get(String name) => _fields[name];

  Iterable<Field> get values => _fields.values;
  Iterable<MapEntry<String, Field>> get entries => _fields.entries;

  operator [](String key) => get(key);

  @override
  toJson() {
    final map = <String, dynamic>{};
    for (final entry in entries) {
      map[entry.key] = entry.value.toJson();
    }
    return map;
  }
}
