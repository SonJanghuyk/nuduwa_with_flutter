import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/models/meeting.dart';
import 'package:nuduwa_with_flutter/models/member.dart';
import 'package:nuduwa_with_flutter/models/user_meeting.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/meeting_info_sheet.dart';
import 'package:nuduwa_with_flutter/constants/assets.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/service/permission_service.dart';

class MapPageController extends GetxController {
  // static MapPageController get instance => Get.find();

  // Helper
  final _utils = MapPageControllerUtils(
    drawIconOfMeeting: DrawIconOfMeeting(
      imageSize: !kIsWeb ? 80.0 : 26.666,
      borderWidth: !kIsWeb ? 10.0 : 3.333,
      triangleSize: !kIsWeb ? 30.0 : 10.0,
    ),
  );

  // GoogleMap
  final _mapController = Completer<GoogleMapController>();
  final meetingsAndMarkers =
      RxMap<String, ({Meeting meeting, Marker marker})>();
  var _checkUserMeetings = <UserMeeting>[];

  // 구글 지도에서 POI아이콘 삭제
  late final String _mapStyle;

  // Location
  final currentLatLng = Rx<LatLng?>(null);
  var center = const LatLng(0, 0);

  // Firestore Listener
  final _snapshotMeetingsAndMarkers =
      <String, ({Meeting meeting, Marker marker})>{};
  final _snapshotMeetings = RxList<Meeting>();

  // CreateMeeting
  final isCreate = RxBool(false);
  Marker? newMarker;
  final _newMarkerId = 'newMeeting';

  // JoinMeeting
  final isLoading = RxBool(false);

  // Members
  final members = RxList<Member>();

  // Category Filter
  final category = RxString('필터');

  @override
  void onInit() async {
    super.onInit();

    await _initializeVariables();

    ever(MainPageController.instance.userMeetings, _updateMeetingIcon);
    once(PermissionService.instance.currentLatLng, fetchCurrentLocation);

    _snapshotMeetings.bindStream(_streamMeetings());
    debugPrint('000');
    ever(_snapshotMeetings, _createMarkers);
  }

  Future<void> _initializeVariables() async {
    // GoogleMap Style - Remove POI Icons
    _mapStyle = await rootBundle.loadString('assets/map_style.txt');
    await _utils.initializeVariables();

    currentLatLng.value = PermissionService.instance.currentLatLng.value;
  }

  void fetchCurrentLocation(LatLng? currentLatLng) {
    debugPrint('위치 권한');
    this.currentLatLng.value = currentLatLng;
    center = currentLatLng!;
  }

  /// 모임 참여하거나 나가면 아이콘 색 바꾸기
  Future<void> _updateMeetingIcon(List<UserMeeting> userMeetings) async {
    debugPrint('updateMeetingIcon');
    final leavedMeetings =
        _checkUserMeetings.toSet().difference(userMeetings.toSet());
    final joinMeetings =
        userMeetings.toSet().difference(_checkUserMeetings.toSet());
    final symmetricDifferenceMeetings = leavedMeetings.union(joinMeetings);

    _checkUserMeetings = userMeetings;

    for (final userMeeting in symmetricDifferenceMeetings) {
      if (_snapshotMeetingsAndMarkers.keys.contains(userMeeting.meetingId)) {
        final meeting =
            _snapshotMeetingsAndMarkers[userMeeting.meetingId]!.meeting;
        final marker = await _utils.fetchMeetingMarker(meeting);
        _snapshotMeetingsAndMarkers[userMeeting.meetingId] =
            (meeting: meeting, marker: marker);
      }
    }
    _convertMeetings();
  }

  /// 서버에서 가져오는 모임 데이터와 모임 만들기 때 생성되는 마커 합치기
  void _convertMeetings() {
    meetingsAndMarkers.value = Map.from(_snapshotMeetingsAndMarkers);
    if (newMarker != null) {
      final tempMeeting = MeetingRepository.tempMeetingData();
      meetingsAndMarkers[_newMarkerId] =
          (meeting: tempMeeting, marker: newMarker!);
    }
  }

  void clusteringMarkers() {}

  Stream<List<Meeting>> _streamMeetings() {
    return MeetingRepository.streamAllDocuments();
  }

  void _createMarkers(List<Meeting> meetings) {
    _snapshotMeetingsAndMarkers.clear();
    for (final meeting in meetings) {
      final markerForLoading = _utils.creatLoadingMeetingMarker(meeting);

      // 우선 로딩아이콘으로 마커표시
      _snapshotMeetingsAndMarkers[meeting.id!] =
          (meeting: meeting, marker: markerForLoading);

      // Marker 이미지를 HostImage로 교체
      _utils.fetchMeetingMarker(meeting).then((marker) {
        _snapshotMeetingsAndMarkers[meeting.id!] =
            (meeting: meeting, marker: marker);
        _convertMeetings();
      });
    }
    _convertMeetings();
  }

  // 현재 위치로 지도 이동
  Future<void> moveCurrentLatLng() async {
    try {
      GoogleMapController controller = await _mapController.future;

      final currentPosition = await Geolocator.getCurrentPosition();

      currentLatLng.value =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng.value!,
          zoom: 15.0,
        ),
      ));
    } on PermissionDeniedException {
      final check = await PermissionService.instance.checkLocationPermission();
      if (check != null) moveCurrentLatLng();
    } catch (e) {
      debugPrint('오류! moveCurrentLatLng: ${e.toString()}');
    }
  }

  // 구글지도 초기화
  void onMapCreated(GoogleMapController controller) async {
    try {
      // _mapController = Completer<GoogleMapController>();
      _mapController.complete(controller);

      controller.setMapStyle(_mapStyle);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 지도 이동시 수행
  void checkedCenter(CameraPosition position) {
    center = position.target;

    if (newMarker == null) return;

    Marker updatedMarker = newMarker!.copyWith(
      positionParam: position.target,
    );
    newMarker = updatedMarker;
    _convertMeetings();
  }

  // 모임 만들기 클릭시 지도 중앙에 마커 생성
  void clickedMeetingCreateButton() {
    if (!isCreate.value) {
      isCreate.value = true;
      Marker marker = Marker(
        markerId: MarkerId(_newMarkerId),
        position: center,
        draggable: false,
      );
      newMarker = marker;
    } else {
      isCreate.value = false;
      newMarker = null;
    }
    _convertMeetings();
  }

  // 카테고리 필터
  void clickedFilter(MeetingCategory? category) {
    this.category.value = category?.displayName ?? '필터';
    for (var meeting in _snapshotMeetingsAndMarkers.values) {
      final visible = (category == null)
          ? true
          : meeting.meeting.category == category.displayName;
      Marker updatedMarker = meeting.marker.copyWith(visibleParam: visible);
      _snapshotMeetingsAndMarkers[meeting.meeting.id!] =
          (meeting: meeting.meeting, marker: updatedMarker);
    }
    _convertMeetings();
  }
}

enum IconColors {
  host(Colors.red),
  join(Colors.green),
  defalt(Colors.blue);

  final Color color;
  const IconColors(this.color);
}

class MapPageControllerUtils {
  DrawIconOfMeeting drawIconOfMeeting;
  late final Map<String, ui.Image> iconFrames;
  late final Map<String, BitmapDescriptor> loadingIcons;

  MapPageControllerUtils({required this.drawIconOfMeeting});

  Future<void> initializeVariables() async {
    // 지도에서 쓸 아이콘 생성
    final (iconFrames, loadingIcons) = await drawIconImages();
    this.iconFrames = iconFrames;
    this.loadingIcons = loadingIcons;
  }

  /// 지도에 보여줄 아이콘 이미지 미리 만들어놓기
  Future<(Map<String, ui.Image>, Map<String, BitmapDescriptor>)>
      drawIconImages() async {
    final futureIconFrames = {
      for (final color in IconColors.values)
        color.name: drawIconOfMeeting.drawIconFrame(color.color)
    };
    final iconFrames = Map.fromIterables(
        futureIconFrames.keys, await Future.wait(futureIconFrames.values));

    // 웹 이미지 가져오는동안 보여줄 아이콘
    final loadingIcons = await drawIconOfMeeting.drawLoadingIcons(iconFrames);

    return (iconFrames, loadingIcons);
  }

  Marker creatLoadingMeetingMarker(Meeting meeting) {
    // Host 여부, 참여 여부에 따라 다른색 아이콘
    final String iconColor;
    if (meeting.hostUid == FirebaseReference.currentUid) {
      // host일때
      iconColor = IconColors.host.name;
    } else if (MainPageController.instance.userMeetings
        .any((userMeeting) => userMeeting.meetingId == meeting.id)) {
      // 참여중인 모임일때
      iconColor = IconColors.join.name;
    } else {
      // 둘다 아닐때
      iconColor = IconColors.defalt.name;
    }

    final loadingIcon = loadingIcons[iconColor];

    // 우선 로딩아이콘으로 마커표시
    final markerForLoading = Marker(
      markerId: MarkerId(meeting.id!),
      position: meeting.location,
      icon: loadingIcon!,
      onTap: () => meetingInfoSheet(meeting),
    );

    return markerForLoading;
  }

  Future<Marker> fetchMeetingMarker(Meeting meeting) async {
    try {
      // Host 정보 가져오기
      if (meeting.hostName == null) {
        meeting = await MeetingRepository.fetchHostNameAndImage(meeting);
      }

      // Host 여부, 참여 여부에 따라 다른색 아이콘
      final String iconColor;
      if (meeting.hostUid == FirebaseReference.currentUid) {
        // host일때
        iconColor = IconColors.host.name;
      } else if (MainPageController.instance.userMeetings
          .any((userMeeting) => userMeeting.meetingId == meeting.id)) {
        // 참여중인 모임일때
        iconColor = IconColors.join.name;
      } else {
        // 둘다 아닐때
        iconColor = IconColors.defalt.name;
      }

      // Marker 이미지를 가져온 HostImage로 교체
      final icon = await drawIconOfMeeting.drawMeetingIcon(
          meeting.hostImageUrl!, iconFrames[iconColor]!);

      // Web이미지로 마커 새로 그리기
      final marker = Marker(
        markerId: MarkerId(meeting.id!),
        position: meeting.location,
        icon: icon,
        onTap: () => meetingInfoSheet(meeting),
      );
      return marker;
    } catch (e) {
      debugPrint('에러!fetchHostData: ${e.toString()}');
      rethrow;
    }
  }
}

class DrawIconOfMeeting {
  double imageSize; // 이미지 크기
  double borderWidth; // 테두리 두께
  double triangleSize; // 하단 꼭지점 크기

  DrawIconOfMeeting({
    required this.imageSize,
    required this.borderWidth,
    required this.triangleSize,
  });

  /// 로딩중 지도에 표시할 아이콘 만들기
  Future<Map<String, BitmapDescriptor>> drawLoadingIcons(
      Map<String, ui.Image> iconImages) async {
    // 웹 이미지 가져오는동안 보여줄 이미지
    final image = await _loadingImage();

    // image와 iconImages를 합쳐서 Marker 아이콘 만들기
    final loadingIconImages = await Future.wait([
      for (var iconImage in iconImages.values) _drawIcon(image, iconImage),
    ]);

    // loadingIconImages로 만들걸 쓰기 쉽게 Map으로 변환
    final loadingIcons = {
      for (var index = 0; index < loadingIconImages.length; index++)
        iconImages.keys.toList()[index]: loadingIconImages[index],
    };

    return loadingIcons;
  }

  /// 지도에 표시할 아이콘 만들기
  Future<BitmapDescriptor> drawMeetingIcon(
      String? imageUrl, ui.Image iconImage) async {
    final imageData = await downloadImage(imageUrl);
    return await _drawIcon(imageData, iconImage);
  }

  /// 웹에서 이미지 다운로드 없으면 NoImage 이미지 넣기
  static Future<Uint8List> downloadImage(String? imageUrl) async {
    if (imageUrl == null) {
      final ByteData assetData = await rootBundle.load(Assets.imageNoImage);
      return assetData.buffer.asUint8List();
    } else {
      final imageData = await http.get(Uri.parse(imageUrl));
      return imageData.bodyBytes;
    }
  }

  /// imageData와 iconImages를 합쳐서 Marker 아이콘 만들기
  Future<BitmapDescriptor> _drawIcon(
      Uint8List imageData, ui.Image iconImage) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frameInfo = await codec.getNextFrame();
    // imageData 원모양으로 그리기
    final meetingImage = await _drawCircleImage(frameInfo, imageSize);
    final ui.Image markerImage = await _overlayImages(meetingImage, iconImage);

    // BitmapDescriptor 생성
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedImageData = byteData!.buffer.asUint8List();
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(resizedImageData);
    return bitmapDescriptor;
  }

  /// 웹이미지 가져오는 동안 표시될 이미지
  Future<Uint8List> _loadingImage() async {
    final ByteData assetData = await rootBundle.load(Assets.imageLoading);
    return assetData.buffer.asUint8List();
  }

  /// 이미지 원 모양으로 만들기
  Future<ui.Image> _drawCircleImage(
      ui.FrameInfo frameInfo, double imageSize) async {
    final ui.Image image = frameInfo.image;
    final int imageLength = image.width > image.height
        ? image.height
        : image.width; // 이미지 가로세로 중 짧은 길이

    final double scale = imageSize / imageLength;

    // 이미지 중심좌표
    final ui.Rect srcRect = ui.Rect.fromLTRB(
        (image.width.toDouble() - imageLength) / 2,
        (image.height.toDouble() - imageLength) / 2,
        imageLength.toDouble(),
        imageLength.toDouble());
    // 이미지 크기
    final ui.Rect destRect =
        ui.Rect.fromLTWH(0.0, 0.0, imageLength * scale, imageLength * scale);
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvasImage = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double center = imageSize / 2;

    // 원그리기
    canvasImage.drawCircle(Offset(center, center), center, paint);
    // 이미지 그리기
    paint.blendMode = BlendMode.srcIn;
    canvasImage.drawImageRect(image, srcRect, destRect, paint);

    final ui.Image webImage = await pictureRecorder
        .endRecording()
        .toImage(imageSize.toInt(), imageSize.toInt());

    return webImage;
  }

  /// 이미지 2개 겹치는 함수
  Future<ui.Image> _overlayImages(
      ui.Image foreground, ui.Image background) async {
    final double backgroundWidth = background.width.toDouble();
    final double backgroundHeight = background.height.toDouble();
    final double foregroundWidth = foreground.width.toDouble();
    final double foregroundHeight = foreground.height.toDouble();

    final double backgroundSize =
        backgroundWidth > backgroundHeight ? backgroundHeight : backgroundWidth;

    final double offsetX = (backgroundSize - foregroundWidth) / 2;
    final double offsetY = (backgroundSize - foregroundHeight) / 2;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 큰 이미지 그리기
    canvas.drawImage(background, Offset.zero, Paint());

    // 작은 이미지 그리기
    canvas.drawImage(foreground, Offset(offsetX, offsetY), Paint());

    final ui.Picture picture = pictureRecorder.endRecording();

    final ui.Image overlayedImage = await picture.toImage(
        backgroundWidth.toInt(), backgroundHeight.toInt());

    return overlayedImage;
  }

  /// 아이콘이미지 만드는 함수
  Future<ui.Image> drawIconFrame(Color color) async {
    final double iconSize = imageSize + (borderWidth * 2); // 아이콘 크기

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvasIcon = Canvas(pictureRecorder);
    final Paint redCirclePaint = Paint()..color = color;

    final double iconCenter = imageSize / 2 + borderWidth;
    // 세모 그리기
    final ui.Path trianglePath = ui.Path()
      ..moveTo(iconCenter, iconCenter * 2 + triangleSize) // 세모의 하단 꼭지점 시작점
      ..lineTo(iconCenter / 2, iconCenter + iconCenter * 2 / 3) // 좌측 꼭지점
      ..lineTo(iconCenter + iconCenter / 2,
          iconCenter + iconCenter * 2 / 3) // 우측 꼭지점
      ..close(); // 세모 완성

    canvasIcon.drawCircle(
        Offset(iconCenter, iconCenter), iconCenter, redCirclePaint);
    canvasIcon.drawPath(trianglePath, redCirclePaint);

    final ui.Image iconImage = await pictureRecorder
        .endRecording()
        .toImage(iconSize.toInt(), iconSize.toInt() + triangleSize.toInt());

    return iconImage;
  }
}
