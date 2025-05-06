
class UserModel {
  final String nameUser;
  final String email;
  final String phone;
  final bool isCompany;


  UserModel({
    required this.nameUser,
    required this.email,
    required this.phone,
    required this.isCompany,
  }) {
    if(!email.contains('@')){
      throw ArgumentError('El email "$email" no es válido');
    }
    if(phone.isNotEmpty && phone.length < 9){
      throw ArgumentError('El número de telefono debe tener 9 dígitos');
    }
  }

  // convertir mapa a Objeto User
  factory UserModel.fromFirestore(Map<String,dynamic> data){
    try {
      return UserModel(
        nameUser: data ['name_user'] as String? ?? '',
        email: data ['email'] as String? ?? '',
        phone: data ['phone'] as String? ?? '',
        isCompany: (data ['is_company'] ?? false) as bool,
      );
    }catch (e){
      throw ArgumentError('Error al convertir UserModel: $e');
    }
  }

  // convertir objecto User a mapa
  Map<String, dynamic> toMap(){
    return{
      'name_user': nameUser.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.replaceAll(RegExp(r'\D'), ''),
      'is_company': isCompany,
    };
  }

  UserModel copyWith({
    String? nameUser,
    String? email,
    String? phone,
    bool? isCompany,
}){
    return UserModel(
        nameUser: nameUser ?? this.nameUser,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        isCompany: isCompany ?? this.isCompany
    );
  }

  @override
  String  toString(){
    return 'UserModel(nameUser: $nameUser, email: $email,'
    'phone:$phone, isCompany: $isCompany)';
  }

}
