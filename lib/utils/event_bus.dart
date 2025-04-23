import 'package:event_bus/event_bus.dart';
import 'package:sk120x_controller_app/models/sk_device.dart';


EventBus eventBus = EventBus();

class BleEvent {
  final String eventCode;
  SkDevice? skDevice;
  BleEvent(this.eventCode, {this.skDevice});
}