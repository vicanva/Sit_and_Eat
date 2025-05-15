
import 'package:sit_and_eat/Model/company_model.dart';
import 'package:sit_and_eat/Services/company_service.dart';
import 'package:flutter/material.dart';

class CompanyInfoWidget extends StatelessWidget {
  final String compId;
  final CompanyService companyService;

  const CompanyInfoWidget({
    Key? key,
    required this.compId,
    required this.companyService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CompanyModel?>(
      future: companyService.getCompanyData(compId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Text('Error al cargar datos de la empresa');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Información de la empresa no disponible');
        } else {
          final company = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${company.nameRest}',
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
              ),
              Text('Dirección: ${company.address}'),
              Text('Ciudad: ${company.city}'),
            ],
          );
        }
      },
    );
  }
}