import 'package:cellcounter/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var count = 0;

  @override
  void initState() {
    super.initState();

    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());

    return Scaffold(
      drawer: Drawer(
         child: ListView(
           // Important: Remove any padding from the ListView.
           padding: EdgeInsets.zero,
           children: <Widget>[
             DrawerHeader(
               decoration: BoxDecoration(
                 color: Colors.blue,
               ),
               child: Text('Cell counter'),
             ),
             ListTile(
               title: Text('Historic'),
               onTap: () {
                 Get.back();
                 Get.to(HistoricWidget());
               },
             )
           ],
         ),
       ),
      appBar: AppBar(
        title: Text("Cell counter"),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => c.increment(),
        child: Stack(
        children: [
           Column(
             children: [
               Expanded(
                   child: Container(
                     color: Colors.blue,
                   ),
                 ),
             ],
           ),
           Center(
            child: Obx(() => Text(c.count.toString(), style: Theme.of(context).primaryTextTheme.headline1,) )

           )
        ],
      ))
        ,
      floatingActionButton: FloatingActionButton(
        onPressed: () => c.zero(),
        tooltip: 'Increment',
        backgroundColor: Colors.red,
        child: Icon(Icons.delete),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HistoricWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Controller c = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text("Cell counter"),
      ),
      body: ListView.separated(
          itemBuilder: (ctx, ix) {
            CounterAction action = c.actions[c.actions.length - 1 - ix];

            return GestureDetector(
              onTap: () {
                c.setTo(int.parse(action.payload));
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("${action.timestamp.day}/${action.timestamp.month}/${action.timestamp.year}"),
                      Text("${action.timestamp.hour}:${action.timestamp.minute}:${action.timestamp.second}.${action.timestamp.millisecond}"),
                    ],
                  ),
                  Text(action.name),
                  Text(action.payload)

                ],
          ),
              ),
            );
          },
          separatorBuilder: (ctx, ix) => Divider(),
          itemCount: c.actions.length
      )
    );
  }
}
