import 'package:json_model_builder/fields.dart';
import 'package:json_model_builder/models.dart';

class Human extends ModelBuilder {
  Human(super.json);

  @override
  Iterable<Field> get fields => [age, name, address, properties, numbersArray, otherHomes];

  StringField get name => stringField('name');
  IntField get age => intField('age');

  ModelField<Address> get address => modelField('address');

  ModelField<ModelMap> get properties => mapField('props'); // Equivalent to: Map<String, dynamic>

  ModelField<ModelList> get numbersArray => listField('numbers_array', type: int); //Equivalent to List<int>

  ModelField<ModelMap> get otherHomes => mapField('homes', type: Address); // Equivalent to: Map<String, dynamic>
}

class Address extends ModelBuilder {
  Address(super.json);

  @override
  Iterable<Field> get fields => [street, number, city, state, country];

  StringField get street => stringField('street');
  IntField get number => intField('number');
  StringField get city => stringField('city');
  StringField get state => stringField('state');
  StringField get country => stringField('country');
}

void main(List<String> args) {
  Model.register('human', (json) => Human(json));
  Model.register('address', (json) => Address(json));
  Model.register('all_types', (json) => ModelUsingAllPosibleTypes(json));

  final tomas = Human({
    'name': 'Tomás',
    'age': 20, // You can also use: 'age': '20' and it will be converted to int
    'address': {
      'street': 'Some Street',
      'city': 'Some City',
      'country': 'Dream Land',
    }
  });

  tomas.address.current?.number.set(1234);

  final department = Address({
    'street': 'Some Street',
    'number': 123,
    'city': 'Some City',
    'country': 'Dream Land',
  });

  tomas.otherHomes.current?.set('department', department);

  if (!tomas.numbersArray.isLoaded) {
    tomas.numbersArray.setFromJson([
      10,
      20,
      '30', // Will be converted to int
      'xyz', // Will be ignored
    ]);
  }

  //field `properties` can have any value type
  tomas.properties.setFromJson({
    'score': 100,
  });
  tomas.properties.current!['cats'] = ['Luna', 'Lily', 'Daddy'];
  tomas.properties.current!.set('born', 2002);

  final lucas = Human({
    'name': 'Lucas',
    'address': {
      'street': 'Some Street',
      'number': 123,
      'city': 'Some City',
      'country': 'Dream Land',
    },
    'homes': {
      'vacation': {'street': 'beach', 'number': 123}
    }
  });

  String lucasName = lucas.name.value!;
  Address lucasMainHome = lucas.address.current!;

  // Using .value or .current is equivalent
  // current can only be used over ModelFields and returns the correct type
  assert(lucasMainHome == lucas.address.value);
  assert(lucasMainHome == lucas.address.value as Address);

  final vacationHome = lucas.otherHomes.current!['vacation']!.value;
  assert(vacationHome is Address);
  assert((vacationHome as Address).street.value == 'beach');
  assert((vacationHome as Address).number.value == 123);

  final something = ModelUsingAllPosibleTypes({
    'date': DateTime.now(),
    'integer': 10,
    'number': 33.33,
    'name': 'Tobby',
    'is_correct': true,
    'things': [
      1,
      'three',
      Human({'name': 'four'}),
      ['x', 'x', 'x', 'x', 'x'],
    ],
    'numbers': [10, 20, '30', '40'],
    'friends': [
      Human({'name': 'Lucas'}),
      {'name': 'John', 'age': 35},
    ],
    'properties': {
      'prop1': 10,
      'props2': '...',
      'other': {'...': '...'}
    },
    'scores': {
      'tobby': 10,
      'licas': 20,
    },
    'players': {
      'lucas': {'name': 'Lucas'},
      'john': Human({'name': 'John', 'age': 35}),
    }
  });

  assert(something.numbers.current![3]!.value is double);
  assert(something.friends.current![1]!.value is Human);
  assert(something.playersByName.current!['lucas']!.value is Human);
  // print(something.toJson());
}

class ModelUsingAllPosibleTypes extends ModelBuilder {
  ModelUsingAllPosibleTypes(super.json);

  @override
  Iterable<Field> get fields => [date, integer, number, name, correct, arrayOfAny, numbers, friends, properties, scores, playersByName];

  DateTimeField get date => dateTimeField('date');

  IntField get integer => intField('integer');

  DoubleField get number => doubleField('number');

  StringField get name => stringField('name');

  BoolField get correct => boolField('is_correct');

  ListField get arrayOfAny => listField('things');

  ListField get numbers => listField('numbers', type: double);

  ListField get friends => listField('friends', type: Human);

  MapField get properties => mapField('properties');

  MapField get scores => mapField('scores', type: int);

  MapField get playersByName => mapField('players', type: Human);
}
