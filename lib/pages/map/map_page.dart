import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';

import 'sub/create_meeting_sheet.dart';

class MapPage extends GetView<MapPageController> {
  const MapPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.currentLatLng.value == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: controller.onMapCreated,
              initialCameraPosition: CameraPosition(
                // 초기 지도 위치
                target: controller.currentLatLng.value!,
                zoom: 15.0,
              ),
              compassEnabled: false, // 나침판표시 비활성화
              mapToolbarEnabled: false, // 클릭시 경로버튼 비활성화
              myLocationEnabled: true, // 내 위치 활성화
              myLocationButtonEnabled: false, // 내 위치 버튼 비활성화(따로 구현함)
              zoomControlsEnabled: false, // 확대축소 버튼 비활성화
              markers: controller.meetingsAndMarkers.values
                  .map((tuple) => tuple.marker)
                  .toSet(), // 지도 마커
              onCameraMove: controller.checkedCenter, // 지도 이동시 중심위치 저장
            )),
      floatingActionButton: Stack(
        children: [
          // 필터 버튼
          Align(
            alignment:
                Alignment(Alignment.topLeft.x, Alignment.topLeft.y + 0.1),
            child: Obx(
              () => IntrinsicWidth(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 30),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    color: Colors.amberAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    itemBuilder: (BuildContext context) => [
                      filterMenuItem(context, null),
                      for (final category in MeetingCategory.values)
                        filterMenuItem(context, category),
                    ],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          controller.category.value,
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 모임만들기 버튼
          Align(
            alignment:
                Alignment(Alignment.topRight.x, Alignment.topRight.y + 0.1),
            child: Obx(
              () => SizedBox(
                width: !controller.isCreate.value ? 150 : 80,
                height: 50,
                child: FloatingActionButton(
                  heroTag: 'btnCreateMeeting',
                  backgroundColor:
                      !controller.isCreate.value ? Colors.blue : Colors.red,
                  onPressed: controller.clickedMeetingCreateButton,
                  child: Text(
                    !controller.isCreate.value ? '모임만들기' : '취소',
                    style: buttonTextStyle,
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
              backgroundColor: Colors.blue,
              onPressed: controller.moveCurrentLatLng,
              child: const Icon(
                Icons.navigation,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          // 모임 생성 버튼
          Obx(() => controller.isCreate.value
              ? Align(
                  alignment: Alignment(Alignment.bottomCenter.x + 0.11,
                      Alignment.bottomCenter.y),
                  child: SizedBox(
                    width: 150,
                    height: 40,
                    child: FloatingActionButton(
                      heroTag: 'btnSeletedLocation',
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      onPressed: () {
                        createMeetingSheet(context, controller.center);
                        controller.clickedMeetingCreateButton();
                      },
                      child: Text(
                        '생성하기!',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink())
        ],
      ),
    );
  }

  PopupMenuItem<String> filterMenuItem(
      BuildContext context, MeetingCategory? category) {
    return PopupMenuItem<String>(
      onTap: () => controller.clickedFilter(category),
      child: Center(
        child: Text(
          category?.displayName ?? '전체',
          style: buttonTextStyle,
        ),
      ),
    );
  }

  TextStyle get buttonTextStyle => const TextStyle(
        fontSize: 30,
        color: Colors.white,
      );
}
