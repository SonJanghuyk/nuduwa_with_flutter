// import 'package:flutter/material.dart';
// import 'package:nuduwa_with_flutter/utils/responsive.dart';

// class ResponsivePage extends StatelessWidget {
//   ResponsivePage({
//     super.key,
//     required this.firstPage,
//     required this.endPage,
//     required this.tag,
//   });

//   Widget firstPage;
//   Widget endPage;
//   String tag;

//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Responsive.layout(
//       portrait: portrait,
//       landscape: landscape,
//     );
//   }

//   Navigator meetingNavigator(void Function(String) onTapCard,  void Function(BuildContext) onClose) {
//     return Navigator(
//       key: Get.nestedKey(MeetingRoutePages.key),
//       initialRoute: '/',
//       onGenerateRoute: (settings) {
//         if (settings.name == MeetingRoutePages.meetingDetail) {
//           final meetingId = settings.arguments as String;
//           return MeetingRoutePages.detailPage(meetingId, onClose);
//         } else {
//           return GetPageRoute(
//             page: () => MeetingResponsivePage(onTapCardPortrait: onTapCard),
//           );
//         }
//       },
//     );
//   }
// }
