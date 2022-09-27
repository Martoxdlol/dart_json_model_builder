import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import '../models.dart';

void test3() {
  test('composed model', () {
    final json = {
      'name': 'Maria',
      'username': 'mary99',
      'person': {'name': 'Maria', 'age': 26, 'address': 'Some street'}
    };
    final user1 = User(json);
    expect('Maria', user1.name.value);
    expect('mary99', user1.username.value);
    expect(true, user1.person.isLoaded);
    expect(true, user1.person.value != null);
    expect('Maria', user1.person.values?.name.value);
    expect(26, user1.person.values?.age.value);
    expect(false, JsonDiffer.fromJson(json, user1.toJson()).diff().hasChanged);
  });
}
