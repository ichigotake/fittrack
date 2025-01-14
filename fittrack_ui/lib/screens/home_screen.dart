import 'package:fittrack_ui/screens/data_screen.dart';
import 'package:fittrack_ui/style.dart';
import 'package:fittrack_ui/widgets/moods.dart';
import 'package:flutter/material.dart';
import 'package:fittrack_ui/utisl.dart';
import 'dart:async';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:fit_kit/fit_kit.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _selectedIndex = 0;
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  final Map<String, List> biometricdata = {};
  bool permissions;

  List<DateTime> _dates = [];
  RangeValues _dateRange = RangeValues(1, 8);
  double _limitRange = 0;

  DateTime get _dateFrom => _dates[_dateRange.start.round()];
  DateTime get _dateTo => _dates[_dateRange.end.round()];
  int get _limit => _limitRange == 0.0 ? null : _limitRange.round();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates.add(null);
    for (int i = 7; i >= 0; i--) {
      _dates.add(DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i)));
    }
    _dates.add(null);
    hasPermissions();
    read();
  }

  Future<void> read() async {
    results.clear();
    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      if (!permissions) {
        result = 'requestPermissions: failed';
      } else {
        for (DataType type in DataType.values) {
          try {
            results[type] = await FitKit.read(
              type,
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              limit: _limit,
            );
          } on UnsupportedException catch (e) {
            results[e.dataType] = [];
          }
        }
        result = 'readAll: success';
        results.forEach((key, value) {
          if (key is DataType) {
            biometricdata['$key'] = value;
          }
        });
      }
    } catch (e) {
      result = 'readAll: $e';
    }
  }

  Future<void> revokePermissions() async {
    results.clear();
    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(DataType.values);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      result = 'hasPermissions: $e';
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildTopStack(),
                SizedBox(
                  height: 60.0,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // _buildNotificationCard(),
                      _buildNextAppointmentTitle(),
                      _buildNextAppointmentInfo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   showSelectedLabels: false,
        //   showUnselectedLabels: false,
        //   currentIndex: _selectedIndex,
        //   items: [
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           LineAwesomeIcons.home,
        //           size: 30.0,
        //         ),
        //         title: Text('1')),
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           LineAwesomeIcons.search,
        //           size: 30.0,
        //         ),
        //         title: Text('1')),
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           LineAwesomeIcons.gratipay,
        //           size: 30.0,
        //         ),
        //         title: Text('1')),
        //   ],
        //   onTap: onTapped,
        // ),
        floatingActionButton: Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              child: Icon(
                Icons.update_sharp,
                size: 32,
              ),
              onPressed: () => read(),
              backgroundColor: lightColor,
            )));
  }

  Stack _buildTopStack() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        _buildBackgroundCover(),
        _buildGreetings(),
        _buildMoodsHolder(),
      ],
    );
  }

  _buildBackgroundCover() {
    return Container(
      height: 260.0,
      decoration: BoxDecoration(
          gradient: purpleGradient,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40))),
    );
  }

  _buildGreetings() {
    return Positioned(
      left: 20.0,
      bottom: 90.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi!',
            style: greetingTitleStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'How are you feeling today?',
            style: greetingSubtitleStyle,
          ),
        ],
      ),
    );
  }

  _buildMoodsHolder() {
    return Positioned(
      bottom: -45,
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width - 40,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 5.5,
                blurRadius: 5.5,
              )
            ]),
        child: MyMoods(),
      ),
    );
  }

  // _buildNotificationCard() {
  //   return Container(
  //     padding: EdgeInsets.all(12.0),
  //     decoration: BoxDecoration(
  //       color: lightColor,
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: ListTile(
  //       leading: Icon(
  //         LineAwesomeIcons.heart,
  //         color: Colors.white,
  //         size: 32,
  //       ),
  //       title: Text(
  //         'Result',
  //         style: notificationTitleStyle,
  //       ),
  //       trailing: Text(
  //         'Detail',
  //         style: notificationButtonStyle,
  //       ),
  //     ),
  //   );
  // }

  _buildNextAppointmentTitle() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Latest data', style: nextAppointmentTitleStyle),
          InkWell(
              child: Text(
                'See All',
                style: nextAppointmentSubTitleStyle,
              ),
              onTap: () {
                // Navigator.pushReplacementNamed(context, '/data');
                // results.forEach((key, value) {
                //   print('Key:$key, Value:$value');
                // });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DataPage(biometricdata: biometricdata)));
              }),
        ],
      ),
    );
  }

  _buildNextAppointmentInfo() {
    final heartrate = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.HEART_RATE'].last.value.round();
    final heartratetime = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.HEART_RATE'].last.dateTo;
    final steps = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.STEP_COUNT'].last.value.round();
    final stepstime = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.STEP_COUNT'].last.dateTo;
    final energy = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.ENERGY'].last.value.round();
    final energytime = biometricdata.isEmpty
        ? 0
        : biometricdata['DataType.ENERGY'].last.dateTo;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      // decoration: BoxDecoration(
      //     color: Colors.white, borderRadius: BorderRadius.circular(18)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 5.5,
              blurRadius: 5.5,
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CircleAvatar(
              //   backgroundColor: Colors.grey,
              //   backgroundImage: NetworkImage(USER_IMAGE),
              //   radius: 36,
              // ),
              Icon(
                LineAwesomeIcons.heart,
                size: 40,
                color: Colors.redAccent,
              ),
              SizedBox(
                width: 12,
              ),
              RichText(
                  text: TextSpan(
                      text: '心拍数 $heartrate BPM',
                      style: appointmentMainStyle,
                      children: [
                    TextSpan(
                      text: '\n $heartratetime',
                      style: appointmentDatastyle,
                    ),
                  ]))
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LineAwesomeIcons.map_marker,
                size: 40,
                color: Colors.blueGrey,
              ),
              SizedBox(
                width: 12,
              ),
              RichText(
                  text: TextSpan(
                      text: '歩数：$steps 歩',
                      style: appointmentMainStyle,
                      children: [
                    TextSpan(
                      text: '\n $stepstime',
                      style: appointmentDatastyle,
                    ),
                  ]))
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LineAwesomeIcons.fire,
                size: 40,
                color: Colors.green,
              ),
              SizedBox(
                width: 12,
              ),
              RichText(
                  text: TextSpan(
                      text: '$energy kCal',
                      style: appointmentMainStyle,
                      children: [
                    TextSpan(
                      text: '\n $energytime',
                      style: appointmentDatastyle,
                    ),
                  ]))
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  // void onTapped(int value) {
  //   setState(() {
  //     _selectedIndex = value;
  //     print(results);
  //   });
  // }
}
