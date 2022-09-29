# Build JSON serializable classes without code gen or mirrors

This library provides a way to create modeles easily usable from code that can be serialized into/from JSON.

Instead of directly using variables of the corresponding types we use 'fields'. 
A 'field' has a type. 

### Models

Every class that must be json serializable from this library is a subclass of Model.
A model can
 - Be serialized to JSON
 - Be instanciated from parsed JSON
 - Have fields with a type of Model
 - Be able to correctly create it sub model fields from JSON

If you have a Model that has some field with type of other model, this will work fine. 
Instanciating the parent from json will also instanciate the child correctly.

## Example
```dart
class Person extends ModelBuilder {
  Person(super.json);

  // IMPORTANT: you must put all your field here to ensure that it will work
  @override
  Iterable<Field> get fields => [age, name, address, properties, numbersArray, otherHomes];

  StringField get name => stringField('name');
  IntField get age => intField('age');

  ModelField<Address> get address => modelField('address'); // It will parse json to instance of Address 

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

void main() {
  // IMPORTANT: you must register Model types
  Model.register('person', (json) => Person(json));
  Model.register('address', (json) => Address(json));

  // Can fill model from JSON
  final me = Person({
    'name': 'Tomás',
    'age': 20,
    'address': {
      'street': 'Some Street',
      'city': 'Some City',
      'country': 'Dream Land',
    }
  });

  // Can know if field is filled or not
  if(!me.numbersArray.isLoaded) {
      // Set property one by one
      me.numbersArray.set([1, 2, 3, 4, '5', 'invalid, this will ve ignored' ]);
  }

  me.age.set(21);

  // Print single property
  print('Name: ${me.name.value}');

  // Convert to json
  print(me.toJson());

  // If using a 'ModelField<SomeType>', use current instead of value
  // It will have the corresponding type 
  // The value readed here was created from json as 'Address'
  Address address = me.address.current;

}
```


## List
To create a field with type list use
```dart
// List of int (cannot have any value type other than int)
ListField get numbersArray => listField('numbers_array', type: int); 

// Can have any value type
// ListField is equivalent to ModelField<ModelList>
ModelField<ModelList> get things => listField('things_array'); 

// Can have a model as type
ListField get homes => listField('homes', type: Address); 


// Read value
int index = 3;
someone.homes.current?[index]?.value
someone.homes.current?.get(index)?.value

// Weite value
someone.homes.current?.add({ ... })
someone.homes.current?.add(Address({ ... }))
someone.homes.current?[1] = Address({ ... })
someone.homes.current?[someone.homes.current.length] = { ... } // It will be converted from json to Address
someone.homes.current?.set(2, Address({ ... }))
someone.homes.current?.set(2, { ... })
```

## Map
To create a field with type mape use
```dart
// List of int (cannot have any value type other than int)
MapField get numbersArray => mapField('amounts', type: int); 

// Can have any value type
MapField get things => mapField('things'); 

// Can have a model as type
// MapField is equivalent to ModelField<ModelMap>
ModelField<ModelMap> get homes => mapField('homes', type: Address); 


// Read value
someone.homes.current?['some_home_id']?.value
someone.homes.current?.get('some_home_id')?.value

// Weite value
someone.homes.current?['some_home_id'] = Address({ ... })
someone.homes.current?['some_home_id'] = { ... } // It will be converted from json to Address
someone.homes.current?.set('some_home_id', Address({ ... }))
someone.homes.current?.set('some_home_id', { ... })

```

## All types
```dart
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
```


