import 'package:sit_and_eat/Model/company_model.dart';
import 'package:sit_and_eat/Services/company_service.dart';
import 'package:sit_and_eat/Model/user_model.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:flutter/material.dart';


class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final String userId;
  final CompanyModel? comp;

  const EditProfileScreen({super.key, required this.user, required this.userId, this.comp});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameUsuController;
  late TextEditingController _phoneController;
  TextEditingController? _nameRestController;
  TextEditingController? _provinceController;
  TextEditingController? _addressController;
  TextEditingController? _cityController;
  TextEditingController? _zipCodeController;
  bool _registerCompany = false;


  @override
  void initState() {
    super.initState();
    _nameUsuController = TextEditingController(text: widget.user.nameUser);
    _phoneController = TextEditingController(text: widget.user.phone);

    if(widget.user.isCompany) {
      _nameRestController =
          TextEditingController(text: widget.comp?.nameRest ?? '');
      _provinceController =
          TextEditingController(text: widget.comp?.province ?? '');
      _addressController =
          TextEditingController(text: widget.comp?.address ?? '');
      _cityController = TextEditingController(text: widget.comp?.city ?? '');
      _zipCodeController =
          TextEditingController(text: widget.comp?.zipcode ?? '');
    }
  }

  @override
  void dispose() {
    _nameUsuController.dispose();
    _phoneController.dispose();
      _nameRestController?.dispose();
      _provinceController?.dispose();
      _addressController?.dispose();
      _cityController?.dispose();
      _zipCodeController?.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try{
        bool isCompany = widget.user.isCompany || _registerCompany;

      UserModel updatedUser = widget.user.copyWith(
        nameUser: _nameUsuController.text.trim(),
        phone: _phoneController.text.trim(),
        isCompany: isCompany,
      );
        await UserService.saveUserData(widget.userId, updatedUser);


      if (isCompany) {
        CompanyModel company = CompanyModel(
          nameRest: _nameRestController!.text.trim(),
          address: _addressController!.text.trim(),
          city: _cityController!.text.trim(),
          zipcode: _zipCodeController!.text.trim(),
          province: _provinceController!.text.trim(),
        );
        await CompanyService().updateCompany(widget.userId, company);
      }
      // Volver al perfil después de guardar
      Navigator.of(context).pop( {
        'updatedUser': updatedUser,
        'updatedCompany': isCompany ?
            CompanyModel(
              nameRest: _nameRestController!.text.trim(),
              province: _provinceController!.text.trim(),
              city: _cityController!.text.trim(),
              address: _addressController!.text.trim(),
              zipcode: _zipCodeController!.text.trim())
              : null,
      });
      }catch(e){
        print('Error cambios user: $e');
      }
    }
  }

  Future<void> _deleteCompany() async{
    try{
      await CompanyService().deleteCompany(widget.userId);
      UserModel updateUser = widget.user.copyWith(isCompany: false);
      await UserService.saveUserData(widget.userId, updateUser);

      Navigator.of(context).pop({
        'updatedUser': updateUser,
        'updatedCompany': null,
      });

    }catch (e){
      print('Error al eliminar la empresa: $e');
    }
  }

  Future<void>_alertDeleteConfirm() async{
    bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Confirmar Eliminación'),
            content: Text('¿Estás seguro de eliminar el negoció?\n'
                ' Esto eliminará toda información de la empresa'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
              ),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Eliminar'),
              ),
            ],
          );
        },
    );
    if(confirm == true){
      _deleteCompany();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool showCompanySection = widget.user.isCompany || _registerCompany;

    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')
      ),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
          padding: EdgeInsets.all(screenWidth *0.04),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('No se puede modificar el email'),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameUsuController,
                  decoration: InputDecoration(labelText: 'Nombre y Apellidos'),
                  validator: (value) => value!.isEmpty ? 'Ingrese su nombre completo' : null,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => value!.isEmpty ? 'Ingrese su num. de teléfono' : null,
                ),
                if(widget.user.isCompany) ...[
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _nameRestController,
                    decoration: InputDecoration(labelText: 'Nombre del restaurante'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _provinceController,
                    decoration: InputDecoration(labelText: 'Provincia del restaurante'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: 'Ciudad'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Dirección'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _zipCodeController,
                    decoration: InputDecoration(labelText: 'Cod. Post.'),
                  ),
                ],

                SizedBox(height: 12),
                if(!widget.user.isCompany) ...[
                  CheckboxListTile(
                    title: Text('¿Deseas registrar tu negocio?'),
                    value: _registerCompany,
                    onChanged: (bool? value){
                      setState(() {
                      _registerCompany = value ?? false;

                      if(_registerCompany){
                      _nameRestController ??= TextEditingController();
                      _provinceController ??= TextEditingController();
                      _addressController ??= TextEditingController();
                      _cityController ??= TextEditingController();
                      _zipCodeController ??= TextEditingController();
                      }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
                    if(showCompanySection) ...[
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameRestController,
                      decoration: InputDecoration(labelText: 'Nombre del restaurante'),
                      validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese nombre restaurante' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _provinceController,
                      decoration: InputDecoration(labelText: 'Provincia'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese la provincia' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(labelText: 'Ciudad'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese la ciudad' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Dirección'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese la direccion' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: InputDecoration(labelText: 'Código Postal'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese el Codigo Postal' : null,
                    ),
                ],
                SizedBox(height: 14),
                if(widget.user.isCompany)...[
                  ElevatedButton(
                      onPressed: _alertDeleteConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: Text('Cerrar mi Negocio'),
                  ),
                ],

                // guardar
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent
                  ),
                  child: Text('Guardar Cambios'),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}
