import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class CounterAction {
  int id;
  String name;
  DateTime timestamp;
  String payload;

  CounterAction(this.id, this.name, this.timestamp, this.payload);
}

class Controller extends GetxController{
  final AudioCache audio = new AudioCache();
  final AudioPlayer player = new AudioPlayer();
  Future<File> beepAudio;
  Database db;

  Controller() {
    beepAudio = audio.load("beep-23.wav");
    recoverDatabase();
  }

  recoverDatabase() async {
    var dbPath = await getDatabasesPath();
    var path = "$dbPath/cellcounter.db";
    db = await openDatabase(
        path,
      version: 1,
      onCreate: (db, version) async {
          print(version);
        await db.execute('CREATE TABLE counter_actions (id INTEGER PRIMARY KEY, name TEXT, payload TEXT, timestamp_millis INT)');
      }
    );

    List<Map> records = await db.rawQuery("SELECT id, name, payload, timestamp_millis FROM counter_actions");

    records.forEach((element) {
      var timestamp = DateTime.fromMillisecondsSinceEpoch(element["timestamp_millis"]);

      actions.add(
        CounterAction(element["id"], element["name"], timestamp, element["payload"])
      );
    });
  }

  var count = 0.obs;
  var actions = [].obs;

  increment() {
    count++;
    beep();
    insert("increment", DateTime.now(), count.toString());
  }

  zero() {
    count.value = 0;
    insert("zero", DateTime.now(), count.toString());
  }

  void insert(String name, DateTime timestamp, String payload) async {
    int id = await db.rawInsert(
        "INSERT INTO counter_actions(name, timestamp_millis, payload) VALUES (?, ?, ?)",
        [
          name,
          timestamp.millisecondsSinceEpoch,
          payload
        ]
    );

    actions.add(CounterAction(id, name, timestamp, payload));
  }

  setTo(int value) {
    count.value = value;
    insert("changed", DateTime.now(), value.toString());
  }

  beep() async {
    player.play((await beepAudio).path);
  }
}