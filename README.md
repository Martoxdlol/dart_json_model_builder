# Build JSON serializable classes without code gen or mirrors


## Example
```dart
class Person extends ModelBuilder {
  Person(super.json);

  @override
  Iterable<Field> get fields => [age, name, address];

  StringField get name => stringField('name');
  StringField get address => stringField('address');
  IntField get age => intField('age');
}

void main() {
    // Can fill model from JSON
    final me = Person({ 'name': 'Tomás', 'age': 20 });

    // Can know if field is filled or not
    if(!me.address.isLoaded) {
        // Set property one by one
        me.address.set('123 Some Street, Somewhere');
    }

    // Print single property
    print('Name: ${me.name.value}');

    // Convert to json
    print(me.toJson());
}
```

## Other example
```dart
class Person extends ModelBuilder {
  Person(super.json);

  @override
  Iterable<Field> get fields => [age, name, address];

  StringField get name => stringField('name');
  StringField get address => stringField('address');
  IntField get age => intField('age');
}

void main() {
    // Can fill model from JSON
    final me = Person({ 'name': 'Tomás', 'age': 20 });

    // Can know if field is filled or not
    if(!me.address.isLoaded) {
        // Set property one by one
        me.address.set('123 Some Street, Somewhere');
    }

    // Print single property
    print('Name: ${me.name.value}');

    // Convert to json
    print(me.toJson());
}
```
