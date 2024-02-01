import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';


class MeetingWidget extends StatefulWidget {
  @override
  _MeetingWidgetState createState() => _MeetingWidgetState();
}

class _MeetingWidgetState extends State<MeetingWidget> {
  TextEditingController meetingIdController = TextEditingController();
  TextEditingController meetingPasswordController = TextEditingController();
  late Timer timer;

  @override
  Widget build(BuildContext context) {
    // new page needs scaffolding!
    return Scaffold(
      appBar: AppBar(
        title: Text('Join meeting'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: meetingIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Meeting ID',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: meetingPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    // The basic Material Design action button.
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () => {
                        _joinMeeting(context)
                      },
                      child: Text('Join'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    // The basic Material Design action button.
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () => {
                        _startMeeting(context)
                      },
                      child: const Text('Start Meeting'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _joinMeeting(BuildContext context) {
      bool _isMeetingEnded(String status) {
        var result = false;

        if (Platform.isAndroid)
          result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
        else
          result = status == "MEETING_STATUS_IDLE";

        return result;
      }
      if(meetingIdController.text.isNotEmpty && meetingPasswordController.text.isNotEmpty){
        ZoomOptions zoomOptions = ZoomOptions(
          domain: "zoom.us",
          appKey: "rK3U3UrmRAOg3xIehPmLmA", //API KEY FROM ZOOM - Sdk API Key
          appSecret: "eoc3EfqL4eXTdy4UHxjgv8W07EuknA5X", //API SECRET FROM ZOOM - Sdk API Secret
        );
        var meetingOptions = ZoomMeetingOptions(
            userId: 'username', //pass username for join meeting only --- Any name eg:- EVILRATT.
            meetingId: "7698470375", //pass meeting id for join meeting only
            meetingPassword: "Mk6dMFSbHWM0XZibd1auaJFjFMr2KN.1", //pass meeting password for join meeting only
            disableDialIn: "true",
            disableDrive: "true",
            disableInvite: "true",
            disableShare: "true",
            disableTitlebar: "false",
            viewOptions: "true",
            noAudio: "false",
            noDisconnectAudio: "false");

        var zoom = ZoomView();
        zoom.initZoom(zoomOptions).then((results) {
          if(results[0] == 0) {
            zoom.onMeetingStatus().listen((status) {
              print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
              if (_isMeetingEnded(status[0])) {
                print("[Meeting Status] :- Ended");
                timer.cancel();
              }
            });
            print("listen on event channel");
            zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
              timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                zoom.meetingStatus(meetingOptions.meetingId!)
                    .then((status) {
                  print("[Meeting Status Polling] : " + status[0] + " - " + status[1]);
                });
              });
            });
          }
        }).catchError((error) {
          print("[Error Generated] : " + error);
        });
      }else{
        if(meetingIdController.text.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Enter a valid meeting id to continue."),
          ));
        }
        else if(meetingPasswordController.text.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Enter a meeting password to start."),
          ));
        }
      }
    }

  _startMeeting(BuildContext context) {
    bool _isMeetingEnded(String status) {
      var result = false;

      if (Platform.isAndroid)
        result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
      else
        result = status == "MEETING_STATUS_IDLE";

      return result;
    }
    ZoomOptions zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "", //API KEY FROM ZOOM - Sdk API Key
      appSecret: "", //API SECRET FROM ZOOM - Sdk API Secret
    );
    var meetingOptions = new ZoomMeetingOptions(
        userId: '', //pass host email for zoom
        userPassword: '', //pass host password for zoom
        disableDialIn: "false",
        disableDrive: "false",
        disableInvite: "false",
        disableShare: "false",
        disableTitlebar: "false",
        viewOptions: "false",
        noAudio: "false",
        noDisconnectAudio: "false"
    );

    var zoom = ZoomView();
    zoom.initZoom(zoomOptions).then((results) {
      if(results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          if (_isMeetingEnded(status[0])) {
            print("[Meeting Status] :- Ended");
            timer.cancel();
          }
          if(status[0] == "MEETING_STATUS_INMEETING"){
            zoom.meetinDetails().then((meetingDetailsResult) {
              print("[MeetingDetailsResult] :- " + meetingDetailsResult.toString());
            });
          }
        });
        zoom.startMeeting(meetingOptions).then((loginResult) {
          print("[LoginResult] :- " + loginResult[0] + " - " + loginResult[1]);
          if(loginResult[0] == "SDK ERROR"){
            //SDK INIT FAILED
            print((loginResult[1]).toString());
          }else if(loginResult[0] == "LOGIN ERROR"){
            //LOGIN FAILED - WITH ERROR CODES
            if (loginResult[1] ==
                ZoomError.ZOOM_AUTH_ERROR_WRONG_ACCOUNTLOCKED) {
              print("Multiple Failed Login Attempts");
            }
            print((loginResult[1]).toString());
          }else{
            //LOGIN SUCCESS & MEETING STARTED - WITH SUCCESS CODE 200
            print((loginResult[0]).toString());
          }
        });
      }
    }).catchError((error) {
      print("[Error Generated] : " + error);
    });
  }
}
