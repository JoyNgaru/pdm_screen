# PD Monitor - README

## Introduction
PD Monitor is a Flutter-based mobile application designed for Parkinson's Disease telemonitoring. It integrates with an **Arduino Nano 33 BLE** device to collect and analyze motion and audio data to monitor symptoms.

---
## 1️⃣ Setting Up the Development Environment

### **1. Install Prerequisites**
Ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Visual Studio Code](https://code.visualstudio.com/)
- Android Studio (for SDK & Emulator)
- Git (for version control)
- Arduino IDE (for Arduino programming)

### **2. Set Up Flutter in VS Code**
1. Open **VS Code**.
2. Install the **Flutter & Dart extensions** from the Extensions Marketplace.
3. Verify Flutter installation:
   ```sh
   flutter doctor
   ```
   If there are issues, follow the suggestions given.

### **3. Clone the PD Monitor Project**
```sh
git clone https://github.com/your-repo/pd-monitor.git
cd pd-monitor
```

### **4. Configure a Physical or Virtual Device**
#### **Option 1: Physical Device (Recommended)**
1. Enable **Developer Mode** on your phone.
2. Enable **USB Debugging**.
3. Connect via USB or enable **Wireless Debugging**.
4. Run:
   ```sh
   flutter devices
   ```
   Ensure your device is listed.

#### **Option 2: Emulator**
1. Open **Android Studio**.
2. Install an emulator from AVD Manager.
3. Start the emulator and verify with:
   ```sh
   flutter devices
   ```

### **5. Run the App**
```sh
flutter pub get  # Install dependencies
flutter run       # Start the app on a connected device
```
---
## 2️⃣ Useful Flutter Commands
| Command | Description |
|---------|-------------|
| `flutter doctor` | Checks if Flutter is set up correctly |
| `flutter create .` | Creates a new Flutter project |
| `flutter pub get` | Fetches dependencies |
| `flutter run` | Runs the app on a connected device |
| `flutter clean` | Clears build files to fix issues |
| `flutter build apk` | Generates an APK for deployment |
| `flutter analyze` | Analyzes code for issues |
| `flutter test` | Runs tests |

---
## 3️⃣ Setting Up the Arduino Nano 33 BLE
### **1. Install Arduino IDE & Board Support**
1. Download & install **Arduino IDE** from [here](https://www.arduino.cc/en/software).
2. Open Arduino IDE and go to **Tools > Board > Boards Manager**.
3. Search for **Arduino Nano 33 BLE** and install the board package.

### **2. Connect Arduino & Upload Code**
1. Connect the **Arduino Nano 33 BLE** via USB.
2. Open **Arduino IDE** and go to **Tools > Port** and select your device.
3. Paste your Arduino code into the editor.
4. Click **Upload (⏫ button)** to flash the code.
5. Open **Serial Monitor (Tools > Serial Monitor)** to view sensor data.

### **3. Sample Arduino Code (BLE Sensor Streaming)**
```cpp
#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h> // For accelerometer & gyroscope

void setup() {
    Serial.begin(9600);
    if (!IMU.begin()) {
        Serial.println("Failed to initialize IMU!");
        while (1);
    }
    BLE.begin();
}

void loop() {
    float ax, ay, az;
    IMU.readAcceleration(ax, ay, az);
    Serial.print("Acceleration: "); Serial.println(ax);
    delay(1000);
}
```

---
## 4️⃣ Connecting Flutter App to Arduino via BLE
1. Install the **flutter_blue_plus** package:
   ```sh
   flutter pub add flutter_blue_plus
   ```
2. Scan for BLE devices in Flutter:
   ```dart
   FlutterBluePlus.instance.startScan();
   ```
3. Connect to the Arduino and start receiving data.

---
## Conclusion
You are now set up to develop and test the **PD Monitor** app! 🚀

For any issues, check the Flutter & Arduino documentation or reach out to the community!

