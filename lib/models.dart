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

  /// This enables the [Model] class to instanciate model subclasses
  static void register(String name, ModelInstanciator modelInstanciator) {
    modelsByName[name] = modelInstanciator;
    modelsNameByType[modelInstanciator.call({}).runtimeType] = name;
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

class ModelBuilder {}

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
    if(json is Map) {
      for(final entry in json.entries) {
        _fields[entry.key] = DynamicField(entry.key, parent: this, nullable: true).fixedType;
        _fields[entry.key]?.setFromJson(entry.value);
      }
    }
  }
  
  final Map<String, Field> _fields = {};

  @override
  Iterable<Field> get fields => throw UnimplementedError();
  
  @override
  Field? get(String name) => _fields[name];
  
  Iterable<Field> get values => _fields.values;
  Iterable<MapEntry<String, Field>> get entries => _fields.entries;

  @override
  toJson() {
    final map = <String, dynamic>{};
    for(final entry in entries) {
      map[entry.key] = entry.value.toJson();
    }
    return map;
  }

  operator [](String key) => get(key);
}
