import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import '../models.dart';

void test1() {
  test('basic initialization from json', () {
    final name = 'Maria';
    final age = 26;
    final address = '123 some street, some city';
    final json = {
      'name': name,
      'age': age,
      'address': address,
    };
    final maria = Person(json);

    // Test properties
    expect(maria.name.value, name);
    expect(maria.age.value, age);
    expect(maria.address.value, address);
    // Test fields
    expect(maria.fields.length, 3);
    expect(false, JsonDiffer.fromJson(json, maria.toJson()).diff().hasChanged);
  });
}
