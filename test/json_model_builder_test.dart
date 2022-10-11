import 'package:test/scaffolding.dart';

import 'test_basics.dart';
import 'test_lists_and_maps.dart';
import '../example/main.dart' as example;
import 'test_models.dart';

void main() {
  testBasics();
  testListsAndMaps();
  testModels();
  test('main example', () {
    example.main([]);
  });
}
