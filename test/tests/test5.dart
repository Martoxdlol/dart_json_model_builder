import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import '../models.dart';

void test5() {
  test('fields names', () {
    final person = Person({});
    expect('name', person.name.name);
    expect('age', person.age.name);
    expect('address', person.address.name);
  });
}
