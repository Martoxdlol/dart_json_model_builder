import 'package:surrealize/models.dart';

import 'models.dart';
import 'tests/test1.dart';
import 'tests/test2.dart';
import 'tests/test3.dart';
import 'tests/test5.dart';

void main() {
  Model.register('person', (json) => Person(json));
  Model.register('user', (json) => User(json));

  test1();
  test2();
  test3();
  test5();
}
