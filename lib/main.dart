import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PD Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {}); // ✅ Ensures UI updates immediately
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return user == null ? const LoginScreen() : const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4)).listen((results) {
      for (ScanResult result in results) {
        // Check if the device is the Arduino Nano 33 BLE
        if (result.device.name == 'Arduino Nano 33 BLE') {
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    discoverServices(device);
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      // Assume the characteristic we want is the first one
      var chars = service.characteristics;
      if (chars.isNotEmpty) {
        setState(() {
          characteristic = chars.first;
        });
        readData();
      }
    });
  }

  void readData() async {
    if (characteristic != null) {
      characteristic!.setNotifyValue(true);
      characteristic!.value.listen((value) {
        // Process the received data
        String data = String.fromCharCodes(value);
        print('Received data: $data');
        // Check if an alert needs to be sent
        if (shouldSendAlert(data)) {
          sendAlert(data);
        }
      });
    }
  }

  bool shouldSendAlert(String data) {
    // Implement logic to determine if an alert should be sent
    // For example, if the data indicates a fall or abnormal movement
    return data.contains('ALERT');
  }

  void sendAlert(String data) async {
    // Call Firebase Cloud Function to send SMS
    final HttpsCallable sendSMS = FirebaseFunctions.instance.httpsCallable('sendSMS');
    try {
      await sendSMS.call(<String, dynamic>{
        'message': data,
      });
      print('SMS Alert sent successfully');
    } catch (e) {
      print('Failed to send SMS Alert: $e');
    }

    // Call Firebase Cloud Function to send WhatsApp message
    final HttpsCallable sendWhatsApp = FirebaseFunctions.instance.httpsCallable('sendWhatsApp');
    try {
      await sendWhatsApp.call(<String, dynamic>{
        'message': data,
      });
      print('WhatsApp Alert sent successfully');
    } catch (e) {
      print('Failed to send WhatsApp Alert: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PD Monitor'),
      ),
      body: Center(
        child: connectedDevice == null
            ? Text('Scanning for devices...')
            : Text('Connected to ${connectedDevice!.name}'),
      ),
    );
  }
}
