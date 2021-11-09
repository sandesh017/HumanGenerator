// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hfacegenerator/setdrawingarea.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SetDrawingArea> allPoints = [];

  void saveToImage(List<DrawingArea> points) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(200, 200)));
    Paint paint = Paint()
      ..color = Colors.white.strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 256, 256), paint2);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);

    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final listBytes = Uint8List.view(pngBytes.buffer);

    //File file = await writeBytes(listBytes);

    String base64 = base64Encode(listBytes);
    fetchResponse(base64);
  }

  void fetchResponse(var base64Image) async {
    var data = {"Image": base64Image};

    var url = 'http://192.168.1.70:5000/predict';
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'Keep-Alive',
    };
    var body = json.encode(data);
    try {
      var response =
          await http.post(Uri.parse(url), body: body, headers: headers);

      final Map<String, dynamic> responseData = json.decode(response.body);

      String outputBytes = responseData['Image'];
    } catch (e) {
      debugPrint('*Error has occured');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken),
            image: const AssetImage("assets/pic.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 6.0,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onPanDown: (details) {
                          // ignore: unnecessary_this
                          this.setState(() {
                            allPoints.add(SetDrawingArea(
                                points: details.localPosition,
                                paintArea: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0));
                          });
                        },
                        onPanUpdate: (details) {
                          // ignore: unnecessary_this
                          this.setState(() {
                            allPoints.add(SetDrawingArea(
                                points: details.localPosition,
                                paintArea: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0));
                          });
                        },
                        onPanEnd: (details) {
                          // ignore: unnecessary_this
                          this.setState(() {
                            allPoints.add(null);
                          });
                        },
                        child: SizedBox.expand(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(22.0),
                            ),
                            child: CustomPaint(
                              painter: MyCustomPainter(allPoints: allPoints),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              this.setState(() {
                                allPoints.clear();
                              });
                            },
                            icon: const Icon(
                              Icons.layers_clear,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
