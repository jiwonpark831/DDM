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
  
  List<String> friends = [];

  final LatLng _center = const LatLng(36.103945, 129.387546);
  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getFriendMarker();
  }

  getFriendMarker() async {
    _markers.clear();
    DocumentSnapshot doc = await _firestore
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    // if (doc.data() != null && doc.get('friendsList') != null) {
    //   friends = List<String>.from(doc.get('friendsList'));
    // }
    var _request = await http.get(Uri.parse(doc['imageURL']));
    // var _bytes = _request.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(_request.bodyBytes, targetWidth: 100, targetHeight: 100);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();
    final double size = 100.0;
    
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


    final ui.Image circularImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    _markers[FirebaseAuth.instance.currentUser!.uid]=Marker(
      markerId:MarkerId(doc.get('uid')),
      position:LatLng(doc.get('location')['lat'],doc.get('location')['lng']),
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
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "상태 메세지를 입력해주세요",
                ),
              ),
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

    // _markers[FirebaseAuth.instance.currentUser!.uid]=Marker(
    //   markerId:MarkerId(doc.get('uid')),
    //   position:LatLng(doc.get('location')['lat'],doc.get('location')['lng']),
    //   icon: BitmapDescriptor.bytes(_bytes.buffer.asUint8List(),imagePixelRatio: 10),
    //   infoWindow: 
    //   // InfoWindow.noText,
    //   InfoWindow(
    //     title:doc.get('name'),
    //     onTap:((){
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
    // ),
      
    );
    debugPrint('${_markers[FirebaseAuth.instance.currentUser!.uid]}');

    setState((){});
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
