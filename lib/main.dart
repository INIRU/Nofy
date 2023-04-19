import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'animatedSearchBar.dart';
import 'subway.dart';

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bssidtest3333/notificationselect.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel', /* same name */
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: false,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );




  service.startService();
  FlutterBackgroundService().invoke("setAsBackground");
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {

  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually


  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }



  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "알림을 실행중입니다.",
      content: "알림을 취소하려면 클릭하세요",
    );
  }

  // test using external plugin
  final deviceInfo = DeviceInfoPlugin();
  String? device;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    device = androidInfo.model;
  }

  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    device = iosInfo.model;
  }

  service.invoke(
    'update',
    {
      "current_date": DateTime.now().toIso8601String(),
      "device": device,
    },
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  late FixedExtentScrollController pickerController;
  ScrollController controller = ScrollController();
  List<Widget> ItemsData = [];
  bool closeTopContainer = false;
  double topContainer = 0;

  int line = 0;
  final List subway_line = SUBWAY_DATA.keys.toList();
  String searchbartext = AnimatedSearchBarState.filter.text;


  Future<void> ItemListBuilder() async {
    Map<String, List> responseList = SUBWAY_DATA;
    List<Widget> listItems = [];

    responseList[subway_line[line]]?.forEach((element) {
      print(searchbartext);
      if (element['name'].contains(searchbartext)) {
        listItems.add(Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 27),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]
          ),
          child: InkWell(
            onTap: () async {
              final isYes = await showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text(
                      "도착역 지정",
                      style: TextStyle(fontSize: 20),
                    ),
                    content: Text(
                      "${element["name"]}역을 도착역으로 지정하시겠습니까?",
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('예'),
                        onPressed: () async {
                          Navigator.pop(context);
                          final station_name = element['name'];
                          final station_line = subway_line[line];
                          final station_bssid = element['bssid'];
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> Notificationselect(name: station_name, bssid: station_bssid, line: station_line,)));
                          }
                      ),
                      CupertinoDialogAction(
                        child: Text('아니요', style: TextStyle(color: Colors.red)),
                        onPressed: () => Navigator.pop(context, false),
                      )
                    ],
                  )
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        element["name"],
                        style: const TextStyle(fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subway_line[line],
                        style: const TextStyle(fontSize: 17,
                            color: Colors.grey),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
      }
    });

    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      ItemsData = listItems;
      searchbartext = AnimatedSearchBarState.filter.text;
    });
  }




    Widget PickerBuilder() => SizedBox(
    height: 300,
    child: CupertinoPicker(
      scrollController: pickerController,
      looping: false,
      itemExtent: 64,
      onSelectedItemChanged: (i) {
        setState(() {
          line = i;
        });
      },
      children: [
        ...subway_line.map((e) =>
            Center(
              child: Text(
                e,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        )
      ],
    ),
  );

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if(!isAllowed){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Allow Notifications'),
            content: Text("Our app would like to send you notifications"),
            actions: [
              TextButton(
                  onPressed:(){Navigator.pop(context);},
                  child: Text('dont allow', style: TextStyle(color: Colors.grey, fontSize: 18),
                  )
              ),
              TextButton(
                onPressed: (){AwesomeNotifications().requestPermissionToSendNotifications().then((_) => Navigator.pop(context));}
                ,child: Text('Allow',
                style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18, fontWeight:
                FontWeight.bold),
              ),
              )
            ],
          ),
        );
      }
    });

    pickerController = FixedExtentScrollController(initialItem: 0);
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    ItemListBuilder();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Text(
            "${line+1}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          onPressed: () {
            pickerController.dispose();
            pickerController = FixedExtentScrollController(initialItem: line);

            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                actions: [PickerBuilder()],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.blueAccent,
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
          ),
        ),
        body: Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              AnimatedSearchBar(),
              Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: ItemsData.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (topContainer > 0.5) {
                        scale = index + 0.5 - topContainer;
                        if (scale < 0) {
                          scale = 0;
                        } else if (scale > 1) {
                          scale = 1;
                        }
                      }
                      return Opacity(
                        opacity: scale,
                        child: Transform(
                          transform:  Matrix4.identity()..scale(scale,scale),
                          alignment: Alignment.bottomCenter,
                          child: Align(
                              heightFactor: 0.7,
                              alignment: Alignment.topCenter,
                              child: ItemsData[index]),
                        ),
                      );
                    },
                  )
              )
            ],
          ),
        ),
      ),
    );
  }



  Future<void> notificationplz() async{
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: createUniqueId(),
          channelKey: 'basic_channel',
          title: '도착 알림!',
          body: '곧 역에 도착합니다.',
        ),
      );
  }

  int createUniqueId(){
    return DateTime.now().millisecondsSinceEpoch.remainder(100);
  }

}

