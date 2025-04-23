class SkDevice {
  int vSet; // 设置电压
  int iSet; // 设置电流
  int vOut; // 输出电压
  int iOut; // 输出电流
  int wOut; // 输出功率
  int vIn; // 输入电压
  int ahOutLow; // 输出安时 - 低2字节
  int ahOutHigh; // 输出安时 - 高2字节
  int ahOut; // 输出安时
  int whOutLow; // 输出瓦时 - 低2字节
  int whOutHigh; // 输出瓦时 - 高2字节
  int whOut; // 输出瓦时
  int hOut; // 输出时间-小时
  int mOut; // 输出时间-分钟
  int sOut; // 输出时间-秒钟
  int tempInside; // 内部温度
  int tempOutside; // 外部温度
  int keyLock; // 按键锁
  int protectStatus; // 保护状态
  int cvccMode; // CVCC模式
  int outEnable; // 输出使能
  int tempUnit; // 温度单位
  int backlightLevel; // 背光等级
  int sleepTime; // 休眠时间
  int skModel; // 设备型号
  int skVersion; // 固件版本号
  int skModbusId; // ModBus ID
  int skBaudrate; // ModBus 波特率
  int tempInsideOffset; // 内部温度偏移修正
  int tempOutsideOffset; // 外部温度偏移修正
  int buzzerEnable; // 蜂鸣器使能
  int extractCfgGrop; // 快速设置组
  int deviceStatus; // 设备状态
  int mpptEnable; // MPPT使能
  int mpptK; // MPPT最大功率点系数
  int batteryChargeCutoffI; // 电池充电截止电流
  int cwEnable; // 恒功率使能
  int cw; // 恒功率值

  Map<String, int> skDeviceFieldOffsets = {
    'vSet': 0,
    'iSet': 2,
    'vOut': 4,
    'iOut': 6,
    'wOut': 8,
    'vIn': 10,
    'ahOutLow': 12,
    'ahOutHigh': 14,
    'whOutLow': 16,
    'whOutHigh': 18,
    'hOut': 20,
    'mOut': 22,
    'sOut': 24,
    'tempInside': 26,
    'tempOutside': 28,
    'keyLock': 30,
    'protectStatus': 32,
    'cvccMode': 34,
    'outEnable': 36,
    'tempUnit': 38,
    'backlightLevel': 40,
    'sleepTime': 42,
    'skModel': 44,
    'skVersion': 46,
    'skModbusId': 48,
    'skBaudrate': 50,
    'tempInsideOffset': 52,
    'tempOutsideOffset': 54,
    'buzzerEnable': 56,
    'extractCfgGrop': 58,
    'deviceStatus': 60,
    'mpptEnable': 62,
    'mpptK': 64,
    'batteryChargeCutoffI': 66,
    'cwEnable': 68,
    'cw': 70,
  };

  SkDevice({
    this.vSet = 0,
    this.iSet = 0,
    this.vOut = 0,
    this.iOut = 0,
    this.wOut = 0,
    this.vIn = 0,
    this.ahOutLow = 0,
    this.ahOutHigh = 0,
    this.whOutLow = 0,
    this.whOutHigh = 0,
    this.hOut = 0,
    this.mOut = 0,
    this.sOut = 0,
    this.tempInside = 0,
    this.tempOutside = 0,
    this.keyLock = 0,
    this.protectStatus = 0,
    this.cvccMode = 0,
    this.outEnable = 0,
    this.tempUnit = 0,
    this.backlightLevel = 0,
    this.sleepTime = 0,
    this.skModel = 0,
    this.skVersion = 0,
    this.skModbusId = 0,
    this.skBaudrate = 0,
    this.tempInsideOffset = 0,
    this.tempOutsideOffset = 0,
    this.buzzerEnable = 0,
    this.extractCfgGrop = 0,
    this.deviceStatus = 0,
    this.mpptEnable = 0,
    this.mpptK = 0,
    this.batteryChargeCutoffI = 0,
    this.cwEnable = 0,
    this.cw = 0,
    this.ahOut = 0,
    this.whOut = 0,
  });

  // 新增解析函数
  static SkDevice parseFromBytes(List<int> bytes) {
    if (bytes.length < 72) {
      throw ArgumentError('输入数据长度不足');
    }

    return SkDevice(
      vSet: _parseUint16(bytes, 0),
      iSet: _parseUint16(bytes, 2),
      vOut: _parseUint16(bytes, 4),
      iOut: _parseUint16(bytes, 6),
      wOut: _parseUint16(bytes, 8),
      vIn: _parseUint16(bytes, 10),
      ahOutLow: _parseUint16(bytes, 12),
      ahOutHigh: _parseUint16(bytes, 14),
      ahOut: _parseUint16(bytes, 12) + (_parseUint16(bytes, 14) << 16),
      whOutLow: _parseUint16(bytes, 16),
      whOutHigh: _parseUint16(bytes, 18),
      whOut: _parseUint16(bytes, 16) + (_parseUint16(bytes, 18) << 16),
      hOut: _parseUint16(bytes, 20),
      mOut: _parseUint16(bytes, 22),
      sOut: _parseUint16(bytes, 24),
      tempInside: _parseUint16(bytes, 26),
      tempOutside: _parseUint16(bytes, 28),
      keyLock: _parseUint16(bytes, 30),
      protectStatus: _parseUint16(bytes, 32),
      cvccMode: _parseUint16(bytes, 34),
      outEnable: _parseUint16(bytes, 36),
      tempUnit: _parseUint16(bytes, 38),
      backlightLevel: _parseUint16(bytes, 40),
      sleepTime: _parseUint16(bytes, 42),
      skModel: _parseUint16(bytes, 44),
      skVersion: _parseUint16(bytes, 46),
      skModbusId: _parseUint16(bytes, 48),
      skBaudrate: _parseUint16(bytes, 50),
      tempInsideOffset: _parseUint16(bytes, 52),
      tempOutsideOffset: _parseUint16(bytes, 54),
      buzzerEnable: _parseUint16(bytes, 56),
      extractCfgGrop: _parseUint16(bytes, 58),
      deviceStatus: _parseUint16(bytes, 60),
      mpptEnable: _parseUint16(bytes, 62),
      mpptK: _parseUint16(bytes, 64),
      batteryChargeCutoffI: _parseUint16(bytes, 66),
      cwEnable: _parseUint16(bytes, 68),
      cw: _parseUint16(bytes, 70),
    );
  }

  // 新增解析函数
  void parseFrom20Bytes(List<int> bytes) {
    if (bytes.length != 20) {
      throw ArgumentError('输入数据长度不足');
    }
    vSet = _parseUint16(bytes, 0);
    iSet = _parseUint16(bytes, 2);
    vOut = _parseUint16(bytes, 4);
    iOut = _parseUint16(bytes, 6);
    wOut = _parseUint16(bytes, 8);
    vIn = _parseUint16(bytes, 10);
    ahOutLow = _parseUint16(bytes, 12);
    ahOutHigh = _parseUint16(bytes, 14);
    whOutLow = _parseUint16(bytes, 16);
    whOutHigh = _parseUint16(bytes, 18);
    ahOut = ahOutLow + (ahOutHigh << 16);
    whOut = whOutLow + (whOutHigh << 16);
  }

  // 辅助函数：从字节列表中解析两个字节为无符号16位整数
  static int _parseUint16(List<int> bytes, int offset) {
    return (bytes[offset + 1] << 8) | bytes[offset];
  }

  int getfieldValueByfieldName(String fieldName) {
    switch (fieldName) {
      case 'vSet':
        return vSet;
      case 'iSet':
        return iSet;
      case 'vOut':
        return vOut;
      case 'iOut':
        return iOut;
      case 'wOut':
        return wOut;
      case 'vIn':
        return vIn;
      case 'ahOutLow':
        return ahOutLow;
      case 'ahOutHigh':
        return ahOutHigh;
      case 'whOutLow':
        return whOutLow;
      case 'whOutHigh':
        return whOutHigh;
      case 'hOut':
        return hOut;
      case 'mOut':
        return mOut;
      case 'sOut':
        return sOut;
      case 'tempInside':
        return tempInside;
      case 'tempOutside':
        return tempOutside;
      case 'keyLock':
        return keyLock;
      case 'protectStatus':
        return protectStatus;
      case 'cvccMode':
        return cvccMode;
      case 'outEnable':
        return outEnable;
      case 'tempUnit':
        return tempUnit;
      case 'backlightLevel':
        return backlightLevel;
      case 'sleepTime':
        return sleepTime;
      case 'skModel':
        return skModel;
      case 'skVersion':
        return skVersion;
      case 'skModbusId':
        return skModbusId;
      case 'skBaudrate':
        return skBaudrate;
      case 'tempInsideOffset':
        return tempInsideOffset;
      case 'tempOutsideOffset':
        return tempOutsideOffset;
      case 'buzzerEnable':
        return buzzerEnable;
      case 'extractCfgGrop':
        return extractCfgGrop;
      case 'deviceStatus':
        return deviceStatus;
      case 'mpptEnable':
        return mpptEnable;
      case 'mpptK':
        return mpptK;
      case 'batteryChargeCutoffI':
        return batteryChargeCutoffI;
      case 'cwEnable':
        return cwEnable;
      case 'cw':
        return cw;
      default:
        throw ArgumentError('未知字段名: $fieldName');
    }
  }

  void setfieldValueByfieldName(String fieldName, int value) {
    switch (fieldName) {
      case 'vSet':
        vSet = value;
        break;
      case 'iSet':
        iSet = value;
        break;
      case 'vOut':
        vOut = value;
        break;
      case 'iOut':
        iOut = value;
        break;
      case 'wOut':
        wOut = value;
        break;
      case 'vIn':
        vIn = value;
        break;
      case 'ahOutLow':
        ahOutLow = value;
        ahOut = ahOutLow + (ahOutHigh << 16);
        break;
      case 'ahOutHigh':
        ahOutHigh = value;
        ahOut = ahOutLow + (ahOutHigh << 16);
        break;
      case 'whOutLow':
        whOutLow = value;
        whOut = whOutLow + (whOutHigh << 16);
        break;
      case 'whOutHigh':
        whOutHigh = value;
        whOut = whOutLow + (whOutHigh << 16);
        break;
      case 'hOut':
        hOut = value;
        break;
      case 'mOut':
        mOut = value;
        break;
      case 'sOut':
        sOut = value;
        break;
      case 'tempInside':
        tempInside = value;
        break;
      case 'tempOutside':
        tempOutside = value;
        break;
      case 'keyLock':
        keyLock = value;
        break;
      case 'protectStatus':
        protectStatus = value;
        break;
      case 'cvccMode':
        cvccMode = value;
        break;
      case 'outEnable':
        outEnable = value;
        break;
      case 'tempUnit':
        tempUnit = value;
        break;
      case 'backlightLevel':
        backlightLevel = value;
        break;
      case 'sleepTime':
        sleepTime = value;
        break;
      case 'skModel':
        skModel = value;
        break;
      case 'skVersion':
        skVersion = value;
        break;
      case 'skModbusId':
        skModbusId = value;
        break;
      case 'skBaudrate':
        skBaudrate = value;
        break;
      case 'tempInsideOffset':
        tempInsideOffset = value;
        break;
      case 'tempOutsideOffset':
        tempOutsideOffset = value;
        break;
      case 'buzzerEnable':
        buzzerEnable = value;
        break;
      case 'extractCfgGrop':
        extractCfgGrop = value;
        break;
      case 'deviceStatus':
        deviceStatus = value;
        break;
      case 'mpptEnable':
        mpptEnable = value;
        break;
      case 'mpptK':
        mpptK = value;
        break;
      case 'batteryChargeCutoffI':
        batteryChargeCutoffI = value;
        break;
      case 'cwEnable':
        cwEnable = value;
        break;
      case 'cw':
        cw = value;
        break;
      default:
        throw ArgumentError('未知字段名: $fieldName');
    }
  }

  //根据寄存器号获取寄存器名称
  String getRegisterName(int regNumber) {
    for (var entry in skDeviceFieldOffsets.entries) {
      if (entry.value == regNumber) {
        return entry.key;
      }
    }
    return '未知寄存器';
  }
  //根据寄存器名称获取寄存器号
  int getRegisterNumber(String regName) {
    return skDeviceFieldOffsets[regName] ?? -1;
  }
  //根据寄存器号获取寄存器值
  int getRegisterValue(int regNumber) {
    for (var entry in skDeviceFieldOffsets.entries) {
      if (entry.value == regNumber) {
        return getfieldValueByfieldName(entry.key);
      }
    }
    return -1;
  }
  
  //根据寄存器号设置寄存器值
  void setRegisterValue(int regNumber, int value) {
    for (var entry in skDeviceFieldOffsets.entries) {
      if (entry.value == regNumber * 2) {
        setfieldValueByfieldName(entry.key, value);
        return;
      }
    }
    throw ArgumentError('未知寄存器号: $regNumber');
  } 
}
