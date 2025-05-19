
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class messagesWidget extends StatefulWidget{
  final String reservationId;
  final Future<void> Function(String reservationId,Map<String,dynamic> message) addMessage;
  final String sender;

  const messagesWidget({
    super.key,
    required this.reservationId,
    required this.addMessage,
    required this.sender,
});

  static void showTheDialog(BuildContext context, {
    required String reservationId,
    required Future<void> Function(String reservationId,Map<String,dynamic> message) addMessage,
    required String sender,
  }) {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(18),
        child: SizedBox(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.6,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: messagesWidget(
              key: ValueKey(reservationId),
              reservationId: reservationId,
              addMessage: addMessage,
              sender: sender,
            ),
          ),
        ),
      ),
    );
  }

  @override
  messagesWidgetState createState() => messagesWidgetState();
}

class messagesWidgetState extends State<messagesWidget>{
  final TextEditingController _messageController = TextEditingController();
  String? _senderName = '';

  Stream<List<Map<String,dynamic>>> _messageStream(){
    return FirebaseFirestore.instance
        .collection('Reservas')
        .doc(widget.reservationId)
        .snapshots()
        .map((doc){
      final data = doc.data();
      final messages = (data?['messages'] as List<dynamic>? ?? []);
      return messages
          .map((msg) => Map<String,dynamic>.from(msg))
          .toList()
          ..sort((a,b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
    });
  }

  void _loadSenderName() async{
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid == null) return;

    final service = FirestoreService.instance;
    final name = await service.getSenderName(uid, widget.sender);
    
    setState(() {
      _senderName = name;
    });
  }


  void _sendMessage() async{
    if(_messageController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El mensaje no puede estar vacio'))
      );
      return;
    }

    if(_senderName == null || _senderName!.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el nombre')),
      );
      return;
    }

    if(_messageController.text.isNotEmpty){
      final newMessage = {
        'content': _messageController.text,
        'sender': '${widget.sender}: $_senderName',
        'timestamp': Timestamp.now(),
        'idM': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await widget.addMessage(widget.reservationId,newMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje Enviado'))
      );
      _messageController.clear();
    }

  }


  @override
  void initState(){
    super.initState();
    _markAsRead();
    _loadSenderName();
  }

  @override
  void dispose(){
    _messageController.dispose();
    super.dispose();
  }

  void _markAsRead(){
    final field = widget.sender == 'Cliente'
        ? 'hasNewMessageForCliente' : 'hasNewMessageForEmpresa';

    FirebaseFirestore.instance
    .collection('Reservas')
    .doc(widget.reservationId)
    .update({field: false});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: _messageStream(),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasError) {
          return Text('Error al cargar mensajes');
        }
        final messages = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(messages.isEmpty)
              Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
              child: Text('No hay mensajes'),
              ),
            if(messages.isNotEmpty)
              Expanded(child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return ListTile(
                    title: Align(
                      alignment: msg['sender'].toString().startsWith('Empresa')
                      ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      msg['content'] ?? 'Mensaje vacio',
                      style: TextStyle(fontSize: 16),
                      textAlign: msg['sender'].toString().startsWith('Empresa')
                      ? TextAlign.right : TextAlign.left,
                    ),
                    ),
                    subtitle: Align(
                      alignment: msg['sender'].toString().startsWith('Empresa')
                      ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text('${msg['sender']}',
                      style: TextStyle(fontSize: 10,fontStyle: FontStyle.italic),
                    ),
                    ),
                  );
                },
              ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.03),
                child: TextField(
                    controller: _messageController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: 'Escribe tu mensaje (max. 40 carac)',
                      border: OutlineInputBorder(),
                    ),
                  ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('Enviar Mensaje'),
              ),
            ],
          );
      },
    );
  }

}
