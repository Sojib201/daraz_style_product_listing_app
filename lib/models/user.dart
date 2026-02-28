class UserModel {
  final int id;
  final String email;
  final String username;
  final Name name;
  final String phone;
  final Address address;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        username: json['username'] as String,
        name: Name.fromJson(json['name'] as Map<String, dynamic>),
        phone: json['phone'] as String,
        address: Address.fromJson(json['address'] as Map<String, dynamic>),
      );

  String get fullName {
    final f = name.firstname;
    final l = name.lastname;
    return '${f[0].toUpperCase()}${f.substring(1)} '
        '${l[0].toUpperCase()}${l.substring(1)}';
  }
}

class Name {
  final String firstname;
  final String lastname;

  const Name({required this.firstname, required this.lastname});

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        firstname: json['firstname'] as String,
        lastname: json['lastname'] as String,
      );
}

class Address {
  final String city;
  final String street;
  final int number;
  final String zipcode;

  const Address({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json['city'] as String,
        street: json['street'] as String,
        number: json['number'] as int,
        zipcode: json['zipcode'] as String,
      );

  String get full => '$number $street, $city $zipcode';
}
