import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/map_page_controller.dart';

import 'sub/create_meeting_sheet.dart';
import 'sub/meeting_icon_image.dart';
import 'sub/meeting_info_sheet.dart';

class MapPage extends StatefulWidget {
  final LatLng? currentLatLng;

  const MapPage({
    super.key,
    required this.currentLatLng,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapPageController controller = Get.put(MapPageController());

  @override
  void initState() {
    super.initState();
    controller.setCurrentLocation(widget.currentLatLng);
    controller.listenerForMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: GoogleMap(
          onMapCreated: controller.onMapCreated,
          initialCameraPosition: CameraPosition( // 초기 지도 위치
            target: controller.currentLocation,
            zoom: 15.0,
          ),
          compassEnabled: false,          // 나침판표시 비활성화
          myLocationEnabled: true,        // 내 위치 활성화
          myLocationButtonEnabled: false, // 내 위치 버튼 비활성화(따로 구현함)
          zoomControlsEnabled: false,     // 확대축소 버튼 비활성화
          markers: Set.of(controller.markers.values), // 지도 마커
          onCameraMove: controller.checkedCenter, // 지도 이동시 중심위치 저장
          
        ),
        floatingActionButton: Stack(
          children: [
            // 필터 버튼
            Align(
              alignment: Alignment(
                  Alignment.topLeft.x + 0.2, Alignment.topLeft.y + 0.1),
              child: SizedBox(
                width: 80,
                height: 50,
                child: FloatingActionButton(
                  heroTag: 'btnFilter',
                  elevation: 0, // 그림자 제거
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () async {},
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
              alignment:
                  Alignment(Alignment.topRight.x, Alignment.topRight.y + 0.1),
              child: SizedBox(
                width: !controller.isCreate.value ? 150 : 80,
                height: 50,
                child: FloatingActionButton(
                  heroTag: 'btnCreateMeeting',
                  elevation: 0, // 그림자 제거
                  backgroundColor:
                      !controller.isCreate.value ? Colors.blue : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: controller.clickedMeetingCreateButton,
                  child: Text(
                    !controller.isCreate.value ? '모임만들기' : '취소',
                    style: const TextStyle(
                      fontSize: 23,
                    ),
                  ),
                ),
              ),
            ),

            // 현재위치로 이동 버튼
            Align(
              alignment:
                  Alignment(Alignment.bottomRight.x, Alignment.bottomRight.y),
              child: FloatingActionButton(
                heroTag: 'btnCurrentLocation',
                elevation: 0, // 그림자 제거
                backgroundColor: Colors.blue,
                onPressed: controller.moveCurrentLatLng,
                child: const Icon(
                  Icons.navigation,
                  size: 40,
                ),
              ),
            ),

            if (controller.isCreate.value)

              // 모임 생성 버튼
              Align(
                alignment: Alignment(
                    Alignment.bottomCenter.x + 0.11, Alignment.bottomCenter.y),
                child: SizedBox(
                  width: 110,
                  height: 35,
                  child: FloatingActionButton(
                    heroTag: 'btnSeletedLocation',
                    elevation: 0, // 그림자 제거
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
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
                        backgroundColor: Colors.white,
                        isScrollControlled: true,
                        builder: (BuildContext context) => CreateMeetingSheet(
                          location: controller.center,
                        ),
                      );
                      controller.clickedMeetingCreateButton();
                    },
                    child: const Text(
                      '생성하기!',
                      style: TextStyle(
                        fontSize: 23,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
