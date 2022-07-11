import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:ruangkeluarga/parent/view/inbox/inbox_page_detail.dart';

const List<Tab> inboxTabs = <Tab>[
  Tab(text: 'SOS'),
  Tab(text: 'Notifikasi'),
];

class InboxPage extends StatelessWidget {
  String activePage = 'SOS';
  final controller = Get.find<ParentController>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: inboxTabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() async {
          if (!tabController.indexIsChanging) {
            activePage = inboxTabs[tabController.index].text!;
            print("rubah tab menjadi " + activePage);
            // await controller.inboxNotifFilter(activePage);
            // Your code goes here.
            // To get index of current tab use tabController.index
          };
        });
        return Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: inboxTabs,
            ),
            toolbarHeight: 6,
          ),
          body: TabBarView(
            children: inboxTabs.map((Tab tab) {
              String ss = 'sos';
              ss = tab.text!.toLowerCase();
              print('activePage = ' + activePage + ' <> ' + ss);
              return RefreshIndicator(
                onRefresh: () async => {
                  await controller.getInboxNotif()
                },
                child: ss == 'sos' ?
                    _SOSBody(context, controller)
                  : _NotificatinBody(context, controller),
              );

              // if (tab.text!.toLowerCase() == 'sos'){
              //   print('ini SOS tab');
              //   return _SOSBody(context, controller);
              // }
              // else {
              //   print('ini bukan SOS tab');
              //   return _NotificatinBody(context, controller);
              // }
              // // return _body(context, controller, activePage);
            }).toList(),
          ),
        );
      }),
    );
    // return SafeArea(
    //   appBar: AppBar(
    //     bottom: const TabBar(
    //       tabs: tabs,
    //     ),
    //     toolbarHeight: 6,
    //   ),
    //   child: Scaffold(
    //     // backgroundColor: cPrimaryBg,
    //     // appBar: AppBar(
    //     //   backgroundColor: cTopBg,
    //     //   title: Text('Inbox', style: TextStyle(color: cOrtuWhite)),
    //     //   elevation: 0,
    //     // ),
    //     body: GetBuilder<ParentController>(
    //       builder: (controller) => RefreshIndicator(
    //         onRefresh: () => controller.getInboxNotif(),
    //         child: controller.inboxData.length > 0
    //             ? _body(context, controller)
    //             : CustomScrollView(
    //                 physics: AlwaysScrollableScrollPhysics(),
    //                 slivers: [
    //                     SliverFillRemaining(
    //                       child: Center(
    //                           child: Text('Inbox Kosong',
    //                               style: TextStyle(color: cOrtuText))),
    //                     )
    //                   ]),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _body(BuildContext context, ParentController controller, String InboxType) {
    var inbox = controller.inboxData;
    if (InboxType.toLowerCase() == 'sos') {
      inbox = controller.inboxDataSOS;
      print("load SOS");
    } else {
      inbox = controller.inboxDataNotification;
      print("load Notif");
    }
    print(inbox);
    // final inboxByType = inbox.where((d) => d.type.toEnumString() ==
    //     InboxType.toLowerCase()).toList();
    // List inboxByType = inbox;
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: inbox.length,
        itemBuilder: (ctx, idx) {
          final notifData = inbox[idx];
          return Dismissible(
            key: Key(notifData.id),
            // direction: if == '' ? DismissDirection.horizontal : DismissDirection.none,
            confirmDismiss: (_) async {
              return await controller.deleteNotif(notifData.id);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: cOrtuGrey,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(top: 5, bottom: 2),
              child: ListTile(
                onTap: () async {
                  showLoadingOverlay();
                  await controller.readNotifByID(notifData.id, idx);
                  closeOverlay();
                  // final String videoUrl = notifData.message.videoUrl != null ? notifData.message.videoUrl.toString() : "";
                  // if (videoUrl != '') {
                  //   showUrl(videoUrl, "Panic Video");
                  // }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          InboxDetail(inboxNotif: notifData)));
                },
                title: Text(
                  notifData.message.message,
                  style: TextStyle(
                      fontWeight: notifData.readStatus
                          ? FontWeight.normal
                          : FontWeight.bold),
                ),
                subtitle: Text('\n${dateFormat_EDMYHM(notifData.createAt)}'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _SOSBody(BuildContext context, ParentController controller) {
    var inbox = controller.inboxDataSOS;
    print("load SOS");
    print(inbox);
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: inbox.length,
        itemBuilder: (ctx, idx) {
          final notifData = inbox[idx];
          return Dismissible(
            key: Key(notifData.id),
            // direction: if == '' ? DismissDirection.horizontal : DismissDirection.none,
            confirmDismiss: (_) async {
              return await controller.deleteNotif(notifData.id);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: cOrtuGrey,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(top: 5, bottom: 2),
              child: ListTile(
                onTap: () async {
                  showLoadingOverlay();
                  await controller.readNotifByID(notifData.id, idx);
                  closeOverlay();
                  // final String videoUrl = notifData.message.videoUrl != null ? notifData.message.videoUrl.toString() : "";
                  // if (videoUrl != '') {
                  //   showUrl(videoUrl, "Panic Video");
                  // }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          InboxDetail(inboxNotif: notifData)));
                },
                title: Text(
                  notifData.message.message,
                  style: TextStyle(
                      fontWeight: notifData.readStatus
                          ? FontWeight.normal
                          : FontWeight.bold),
                ),
                subtitle: Text('\n${dateFormat_EDMYHM(notifData.createAt)}'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _NotificatinBody(BuildContext context, ParentController controller) {
    var inbox = controller.inboxDataNotification;
    print("load Notif");
    print(inbox);
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: inbox.length,
        itemBuilder: (ctx, idx) {
          final notifData = inbox[idx];
          return Dismissible(
            key: Key(notifData.id),
            // direction: if == '' ? DismissDirection.horizontal : DismissDirection.none,
            confirmDismiss: (_) async {
              return await controller.deleteNotif(notifData.id);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: cOrtuGrey,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(top: 5, bottom: 2),
              child: ListTile(
                onTap: () async {
                  showLoadingOverlay();
                  await controller.readNotifByID(notifData.id, idx);
                  closeOverlay();
                  // final String videoUrl = notifData.message.videoUrl != null ? notifData.message.videoUrl.toString() : "";
                  // if (videoUrl != '') {
                  //   showUrl(videoUrl, "Panic Video");
                  // }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          InboxDetail(inboxNotif: notifData)));
                },
                title: Text(
                  notifData.message.subject,
                  style: TextStyle(
                      fontWeight: notifData.readStatus
                          ? FontWeight.normal
                          : FontWeight.bold),
                ),
                subtitle: Text('\n${dateFormat_EDMYHM(notifData.createAt)}'),
              ),
            ),
          );
        },
      ),
    );
    // return Column(
    //   children: [
    //     ListView.builder(
    //       physics: AlwaysScrollableScrollPhysics(),
    //       itemCount: inbox.length,
    //       itemBuilder: (ctx, idx) {
    //         final notifData = inbox[idx];
    //         return Dismissible(
    //           key: Key(notifData.id),
    //           // direction: if == '' ? DismissDirection.horizontal : DismissDirection.none,
    //           confirmDismiss: (_) async {
    //             return await controller.deleteNotif(notifData.id);
    //           },
    //           child: Container(
    //             decoration: BoxDecoration(
    //                 color: cOrtuGrey,
    //                 borderRadius: BorderRadius.all(Radius.circular(15))),
    //             margin: EdgeInsets.all(5),
    //             padding: EdgeInsets.only(top: 5, bottom: 2),
    //             child: ListTile(
    //               onTap: () async {
    //                 showLoadingOverlay();
    //                 await controller.readNotifByID(notifData.id, idx);
    //                 closeOverlay();
    //                 // final String videoUrl = notifData.message.videoUrl != null ? notifData.message.videoUrl.toString() : "";
    //                 // if (videoUrl != '') {
    //                 //   showUrl(videoUrl, "Panic Video");
    //                 // }
    //                 Navigator.of(context).push(MaterialPageRoute(
    //                     builder: (context) =>
    //                         InboxDetail(inboxNotif: notifData)));
    //               },
    //               title: Text(
    //                 notifData.message.message,
    //                 style: TextStyle(
    //                     fontWeight: notifData.readStatus
    //                         ? FontWeight.normal
    //                         : FontWeight.bold),
    //               ),
    //               subtitle: Text('\n${dateFormat_EDMYHM(notifData.createAt)}'),
    //             ),
    //           ),
    //         );
    //       },
    //     ),
    //     ElevatedButton(
    //       onPressed: () {
    //       },
    //       child: const Text('Reload'),
    //     ),
    //   ],
    // );
  }
}
