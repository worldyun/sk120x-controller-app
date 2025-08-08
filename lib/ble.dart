// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:sk120x_controller_app/models/sk_device.dart';
import 'package:sk120x_controller_app/utils/event_bus.dart';
import 'package:sk120x_controller_app/utils/my_toast.dart';

class Ble {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  bool isScanning = false;
  bool isConnected = false;
  late BuildContext context;
  late BluetoothService service;
  late BluetoothCharacteristic notifyTop10REGCharacteristic;
  late BluetoothCharacteristic allConfigCharacteristic;
  late BluetoothCharacteristic setConfigCharacteristic;
  late SkDevice skDevice;

  void init(BuildContext context) async {
    this.context = context;
    if (await FlutterBluePlus.isSupported == false) {
      MyToast.showToast(context, "此设备不支持蓝牙");
      return;
    }
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        print("蓝牙已打开");
        initScan();
      } else {
        eventBus.fire(BleEvent("bleOff"));
      }
    });

    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  void initScan() async {
    if (isScanning || isConnected) {
      return;
    }
    isScanning = true;
    devicesList.clear();
    services.clear();
    connectedDevice = null;
    isConnected = false;
    eventBus.fire(BleEvent("scanStart"));
    FlutterBluePlus.onScanResults.listen((results) async {
      devicesList.clear();
      if (results.isNotEmpty) {
        for (var element in results) {
          if (element.device.advName.startsWith("SK120X")) {
            devicesList.add(element.device);
          }
        }
        if (devicesList.isEmpty) {
          MyToast.showToast(context, "未发现设备, 将持续扫描");
        } else {
          await FlutterBluePlus.stopScan();
          isScanning = false;
          connectDevice();
        }
      }
    }, onError: (e) => log(e));

    FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    FlutterBluePlus.startScan(
      withKeywords: ["SK120X"],
      continuousUpdates: true,
    );
  }

  void connectDevice() async {
    var device = devicesList[0];
    connectedDevice = device;
    MyToast.showToast(context, "正在连接设备 ${device.advName}");
    // listen for disconnection
    var subscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) async {
      if (state == BluetoothConnectionState.disconnected) {
        if (isConnected) {
          MyToast.showToast(context, "连接已断开 ${device.advName}");
        }
        isConnected = false;
        connectedDevice = null;
        eventBus.fire(BleEvent("disconnected"));
        //定时3秒后重新扫描
        await Future.delayed(const Duration(seconds: 3));
        initScan();
      } else if (state == BluetoothConnectionState.connected) {
        MyToast.showToast(context, "设备已连接 ${device.advName}");
        await FlutterBluePlus.stopScan();
        isConnected = true;
        eventBus.fire(BleEvent("connected"));
        if (!kIsWeb && Platform.isAndroid) {
          device.requestMtu(512);
        }
        initServices(device);
      }
    });

    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    device.connect();
  }

  void initServices(BluetoothDevice device) async {
    services.clear();
    services = await device.discoverServices();
    for (var element in services) {
      if (element.uuid == Guid("1bb2b7e6-6769-4346-b8c3-413c97b29185")) {
        service = element;
      }
    }
    if (service.characteristics.isEmpty) {
      MyToast.showToast(context, "服务未发现");
      return;
    }
    for (var element in service.characteristics) {
      if (element.uuid == Guid("f2c4b5a0-1d3e-4b8f-9c6d-7a2e5f3b8a0b")) {
        notifyTop10REGCharacteristic = element;
      }
      if (element.uuid == Guid("c2d4ff46-5424-4b37-b3a4-e4a2ee4a4b0a")) {
        allConfigCharacteristic = element;
      }
      if (element.uuid == Guid("5f734ee8-4ff7-4fde-8918-61a363974e6e")) {
        setConfigCharacteristic = element;
      }
    }
    //初始化SkDevice
    List<int> bytes = await allConfigCharacteristic.read();
    skDevice = SkDevice.parseFromBytes(bytes);
    eventBus.fire(BleEvent("skDeviceInit", skDevice: skDevice));
    //设置通知
    await notifyTop10REGCharacteristic.setNotifyValue(true);
    //设置通知回调
    notifyTop10REGCharacteristic.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        skDevice.parseFrom20Bytes(value);
        eventBus.fire(BleEvent("notifyTop10REGReceived", skDevice: skDevice));
      }
    });
    eventBus.fire(BleEvent("servicesDiscovered"));
  }

  //刷新所有配置
  Future<void> refreshAllConfig() async {
    List<int> bytes = await allConfigCharacteristic.read();
    skDevice = SkDevice.parseFromBytes(bytes);
    eventBus.fire(BleEvent("skDeviceInit", skDevice: skDevice));
  }

  Future<bool> setConfigValue(String fieldName, int value) async {
    int offset = skDevice.skDeviceFieldOffsets[fieldName] ?? -1;
    if (offset == -1) {
      MyToast.showToast(context, "未知寄存器 $fieldName");
      return false;
    }
    int regNunber = offset ~/ 2;

    // 失败后重试一次
    return (await writeRegister(regNunber, value))
        ? true
        : (await writeRegister(regNunber, value));
  }

  Future<bool> writeRegister(int regNumber, int regData) async {
    //处理小端字节序
    int regDataLow = regData & 0xFF;
    int regDataHigh = (regData >> 8) & 0xFF;
    int regNumberLow = regNumber & 0xFF;
    int regNumberHigh = (regNumber >> 8) & 0xFF;
    List<int> bytes = [
      0x01,
      regNumberLow,
      regNumberHigh,
      regDataLow,
      regDataHigh,
    ];
    await setConfigCharacteristic.write(bytes);
    var readDate = await setConfigCharacteristic.read();
    if (readDate.isNotEmpty) {
      int regDataRead = (readDate[1] << 8) | readDate[0];
      if (regDataRead != regData) {
        MyToast.showToast(context, "设置失败");
        refreshAllConfig();
        return false;
      } else {
        //更新skDevice对象
        skDevice.setRegisterValue(regNumber, regDataRead);
        eventBus.fire(BleEvent("skDeviceUpdate", skDevice: skDevice));
        return true;
      }
    } else {
      MyToast.showToast(context, "设置失败");
      return false;
    }
  }
}
