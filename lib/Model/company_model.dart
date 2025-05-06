
class CompanyModel{
  final String nameRest;
  final String province;
  final String city;
  final String address;
  final String zipcode;

  CompanyModel({
    required this.nameRest,
    required this.province,
    required this.city,
    required this.address,
    required this.zipcode,
  });

  factory CompanyModel.fromFirestore(Map<String,dynamic> data, String uid){
    return CompanyModel(
      nameRest: data['name_rest'] as String? ?? '',
      province: data['province'] as String? ?? '',
      city: data['city'] as String? ?? '',
      address: data['address'] as String? ?? '',
      zipcode: data['zipcode'] as String? ?? '',
    );
  }

  Map<String,dynamic> toMap(){
    return{
      'name_rest': nameRest.trim(),
      'province': province.trim(),
      'city': city.trim(),
      'address': address.trim(),
      'zipcode': zipcode.trim(),
    };
  }

  CompanyModel copyWith({
    String? nameRest,
    String? province,
    String? city,
    String? address,
    String? zipcode,
}){
    return CompanyModel(
      nameRest: nameRest ?? this.nameRest,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address ?? this.address,
      zipcode: zipcode ?? this.zipcode,
    );
  }

  @override
  String toString(){
    return 'CompanyModel(nameRest: $nameRest,'
        'province: $province, city: $city, address: $address, zipcode: $zipcode)';
  }

}

