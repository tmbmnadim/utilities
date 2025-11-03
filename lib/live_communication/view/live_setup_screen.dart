import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilities/live_communication/controllers/live_controller.dart';
import 'package:utilities/live_communication/models/live_meeting.dart';
import 'package:utilities/live_communication/models/live_user.dart';
import 'package:utilities/live_communication/view/live_screen.dart';
import 'package:utilities/utils/buttons.dart';

class LiveSetupScreen extends StatefulWidget {
  const LiveSetupScreen({super.key});

  @override
  State<LiveSetupScreen> createState() => _LiveSetupScreenState();
}

class _LiveSetupScreenState extends State<LiveSetupScreen> {
  final _usernameCtrl = TextEditingController();
  final _conferenceNameCtrl = TextEditingController();
  final liveCtrl = Get.find<LiveController>();

  @override
  void initState() {
    super.initState();
    _permissions();
    if (!liveCtrl.state.isConnectedToWS) {
      liveCtrl.connectWS(
        onSuccess: (msg) {
          EasyLoading.showInfo(msg);
        },
      );
    }
    if (liveCtrl.state.user != null && !liveCtrl.state.isUserOnline) {
      liveCtrl.registerUser();
    }
  }

  void _permissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GetBuilder<LiveController>(
          builder: (controller) {
            final state = controller.state;
            final user = state.user;

            // ================================================= CREATE A NEW USER
            if (user == null) {
              return Column(
                children: [
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      hint: Text("Name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  AppButtons.expandedButton(
                    text: "Create User",
                    isLoading: state.status == LiveSessionStatus.loading,
                    onPressed: () {
                      if (_usernameCtrl.text.trim().isNotEmpty) {
                        controller.createUser(
                          _usernameCtrl.text,
                          onSuccess: () {
                            EasyLoading.showSuccess(
                              "User created. ID: ${user?.id}",
                            );
                            controller.loadUsers();
                          },
                          onFailure: (e) {
                            EasyLoading.showError(e);
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else if (!state.isConnectedToWS || !state.isUserOnline) {
              return Column(
                children: [
                  AppButtons.expandedButton(
                    text: "Connect to server!",
                    onPressed: () {
                      if (!state.isConnectedToWS) {
                        controller.connectWS(
                          onSuccess: (msg) {
                            EasyLoading.showInfo(msg);
                          },
                        );
                      }
                      if (!state.isUserOnline) {
                        controller.registerUser();
                      }
                    },
                  ),
                ],
              );
            }

            // ========================== CALL, CONFERENCE AND STREAM SETUP
            return Column(
              children: [
                Text("THIS USER: ${state.user?.id}"),
                SizedBox(height: 8),
                // ================================================= P2P CALL
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    "Video Call",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.loadUsers();
                          },
                          label: Icon(Icons.refresh),
                        ),
                        Expanded(child: _availAbleUsersDropDown()),
                      ],
                    ),
                    SizedBox(height: 8),
                    AppButtons.expandedButton(
                      text: "Call",
                      onPressed: () async {
                        Get.to(LiveStreamScreen());
                      },
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                SizedBox(height: 8),

                // ================================================= LIVE CONFERENCE
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    "Conference",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.getMeetings();
                          },
                          label: Icon(Icons.refresh),
                        ),
                        Expanded(child: _availAbleMeetingsDropDown()),
                      ],
                    ),
                    SizedBox(height: 4),
                    AppButtons.expandedButton(
                      text: "Join",
                      onPressed: () {
                        controller.sendMeetingJoinRequest(
                          onSuccess: () {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => Get.to(LiveStreamScreen()),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _conferenceNameCtrl,
                      decoration: InputDecoration(
                        hint: Text("Meeting Name"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    AppButtons.expandedButton(
                      text: "Create",
                      isLoading: state.status == LiveSessionStatus.loading,
                      onPressed: () {
                        if (_conferenceNameCtrl.text.trim().isNotEmpty) {
                          controller.createMeeting(_conferenceNameCtrl.text);
                        }
                      },
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                SizedBox(height: 8),
                ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    "Video Stream",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hint: Text("Room ID"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    AppButtons.expandedButton(text: "Watch", onPressed: () {}),
                    AppButtons.expandedButton(text: "Start", onPressed: () {}),
                    SizedBox(height: 8),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _availAbleUsersDropDown() {
    final controller = Get.find<LiveController>();
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<LiveUser?>(
            isExpanded: true,
            value: controller.selectedUser,
            hint: Text('Select a user'),
            items: controller.state.availableUsers.map((user) {
              return DropdownMenuItem<LiveUser?>(
                value: user,
                child: Text(user.name),
              );
            }).toList(),
            onChanged: (LiveUser? newValue) {
              if (newValue != null) {
                controller.selectedUser = newValue;
              }
            },
          ),
        ),
      );
    });
  }

  Widget _availAbleMeetingsDropDown() {
    final controller = Get.find<LiveController>();
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<LiveMeeting?>(
            isExpanded: true,
            value: controller.selectedMeeting,
            hint: Text('Select a meeting'),
            items: controller.state.availableMeetings.map((meeting) {
              return DropdownMenuItem<LiveMeeting?>(
                value: meeting,
                child: Text(meeting.name),
              );
            }).toList(),
            onChanged: (LiveMeeting? newValue) {
              if (newValue != null) {
                controller.selectedMeeting = newValue;
              }
            },
          ),
        ),
      );
    });
  }
}
