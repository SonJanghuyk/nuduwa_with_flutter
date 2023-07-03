import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_set_sheet.dart';

import 'sub/meeting_icon.dart';
import 'sub/meeting_info_sheet.dart';

class MapScreen extends StatefulWidget {
  final LatLng currentLatLng;

  MapScreen({
    super.key,
    required this.currentLatLng,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _currentLatLng;
  late String _mapStyle;

  Future<LatLng> updateCurrentLatLng() async {
    final currentPosition = await Geolocator.getCurrentPosition();

    return LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _markers = [];

  loadMarkers() async {
    _markers.add(Marker(
      markerId: MarkerId('대림대'),
      position: LatLng(37.4036, 126.9304),
      icon: await meetingIcon(),
      infoWindow: InfoWindow(title: '대림대학교'),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.0),
            ),
          ),
          barrierColor: Colors.white.withOpacity(0),
          isScrollControlled: true,
          builder: (BuildContext context) => const MeetingInfoSheet(),
        );
      }
    ));
    _markers.add(
      Marker(
        markerId: MarkerId('안양대'),
        position: LatLng(37.3919, 126.9199),
        icon: await meetingIcon(),
        infoWindow: InfoWindow(title: '안양대학교'),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('안양종합운동장'),
        position: LatLng(37.4053, 126.9464),
        infoWindow: InfoWindow(title: '안양종합운동장'),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    // 구글 지도에서 POI아이콘 삭제
    rootBundle.loadString('assets/map_style.txt').then((value) {
      _mapStyle = value;
    });

    _currentLatLng = widget.currentLatLng;
    loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller.complete(controller);
            controller.setMapStyle(_mapStyle);
          });
        },
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 15.0,
        ),
        compassEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        
        zoomControlsEnabled: false,
        markers: Set.of(_markers),
      ),
      
      floatingActionButton: Stack(
        children: [
          // 필터 버튼
          Align(
            alignment: Alignment(Alignment.topLeft.x + 0.2, Alignment.topLeft.y + 0.1),
            child: SizedBox(
              width: 80,
              height: 50,
              child: FloatingActionButton(    
                backgroundColor: Colors.amberAccent,            
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed: () async {
                  
                },                
                child: const Text(
                  '필터',
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
            ),
          ),

          // 모임만들기 버튼
          Align(
            alignment: Alignment(Alignment.topRight.x, Alignment.topRight.y + 0.1),
            child: SizedBox(
              width: 150,
              height: 50,
              child: FloatingActionButton(                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15.0),
                      ),
                    ),
                    barrierColor: Colors.white.withOpacity(0),
                    isScrollControlled: true,
                    builder: (BuildContext context) => const MeetingSetSheet(),
                  );
                },                
                child: const Text(
                  '모임만들기',
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
            ),
          ),

          // 현재위치로 이동 버튼
          Align(
            alignment: Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y),
            child: FloatingActionButton(
              child: const Icon(
                Icons.navigation,
                size: 40,
              ),
              onPressed: () async {
                GoogleMapController controller = await _controller.future;
                _currentLatLng = await updateCurrentLatLng();
                controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _currentLatLng,
                    zoom: 15.0,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
