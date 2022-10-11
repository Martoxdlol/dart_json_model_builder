import 'package:json_diff/json_diff.dart';
import 'package:json_model_builder/json_model_builder.dart';
import 'package:test/expect.dart';

void spectJsonNoChange(JsonType jsonOnj, dynamic initialJson) {
  expect(false,
      JsonDiffer.fromJson(initialJson, jsonOnj.toJson()).diff().hasChanged);
}
