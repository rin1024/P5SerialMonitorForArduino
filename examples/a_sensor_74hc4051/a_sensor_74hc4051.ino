#include "analogmuxdemux.h"

#define __M_COMPILE_DATE__ __DATE__ " " __TIME__
#define __M_FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#define SEPARATOR ","

#define NO_UNITS 2
#define NO_SENSORS_PER_AMX 8

#define U1_S0 4
#define U1_S1 5
#define U1_S2 6
#define U1_READ_PINS A0

#define U2_S0 4
#define U2_S1 5
#define U2_S2 6
#define U2_READ_PINS A1

const int EN_PINS[NO_UNITS] = {
  2, 3
};

AnalogMux units[NO_UNITS] = {
  AnalogMux(U1_S0, U1_S1, U1_S2, U1_READ_PINS),
  AnalogMux(U2_S0, U2_S1, U2_S2, U2_READ_PINS),
};

#define SENSING_INTERVAL 25

uint32_t sensingTimer;

/*
 * 
 */
void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.print("[");
  Serial.print(__M_COMPILE_DATE__);
  Serial.print("]");
  Serial.println(__M_FILENAME__);

  Serial.println("setup ... ");
  delay(1000);

  for (int unitIndex = 0; unitIndex < NO_UNITS; unitIndex++) {
    pinMode(EN_PINS[unitIndex], OUTPUT);
    digitalWrite(EN_PINS[unitIndex], HIGH);
  }
}

/*
 * 
 */
void loop() {
  if (millis() - sensingTimer > SENSING_INTERVAL) {
    for (int unitIndex = 0; unitIndex < NO_UNITS; unitIndex++) {
      digitalWrite(EN_PINS[unitIndex], LOW);
      digitalWrite(EN_PINS[1 - unitIndex], HIGH);

      /*Serial.print("[");
      Serial.print(unitIndex);
      Serial.print("]");*/
      for (int pinIndex = 0; pinIndex < NO_SENSORS_PER_AMX; pinIndex++) {
        units[unitIndex].SelectPin(pinIndex);
        
        uint16_t reading = units[unitIndex].AnalogRead();
        //Serial.print(pinIndex);
        Serial.print(reading);
        Serial.print(SEPARATOR);
      }
      //Serial.println();
    }
    Serial.println();

    sensingTimer = millis();
  }
}
