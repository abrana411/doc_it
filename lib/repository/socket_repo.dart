import 'package:doc_it/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepo {
  final _socketClient = SocketClient.instance.socket!;
  //Above the SocketClient.instance is a getter which gives us an instance which is nothing but SocketClient._inetrnal() , which connect the socket if its null and if not then will return the instnace of the socketClient as it is , and since we get the instance now it has the datamember socjet in it (which is conneted now)

  //Getter to get the socketClient (which is actually the io.Socket)
  Socket get socketClient => _socketClient;

  //Making a client join a room for current document
  //What it means to joina room is , the clients which are a part of a room only will communicate with the server in which the ocket connection is being established , so we will make a socketClient join a room with a document id
  void joinRoom(String docId) {
    // print("Attempting to join room with docId: $docId");
    _socketClient.emit('join',
        docId); //Like this simply making a socketClient (which is socket we get from the insatnce of socketClient class after connection is established ie socket.connect ke baad)

    //Name of the room se say 'join' which we gave above , it is needed for the server side socket to connect to this room only and establish a connection with the clients residing in this 'join' room , it is aname can be anything
  }

  //function which runs as the user types (changes the content) so that the changes are broadcasted to other clients
  void typing(Map<String, dynamic> data) {
    _socketClient.emit("typing", data); //emitting typing event from here say
  }

  //Listening to the changes (which are broadcasted by the server)
  void changeListener(Function(Map<String, dynamic>) dochange) {
    //so we will listen to the "changes" event as we fired this only from the server side socket (when broadcasting) and then we will simply send the data to the UI
    //calling this. so that that screen can use this new data to show it (basically here it will be th quill , as we will change the content shown on the text editor), so passing this to a function and that function will be called in the part where this listenchanges is called (as this function will be passed as a parameter)
    _socketClient.on("changes", (data) => dochange(data));
  }

  //For the autosave feature (we could have used the normal API call to save the data) but using the socket for this because
  //If we want to show that the data is saved last at this time in the bottom screen then we can do that using the io.to() , socket.to() in the server side
  void saveDoc(Map<String, dynamic> data) {
    //firing the save event (will listen to it in the backend now (since fired from frontend))
    _socketClient.emit("save", data);
  }
}
