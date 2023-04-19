import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:flutter/services.dart';
import 'package:bssidtest3333/main.dart';

class Notificationselect extends StatefulWidget{
  final String name;
  final String bssid;
  final String line;
  const Notificationselect({Key? key, required this.name, required this.bssid, required this.line}) : super(key: key);


  @override
  State<Notificationselect> createState() => Notification();
}

class Notification extends State<Notificationselect> {

  @override

  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();


  Future<void> huntWiFis() async {
      try {
        wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
      } on PlatformException catch (exception) {
        print(exception.toString());
      }

      if (!mounted) return;
  }

  bool stoploop = true;

  Future<void> comparing()async {
    List<dynamic> wifiresult = [];
    while (stoploop == true) {
      huntWiFis();

      for (int i = 0; i < wiFiHunterResult.results.length; i++) {
        wifiresult.add(wiFiHunterResult.results[i].BSSID);
      }

      if (wifiresult.contains(widget.bssid)) {
        print('success');
        MyHomePageState().notificationplz();
        wifiresult.clear();
        break;
      }
      else {
        print('fail');
        wifiresult.clear();
      }
      print(wifiresult);
      await Future.delayed(Duration(milliseconds: 500));
      print('0.5초');
    }
  }

  var iconcolor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)
                    )
                ),

                height: 450,
                child: Center(
                  child: Column(
                      children: [
                        SizedBox(height: 150,),
                        Container(
                          child: Text(widget.line,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                            textAlign: TextAlign.center,),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.all(
                                Radius.circular(20)
                            ),

                          ),
                          child: Text(widget.name,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50),
                            textAlign: TextAlign.center,),
                        ),
                        SizedBox(height: 20,),
                        Icon(Icons.circle_notifications_outlined, color: iconcolor,size: 100,)
                      ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          boxShadow:[
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 5,
                              blurRadius: 7,
                            )
                          ]
                      ),
                      width: 160,
                      height: 200,
                      child: Icon(Icons.notifications_on_outlined, color: Colors.blueGrey, size: 80,),
                    ),
                    onTap: () {
                      FlutterBackgroundService().invoke("setAsForeground");
                      setState(() {
                        iconcolor = Colors.yellow;
                      });
                      comparing();
                    },
                  ),
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          boxShadow:[
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 5,
                              blurRadius: 7,
                            )
                          ]
                      ),
                      width: 160,
                      height: 200,
                      child: Icon(Icons.notifications_off_outlined, color: Colors.blueGrey, size: 80,),
                    ),
                    onTap: (){
                      Navigator.pop(context);
                      FlutterBackgroundService().invoke("setAsBackground");
                      setState(() {
                        iconcolor = Colors.grey;
                        stoploop = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

