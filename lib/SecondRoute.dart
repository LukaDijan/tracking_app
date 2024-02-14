import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SecondRoute extends StatefulWidget {
  var access_token = "";

  SecondRoute({Key? key, required this.access_token}) : super(key: key);
  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];
  Color buttonColor = Colors.white;

  final String targetDeviceName = 'ESP32_AC';
  final String targetServiceUUID = 'a4122eb1-921d-472d-90f0-d59b54c60804';
  final String targetCharacteristicUUID =
      '6f5176cd-d06f-4dd4-a845-bfd0952b760c';
  BluetoothDevice? connectedDevice;

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    flutterBlue.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.name == targetDeviceName) {
          flutterBlue.stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });

    flutterBlue.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
      print('Connected to $targetDeviceName');
    } catch (e) {
      print('Error connecting to device: $e');
      setState(() {
        buttonColor = Colors.red;
      });
    }
    discoverServices(device);
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == targetServiceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == targetCharacteristicUUID) {
            writeData(characteristic);
            setState(() {
              buttonColor = Colors.green;
            });
          }
        }
      }
    }
  }

  Future<void> writeData(BluetoothCharacteristic characteristic) async {
    List<int> bytes = utf8.encode(widget.access_token);
    await characteristic.write(bytes);
    print("Data written to $targetCharacteristicUUID");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: startScan,
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    minimumSize: Size(300, 300),
                    shape: CircleBorder(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    connectedDevice?.disconnect();
    super.dispose();
  }
}

// if (result.device.name == targetDeviceName) {
//           if (!scanResults.any((existingResult) =>
//               existingResult.device.id == result.device.id)) {
//             setState(() {
//               scanResults.add(result);
//             });
//           }
//           connectToDevice(result.device);
//           break;
//         }
