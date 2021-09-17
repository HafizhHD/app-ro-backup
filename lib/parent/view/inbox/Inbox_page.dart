import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';

class InboxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          backgroundColor: cPrimaryBg,
          title: Text('Inbox'),
          elevation: 0,
        ),
        body: GetBuilder<ParentController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: () => controller.getInboxNotif(),
            child: controller.inboxData.length > 0
                ? _body(controller)
                : Center(
                    child: Text('Inbox Kosong', style: TextStyle(color: cOrtuWhite)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _body(ParentController controller) {
    final inbox = controller.inboxData;
    return Container(
      child: ListView.builder(
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
              decoration: BoxDecoration(color: cOrtuGrey, borderRadius: BorderRadius.all(Radius.circular(15))),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(top: 5, bottom: 2),
              child: ListTile(
                onTap: () async {
                  showLoadingOverlay();
                  await controller.readNotifByID(notifData.id, idx);
                  closeOverlay();
                },
                title: Text(
                  notifData.message.split('pada')[0],
                  style: TextStyle(fontWeight: notifData.readStatus ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Text('\n${dateFormat_EDMYHM(notifData.createAt)}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
