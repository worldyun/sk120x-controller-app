import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knob_widget/knob_widget.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:sk120x_controller_app/ble.dart';
import 'package:sk120x_controller_app/models/sk_device.dart';
import 'package:sk120x_controller_app/utils/event_bus.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK120X',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PowerSupplyApp(),
    );
  }
}

class PowerSupplyApp extends StatefulWidget {
  const PowerSupplyApp({super.key});

  @override
  State<PowerSupplyApp> createState() => _PowerSupplyAppState();
}

class _PowerSupplyAppState extends State<PowerSupplyApp> {
  double setVoltage = 0.0;
  double setCurrent = 0.0;
  double currentVoltage = 3.3;
  double currentCurrent = 0.0;
  double currentPower = 0.0;
  int totalEnergymWh = 0;
  int totalmAh = 0;
  bool powerOn = false;
  bool isDeviceInit = false;
  Ble ble = Ble();
  late SkDevice skDevice;
  bool isViveTotalmAh = false;
  bool isUpdating = false;
  Timer? knodUpdateTimer;
  double newSetV = 0.0;
  double newSetA = 0.0;
  bool isFirstTimeV = true;
  bool isFirstTimeA = true;
  bool devicePowerOn = false;
  // 间隔时间
  int interval = 1500;

  late StreamSubscription<BleEvent> bleEvent;

  List<String> options = [
    '设置电压',
    '设置电流',
    '查看日志',
    '系统设置',
    '关于',
  ];

  final double _minimumV = 0;
  final double _maximumV = 36;
  final double _minimumA = 0;
  final double _maximumA = 6;

  late KnobController _controllerV;
  late KnobController _controllerA;

  late BuildContext buildContext;

  void valueChangedListenerV(double value) {
    if (isFirstTimeV) {
      isFirstTimeV = false;
      return;
    }
    isUpdating = true;
    if (setVoltage != value) {
      value = (value * 10).roundToDouble() / 10;
      interval = 1500;
    } else {
      interval = 100;
    }
    if (newSetV != value) {
      Vibration.vibrate(duration : 25);
    }
    if (mounted) {
      setState(() {
        setVoltage = value;
        newSetV = value;
        knobUpdateVale("V");
      });
    }
  }

  void valueChangedListenerA(double value) {
    if (isFirstTimeA) {
      isFirstTimeA = false;
      return;
    }
    isUpdating = true;
    if (setCurrent != value) {
      value = (value * 20).roundToDouble() / 20;
      interval = 1500;
    } else {
      interval = 100;
    }
    if (newSetA != value) {
      Vibration.vibrate(duration : 25);
    }
    if (mounted) {
      setState(() {
        setCurrent = value;
        newSetA = value;
        knobUpdateVale("A");
      });
    }
  }

  //消除抖动更新电压与电流 两次更新之间的间隔不得小于interval ms
  void knobUpdateVale(String type) async {
    if (knodUpdateTimer != null) {
      // 如果定时器已存在，取消之前的定时器
      knodUpdateTimer!.cancel();
      knodUpdateTimer = null;
    } 
    knodUpdateTimer = Timer(Duration(milliseconds: interval), () async {
      bool isSuccess = false;
      try {
        if (type == "V") {
          int newSetVInt = (newSetV * 100.0).truncate();
          isSuccess = await ble.setConfigValue("vSet", newSetVInt);
        } else if (type == "A") {
          int newSetAInt = (newSetA * 1000.0).truncate();
          isSuccess = await ble.setConfigValue("iSet", newSetAInt);
        }
      } finally {
        if (isSuccess) {
          Vibration.vibrate(preset: VibrationPreset.quickSuccessAlert);
        } else {
          Vibration.vibrate(duration : 300);
        }
        knodUpdateTimer = null;
        // 设置 isUpdating 为 false，表示更新已完成
        Timer(const Duration(milliseconds: 250), () async {
          isUpdating = false;
        });
      }
    });
  }

  void listViewOnTap(int index) {
    switch (index) {
      case 0:
        _showSettingDialog(context, '设置电压', (value) {
          setState(() {
            setVoltage = value;
            _controllerV.setCurrentValue(value);
          });
        });
        break;
      case 1:
        _showSettingDialog(context, '设置电流', (value) {
          setState(() {
            setCurrent = value;
            _controllerA.setCurrentValue(value);
          });
        });
        break;
      case 2:
        // 查看日志
        break;
      case 3:
        // 系统设置
        break;
      case 4:
        // 关于
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerV = KnobController(
      initial: setVoltage,
      minimum: _minimumV,
      maximum: _maximumV,
      startAngle: 0,
      endAngle: 315,
      precision: 3,
    );
    _controllerV.addOnValueChangedListener(valueChangedListenerV);

    _controllerA = KnobController(
      initial: setVoltage,
      minimum: _minimumA,
      maximum: _maximumA,
      startAngle: 0,
      endAngle: 315,
      precision: 3,
    );
    _controllerA.addOnValueChangedListener(valueChangedListenerA);
    initEvent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildContext = context;
      ble.init(context);
    });

    WakelockPlus.enable();
  }

  void powerSwitch(bool value) {
    // powerOn = value;
    if (value) {
      ble.setConfigValue("outEnable", 1);
    } else {
      ble.setConfigValue("outEnable", 0);
    }
  }

  void initEvent() {
    bleEvent = eventBus.on<BleEvent>().listen((event) {
      if (event.eventCode == "bleOff" || event.eventCode == "disconnected") {
        setState(() {
          isDeviceInit = false;
          isFirstTimeA = true;
          isFirstTimeV = true;
        });
      }
      if (event.eventCode == "skDeviceInit") {
        setState(() {
          isFirstTimeA = true;
          isFirstTimeV = true;
          isUpdating = false;
          isDeviceInit = true;
          skDevice = event.skDevice!;
          if (skDevice.deviceStatus == 0) {
            devicePowerOn = true;
          } else {
            devicePowerOn = false;
            //设置一秒后执行
            Future.delayed(const Duration(seconds: 1), () {
              ble.refreshAllConfig();
            });
          }
        });
        _parseData();
        _controllerA.setCurrentValue(skDevice.iSet / 1000.0);
        _controllerV.setCurrentValue(skDevice.vSet / 100.0);
      }
      if (event.eventCode == "notifyTop10REGReceived" ||
          event.eventCode == "skDeviceUpdate") {
        skDevice = event.skDevice!;
        _parseData();
      }
    });
  }

  void _parseData() {
    if (powerOn != (skDevice.outEnable == 1)) {
      Vibration.vibrate(preset: VibrationPreset.quickSuccessAlert);
    }
    setState(() {
      currentVoltage = skDevice.vOut / 100.0;
      currentCurrent = skDevice.iOut / 1000.0;
      currentPower = skDevice.wOut / 100.0;
      totalEnergymWh = skDevice.whOut;
      totalmAh = skDevice.ahOut;
      powerOn = skDevice.outEnable == 1;
      if (!isUpdating) {
        setVoltage = skDevice.vSet / 100.0;
        setCurrent = skDevice.iSet / 1000.0;
      }
    });
  }

  // 新增方法：显示设置对话框
  void _showSettingDialog(
      BuildContext context, String title, Function(double) onConfirm) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '请输入值'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                double value = double.tryParse(controller.text) ?? 0.0;
                if (title == '设置电压') {
                  if (value < _minimumV || value > _maximumV) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('输入值超出范围！'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                } else if (title == '设置电流') {
                  if (value < _minimumA || value > _maximumA) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('输入值超出范围！'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                }
                onConfirm(value);
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    String text = '';
    if (!isDeviceInit) {
      text = '正在搜索设备, 请打开蓝牙';
    } else if (!devicePowerOn) {
      text = '设备未开机';
    }
    return Scaffold(
      body: isDeviceInit && devicePowerOn
          ? OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout();
              },
            )
          : Center(
              child: Text(
                text,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // 添加假的 AppBar
        Container(
          height: 80.0,
          color: Colors.black38,
          alignment: Alignment.center,
          child: const Text(
            'SK120X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.5, // 修改卡片的宽高比
              children: [
                _buildCombinedInfoCard('电压', setVoltage.toStringAsFixed(2),
                    currentVoltage.toStringAsFixed(2), 'V', () {
                  _showSettingDialog(context, '设置电压', (value) {
                    setState(() {
                      setVoltage = value;
                      _controllerV.setCurrentValue(value);
                    });
                  });
                }),
                _buildCombinedInfoCard('电流', setCurrent.toStringAsFixed(3),
                    currentCurrent.toStringAsFixed(3), 'A', () {
                  _showSettingDialog(context, '设置电流', (value) {
                    setState(() {
                      setCurrent = value;
                      _controllerA.setCurrentValue(value);
                    });
                  });
                }),
                _buildInfoCard(
                    '功率', currentPower.toStringAsFixed(3), 'W', () {}),
                _buildInfoCard(
                    '电量',
                    isViveTotalmAh
                        ? totalmAh.toString().padLeft(3, '0')
                        : totalEnergymWh.toString().padLeft(3, '0'),
                    isViveTotalmAh ? 'mAh' : 'mWh', () {
                  Vibration.vibrate(duration : 25);
                  setState(() {
                    isViveTotalmAh = !isViveTotalmAh;
                  });
                }),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _getStwitch(),
        ),
        Expanded(
          flex: 7,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(options[index]),
                onTap: () {
                  // 处理选项点击事件
                  listViewOnTap(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.5, // 修改卡片的宽高比
              children: [
                _buildCombinedInfoCard('电压', setVoltage.toStringAsFixed(2),
                    currentVoltage.toStringAsFixed(2), 'V', () {
                  // _showSettingDialog(context, '设置电压', (value) {
                  //   setState(() {
                  //     setVoltage = value;
                  //     _controllerV.setCurrentValue(value);
                  //   });
                  // });
                }),
                _buildCombinedInfoCard('电流', setCurrent.toStringAsFixed(3),
                    currentCurrent.toStringAsFixed(3), 'A', () {
                  // _showSettingDialog(context, '设置电流', (value) {
                  //   setState(() {
                  //     setCurrent = value;
                  //     _controllerA.setCurrentValue(value);
                  //   });
                  // });
                }),
                _buildInfoCard(
                    '功率', currentPower.toStringAsFixed(3), 'W', () {}),
                _buildInfoCard(
                    '电量',
                    isViveTotalmAh
                        ? totalmAh.toString().padLeft(3, '0')
                        : totalEnergymWh.toString().padLeft(3, '0'),
                    isViveTotalmAh ? 'mAh' : 'mWh', () {
                  Vibration.vibrate(duration : 25);
                  setState(() {
                    isViveTotalmAh = !isViveTotalmAh;
                  });
                }),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Knob(
                      controller: _controllerV,
                      width: 100,
                      height: 100,
                      style: KnobStyle(
                        labelOffset: 3.0,
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        majorTickStyle: const MajorTickStyle(
                          length: 5,
                        ),
                        pointerStyle: const PointerStyle(
                          color: Colors.green,
                          offset : 10.0,
                        ),
                        showMinorTickLabels: false,
                        minorTicksPerInterval: 4,
                        controlStyle: const ControlStyle(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.green,
                          glowColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Knob(
                      controller: _controllerA,
                      width: 100,
                      height: 100,
                      style: KnobStyle(
                        labelOffset: 3.0,
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        majorTickStyle: const MajorTickStyle(
                          length: 5,
                        ),
                        pointerStyle: const PointerStyle(
                          color: Color.fromARGB(255, 255, 187, 0),
                          offset: 10.0,
                        ),
                        showMinorTickLabels: true,
                        controlStyle: const ControlStyle(
                          backgroundColor: Colors.white,
                          shadowColor: Color.fromARGB(255, 255, 187, 0),
                          glowColor: Color.fromARGB(255, 255, 187, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '电压',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(width: 120),
                    Text(
                      '电流',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getStwitch(),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  AnimatedToggleSwitch<bool> _getStwitch() {
    return AnimatedToggleSwitch<bool>.dual(
      current: powerOn,
      first: false,
      second: true,
      spacing: 150.0,
      style: const ToggleStyle(
        borderColor: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      borderWidth: 5.0,
      height: 55,
      onChanged: (b) => powerSwitch(b),
      styleBuilder: (b) => ToggleStyle(
        backgroundColor: b ? Colors.green : Colors.black12,
        indicatorColor: b ? Colors.blue : Colors.red,
        borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4.0), right: Radius.circular(50.0)),
        indicatorBorderRadius: BorderRadius.circular(b ? 50.0 : 4.0),
      ),
      iconBuilder: (value) => Icon(
        value ? Icons.power : Icons.power_settings_new_rounded,
        size: 32.0,
        color: value ? Colors.black : Colors.white,
      ),
      textBuilder: (value) => value
          ? const Center(
              child: Text('输出已开启', style: TextStyle(color: Colors.black)))
          : const Center(
              child: Text('输出已关闭', style: TextStyle(color: Colors.black))),
    );
  }

  Widget _buildInfoCard(
      String title, String value, String unit, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      unit,
                      style: const TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCombinedInfoCard(String title, String setValue,
      String currentValue, String unit, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    setValue,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    unit,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentValue,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    unit,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.normal),
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
