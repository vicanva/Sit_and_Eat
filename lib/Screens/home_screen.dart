import 'package:sit_and_eat/Screens/make_reserve.dart';
import 'package:sit_and_eat/Screens/profile_screen.dart';
import 'package:sit_and_eat/Screens/reservations_pest_screen.dart';
import 'package:sit_and_eat/Screens/reserved_screens.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>{
   int _selectedIndex = 0;
   bool? isCompany;



   @override
  void initState(){
     super.initState();
     _checkUserType();
   }


  Future<void> _checkUserType() async{
       String userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
       if(userUid.isNotEmpty) {
         bool business = await UserService().isUserCompany(userUid);
         setState(() {
           isCompany = business;
         });
        // _initializeScreens();
       }else{
         setState(() {
           isCompany = false;
         });
         //_initializeScreens();
       }
  }

  void _onItemTapped(int index){
       setState(() {
         _selectedIndex = index;
       });
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return MakeReserve(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',);

      case 1:
        return isCompany! ?
        ReservationsPestScreen(isCompany: true) : ReservedScreens()
        ;

      case 2:
        return ProfileScreen();

      default:
        return MakeReserve(
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

     if(isCompany == null){
       return Scaffold(
         body: Center(
           child: CircularProgressIndicator(),
         ),
       );
     }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png',
            height: screenWidth * 0.08
            ),
          ],
        ),
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade700,
        iconSize: screenWidth * 0.07,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_bar),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}