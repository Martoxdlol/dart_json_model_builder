import 'package:json_model_builder/json_model_builder.dart';

class JsonNullable<T extends JsonType> extends JsonType implements JsonTypeNullable {
  T Function() childCreator;
  JsonNullable(this.childCreator);
  T? current;

  @override
  bool get isNull => current == null;

  @override
  bool setFromJson(json) {
    if (json is T) {
      current = json;
      return true;
    }
    final child = childCreator();
    final result = child.setFromJson(json);
    if (result) {
      current = child;
    }
    return result;
  }

  void set(T? value) {
    current = value;
  }

  @override
  toJson() {
    return current?.toJson();
  }
}
