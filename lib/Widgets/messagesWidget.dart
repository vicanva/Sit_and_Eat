
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagesWidget extends StatefulWidget{
  final String reservationId;
  final Future<void> Function(String reservationId,Map<String,dynamic> message) addMessage;
  final String sender;

  const MessagesWidget({
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
            child: MessagesWidget(
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
  MessagesWidgetState createState() => MessagesWidgetState();
}

class MessagesWidgetState extends State<MessagesWidget>{
  final TextEditingController _messageController = TextEditingController();

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

  void _sendMessage() async{
    if(_messageController.text.isNotEmpty){
      final newMessage = {
        'content': _messageController.text,
        'sender': widget.sender,
        'timestamp': Timestamp.now(),
        'idM': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await widget.addMessage(widget.reservationId,newMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje Enviado'))
      );
      _messageController.clear();

    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El mensaje no puede estar vacio'))
      );
    }
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
                    title: Text(msg['content'] ?? 'Mensaje vacio',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text('Enviado por: ${msg['sender']}'),
                  );
                },
              ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.03),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Escribe tu mensaje (max 40 caracteres)',
                    border: OutlineInputBorder(),
                    counterText: '${_messageController.text.length}/40',
                  ),
                  maxLength: 40,
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
