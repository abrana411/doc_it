import 'package:doc_it/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
//Making socket client connection: using this (ie getting instance after making connection)

//This is how we can get an instance of socket client ie we have created a class and inside which we have created an internal cinstructor and that constructor can be caled only thourgh this class only
class SocketClient {
  //this is having two data members one is socket (which will have the connection url and some other important fields as shown below)
  io.Socket? socket;
  static SocketClient?
      _instance; //insatnce if this class only (we will need it) and to get it we will run the insatnce getter below

  SocketClient._internal() {
    socket = io.io(initialUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect':
          false, //we never want the socket to form connection automatically rather we want it to get connected whenever we demand it
    });
    socket!.connect();
  }

  //Now in order to get an instance of this socket client , we have to check if the instance is null only then we will connect the socket using the internal consturtor and if it is not null then we will simply pass the instance which we have
  //This is all in the documentation!!
  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
