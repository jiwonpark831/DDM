import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;


class mapPage extends StatefulWidget {
  const mapPage({super.key});

  @override
  State<mapPage> createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  late GoogleMapController mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, bool> friends = {};
  List<Map<String, String>> friendsForMarker= [];

  Timer? timer;

  

  LatLng _center = const LatLng(36.103945, 129.387546);
  Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getFriendMarker();
  }

  getFriendMarker() async {
    DocumentSnapshot doc = await _firestore
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    _center= LatLng(doc.get('location')['lat'],doc.get('location')['lng']);

    var _request = await http.get(Uri.parse(doc['imageURL']));

    ui.Codec codec = await ui.instantiateImageCodec(_request.bodyBytes, targetWidth: 100, targetHeight: 100);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image image = frameInfo.image;
    
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    Paint paint = Paint();
    double size = 100.0;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint..shader = ui.ImageShader(image, ui.TileMode.clamp, ui.TileMode.clamp, Float64List.fromList([
      size / 100, 0, 0, 0,
      0, size / 100, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1])),
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: ' ${doc['name']} ',
      style: TextStyle(fontSize: 20, backgroundColor: Colors.greenAccent, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(size / 2 - textPainter.width / 2, size / 2 + textPainter.height));


    ui.Image circularImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    ByteData? byteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List imageData = byteData!.buffer.asUint8List();

    _markers[FirebaseAuth.instance.currentUser!.uid]=Marker(
      markerId:MarkerId(doc.get('uid')),
      position:LatLng(doc.get('location')['lat'],doc.get('location')['lng']),
      icon: BitmapDescriptor.bytes(imageData),
      infoWindow: InfoWindow.noText,
    );

    friends = {};
    
    if (doc.data() != null && doc.get('friendList') != null) {
      friends = Map<String, bool>.from(doc.get('friendList'));
    }

    for (var entry in friends.entries) {
      String key = entry.key;
      bool value = entry.value;
      if (value) {
        var friend =
            await FirebaseFirestore.instance.collection('user').doc(key).get();
        if (friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]) {
          var _request = await http.get(Uri.parse(friend['imageURL']));

          ui.Codec codec = await ui.instantiateImageCodec(_request.bodyBytes, targetWidth: 100, targetHeight: 100);
          ui.FrameInfo frameInfo = await codec.getNextFrame();
          ui.Image image = frameInfo.image;
          
          ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
          Canvas canvas = Canvas(pictureRecorder);
          Paint paint = Paint();
          double size = 100.0;
          
          canvas.drawCircle(
            Offset(size / 2, size / 2),
            size / 2,
            paint..shader = ui.ImageShader(image, ui.TileMode.clamp, ui.TileMode.clamp, Float64List.fromList([
            size / 100, 0, 0, 0,
            0, size / 100, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1])),
          );

          final textPainter = TextPainter(
            textDirection: TextDirection.ltr,
          );
          textPainter.text = TextSpan(
            text: ' ${friend['name']} ',
            style: TextStyle(fontSize: 20, backgroundColor: Colors.greenAccent, color: Colors.white),
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(size / 2 - textPainter.width / 2, size / 2 + textPainter.height));


          ui.Image circularImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
          ByteData? byteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);
          Uint8List imageData = byteData!.buffer.asUint8List();

          _markers[friend.get('uid')]=Marker(
            markerId:MarkerId(friend.get('uid')),
            position:LatLng(friend.get('location')['lat'],friend.get('location')['lng']),
            icon: BitmapDescriptor.bytes(imageData),
            infoWindow: InfoWindow.noText,
            onTap:((){
              debugPrint('click');
              TextEditingController _controller =
                  TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text("상태 메세지 수정"),
                    content: Text("dsa"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "닫기",
                          style: TextStyle(
                              color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "저장",
                          style: TextStyle(
                              color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );
            })
          );
        }
      }
    }



      // _markers[FirebaseAuth.instance.currentUser!.uid]=Marker(
      //   markerId:MarkerId(doc.get('uid')),
      //   position:LatLng(doc.get('location')['lat'],doc.get('location')['lng']),
      //   icon: BitmapDescriptor.bytes(imageData),
      //   infoWindow: InfoWindow.noText,
      //   onTap:((){
      //     debugPrint('click');
      //     TextEditingController _controller =
      //         TextEditingController();
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           backgroundColor: Colors.white,
      //           title: Text("상태 메세지 수정"),
      //           content: TextField(
      //             controller: _controller,
      //             decoration: InputDecoration(
      //               hintText: "상태 메세지를 입력해주세요",
      //             ),
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //               child: Text(
      //                 "닫기",
      //                 style: TextStyle(
      //                     color: Colors.black),
      //               ),
      //             ),
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //               child: Text(
      //                 "저장",
      //                 style: TextStyle(
      //                     color: Colors.black),
      //               ),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   })
      // );

      setState((){});

      // Timer.periodic(Duration(seconds:10),(timer) async {
      //   doc = await _firestore
      //     .collection('user')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .get();
      //   Marker tmp_marker = _markers[doc.get('uid')]!.copyWith(positionParam: LatLng(doc.get('location')['lat'],doc.get('location')['lng']));
      //   setState((){
      //     _markers[doc.get('uid')] = tmp_marker;
      //   });


      //   for (var entry in friends.entries) {
      //     String key = entry.key;
      //     bool value = entry.value;
      //     if (value) {
      //       var friend =
      //           await FirebaseFirestore.instance.collection('user').doc(key).get();
      //       if (friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]) {

      //         Marker tmp_marker = _markers[friend.get('uid')]!.copyWith(positionParam: LatLng(friend.get('location')['lat'],friend.get('location')['lng']));
      //         setState((){
      //           _markers[friend.get('uid')] = tmp_marker;
      //         });

      //       }
      //     }
      //   }
      // });
    
  }
  

  //   List<Future<void>> friendFetchFutures = friends.map((element) async {
  //     var _friend = await _firestore.collection('user').doc(element).get();

  //     var lat=_friend['location'][0];
  //     var lng=_friend['location'][1];
  //     var name = _friend['name'];

  //     var request = await http.get(Uri.parse(_friend['imageURL']));
  //     var bytes = request.bodyBytes;

  //     var marker = Marker(
  //       markerId: MarkerId(element),
  //       position: LatLng(lat, lng),
  //       icon: BitmapDescriptor.bytes(bytes.buffer.asUint8List(),imagePixelRatio: 10),
  //       infoWindow: InfoWindow(title:name)
  //     );
  //     _markers[element] = marker;
  //   }).toList();

  //   await Future.wait(friendFetchFutures);

  //   setState(() {});

  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 18.0,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}
