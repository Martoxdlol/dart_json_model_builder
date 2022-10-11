import 'dart:collection';

import 'package:json_model_builder/types.dart';

/// JsonType list compatible to List
class JsonList<T extends JsonType> extends ListBase<T> implements JsonType {
  JsonList(this.childCreator);

  final T Function() childCreator;

  final List<T> _list = <T>[];

  @override
  bool setFromJson(json) {
    if (json is Iterable) {
      _list.clear();
      for (final value in json) {
        _list.add(childCreator()..setFromJson(value));
      }
      return true;
    }
    return false;
  }

  @override
  void add(T element) => _list.add(element);

  @override
  toJson() => _list.map((e) => e.toJson()).toList();

  @override
  int get length => _list.length;

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) => _list[index] = value;

  @override
  set length(int newLength) => _list.length = newLength;
}

/// JsonTypeNullable list compatible to List
class JsonListNullable<T extends JsonType> extends JsonList<T>
    implements JsonTypeNullable {
  JsonListNullable(super.childCreator);

  bool _isNull = true;

  @override
  bool get isNull => _isNull;

  set isNull(bool isNull) {
    if (isNull) _list.clear();
    _isNull = isNull;
  }

  @override
  bool setFromJson(json) {
    final result = super.setFromJson(json);
    if (result == true) {
      isNull = false;
    } else {
      isNull = true;
      _list.clear();
    }
    return true;
  }

  @override
  toJson() => isNull ? null : super.toJson();

  @override
  int get length => !isNull
      ? super.length
      : throw Exception('Null List doesn\'t have length');

  @override
  operator [](int index) => !isNull
      ? super[index]
      : throw Exception('Null List doesn\'t have any value at any index');

  @override
  void operator []=(int index, value) => !isNull
      ? super[index] = value
      : throw Exception('Cannot set value of a null List');

  @override
  set length(int newLength) => !isNull
      ? super.length = newLength
      : throw Exception('Cannot set length of a null List');
}
