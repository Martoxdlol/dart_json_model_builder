import 'package:json_model_builder/json_model_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void testBasics() {
  test('primitive (int)', () {
    final int1 = JsonInt();
    expect(int1.isSet, false);

    expect(int1.setFromJson(10), true);
    expect(int1.value, 10);
    expect(int1.valueOrNull, 10);
    expect(int1.isSet, true);

    expect(int1.setFromJson('20'), true);
    expect(int1.value, 20);
    expect(int1.valueOrNull, 20);
    expect(int1.isSet, true);

    expect(int1.setFromJson('bad'), false);
    expect(int1.valueOrNull, null);
    expect(int1.isSet, false);

    bool exceptionTriggered = false;
    try {
      int1.value;
    } catch (e) {
      exceptionTriggered = true;
    }
    expect(exceptionTriggered, true);
  });

  test('nullable-primitive (int)', () {
    final int1 = JsonIntNullable();
    expect(int1.setFromJson(10), true);
    expect(int1.value, 10);
    expect(int1.valueOrNull, 10);
    expect(int1.isNull, false);
    expect(int1.isSet, true);

    expect(int1.setFromJson('20'), true);
    expect(int1.value, 20);
    expect(int1.valueOrNull, 20);
    expect(int1.isNull, false);
    expect(int1.isSet, true);

    expect(int1.setFromJson('bad'), true);
    expect(int1.value, null);
    expect(int1.valueOrNull, null);
    expect(int1.isNull, true);
    expect(int1.isSet, false);
  });

  test('primitive String', () {
    final string1 = JsonString();
    expect(string1.isSet, false);

    string1.value = 'Hi';
    expect(string1.isSet, true);
    expect(string1.toJson(), 'Hi');
    expect(string1.valueOrNull, 'Hi');

    string1.setFromJson(2000);
    expect(string1.isSet, true);
    expect(string1.toJson(), '2000');
    expect(string1.valueOrNull, '2000');
  });

  test('primitive bool', () {
    final bool1 = JsonBool();
    expect(bool1.isSet, false);

    bool1.value = true;
    expect(bool1.isSet, true);
    expect(bool1.toJson(), true);
    expect(bool1.valueOrNull, true);

    bool1.setFromJson('false');
    expect(bool1.isSet, true);
    expect(bool1.toJson(), false);
    expect(bool1.valueOrNull, false);
  });

  test('primitive DateTime', () {
    final time = JsonDateTime();
    final y2020 = DateTime(2020);
    time.value = y2020;

    expect(time.value, y2020);
    expect(time.toJson(), y2020.toIso8601String());

    expect(time.setFromJson(y2020.millisecondsSinceEpoch), true);
    expect(time.toJson(), y2020.toIso8601String());
    expect(time.value, y2020);

    expect(time.setFromJson(y2020.toIso8601String()), true);
    expect(time.toJson(), y2020.toIso8601String());
    expect(time.value, y2020);

    expect(time.setFromJson('invalid'), false);
    expect(time.valueOrNull, null);
  });
}
