#include <Arduino_BMI270_BMM150.h>  // Correct IMU Library for Rev2
#include <PDM.h>                    // Microphone Library
#include <ArduinoBLE.h>              // BLE Library

// BLE Service & Characteristics
BLEService pdMonitorService("180D");  // Custom BLE Service UUID
BLEFloatCharacteristic tremorCharacteristic("2A37", BLERead | BLENotify);
BLEFloatCharacteristic gaitCharacteristic("2A38", BLERead | BLENotify);
BLEFloatCharacteristic audioCharacteristic("2A39", BLERead | BLENotify);

volatile int audioLevel = 0;

// Microphone Callback Function
void onPDMdata() {
  int16_t sampleBuffer[256];
  int bytesRead = PDM.read(sampleBuffer, sizeof(sampleBuffer));

  if (bytesRead > 0) {
    long sum = 0;
    for (int i = 0; i < bytesRead / 2; i++) {
      sum += abs(sampleBuffer[i]);
    }
    audioLevel = sum / (bytesRead / 2);
  }
}

void setup() {
  Serial.begin(115200);
  
  // Initialize IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }

  // Initialize Microphone
  PDM.onReceive(onPDMdata);
  if (!PDM.begin(1, 16000)) {  // 1 channel, 16kHz
    Serial.println("Failed to initialize microphone!");
    while (1);
  }

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("Failed to initialize BLE!");
    while (1);
  }

  // Setup BLE Service & Characteristics
  BLE.setLocalName("PDMonitor");
  BLE.setAdvertisedService(pdMonitorService);
  pdMonitorService.addCharacteristic(tremorCharacteristic);
  pdMonitorService.addCharacteristic(gaitCharacteristic);
  pdMonitorService.addCharacteristic(audioCharacteristic);
  BLE.addService(pdMonitorService);

  // Start Advertising
  BLE.advertise();
  Serial.println("BLE Device Ready. Waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();  // Check for BLE connection
  
  if (central) {
    Serial.print("Connected to: ");
    Serial.println(central.address());

    while (central.connected()) {
      float ax, ay, az, gx, gy, gz;
      if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable()) {
        IMU.readAcceleration(ax, ay, az);
        IMU.readGyroscope(gx, gy, gz);

        // Calculate tremor intensity (magnitude of acceleration)
        float tremorIntensity = sqrt(ax * ax + ay * ay + az * az);
        tremorCharacteristic.writeValue(tremorIntensity);

        // Calculate gait instability (variance in gyroscope)
        float gaitInstability = sqrt(gx * gx + gy * gy + gz * gz);
        gaitCharacteristic.writeValue(gaitInstability);

        // Send audio level
        audioCharacteristic.writeValue((float)audioLevel);

        // Debugging
        Serial.print("Tremor: ");
        Serial.print(tremorIntensity);
        Serial.print(" | Gait: ");
        Serial.print(gaitInstability);
        Serial.print(" | Audio: ");
        Serial.println(audioLevel);
      }
      delay(500);  // Adjust as needed
    }

    Serial.println("Disconnected.");
  }
}
