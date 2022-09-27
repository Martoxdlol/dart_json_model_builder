import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import '../models.dart';

void test2() {
  test('set keys mannualy', () {
    final name = 'Maria';
    final age = 26;
    final address = '123 some street, some city';
    final json = {
      'name': name,
      'age': age,
      'address': address,
    };
    final maria = Person({
      'name': 'Maria',
    });

    // Test incomplete properties
    expect(maria.age.value, null);
    expect(maria.age.isLoaded, false);
    expect(maria.address.value, null);
    expect(maria.address.isLoaded, false);

    maria.age.set(age);
    maria.address.set(address);

    // Test properties
    expect(maria.name.value, name);
    expect(maria.age.value, age);
    expect(maria.age.isLoaded, true);
    expect(maria.address.value, address);
    expect(maria.address.isLoaded, true);
    // Test fields
    expect(false, JsonDiffer.fromJson(json, maria.toJson()).diff().hasChanged);
  });
}
