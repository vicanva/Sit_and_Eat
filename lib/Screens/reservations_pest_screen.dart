
import 'package:sit_and_eat/Screens/local_reservations_screen.dart';
import 'package:sit_and_eat/Screens/reserved_screens.dart';
import 'package:flutter/material.dart';

class ReservationsPestScreen extends StatelessWidget{
  final bool isCompany;
  
  const ReservationsPestScreen({super.key, required this.isCompany});
  
  @override
  Widget build(BuildContext context){
    final screenHeight = MediaQuery.of(context).size.height;
    
    // aqui se controla la vista, si el usuario es empresa o no.
    final List<Tab> tabs = isCompany
    ? [Tab(text: 'Mis Reservas'),
      Tab(text: 'Reserv Local'),
      ]
    : [Tab(text: 'Mis Reservas')];
    
    // aqui se define que se muestra
    final List<Widget> tabViews = isCompany
    ? [
      ReservedScreens(),
      LocalReservationsScreen(),
    ]
    : [ReservedScreens()];
    
    
    return DefaultTabController(
        length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(screenHeight * 0.04),
            child: TabBar(tabs: tabs)
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
