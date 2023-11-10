import processing.serial.*;
import processing.sound.*;

///////////////////////////////////////////////
final int NUM_SENSORS = 12;

final int SERIAL_INDEX = 2;
final int SERUAL_BAUDRATE = 115200;

final char SENSOR_SEPARATOR = ',';

///////////////////////////////////////////////
final int SCREEN_WIDTH = 600;
final int SCREEN_HEIGHT = 400;

final int SIDE_MARGIN = 30;
final int GRAPH_Y = 80;

///////////////////////////////////////////////
Serial myPort;
int[] serialInArray = new int[NUM_SENSORS];

PFont font;
int barGap, barWidth, divWidth;
int[] bars = new int[NUM_SENSORS];

///////////////////////////////////////////////
final int STATUS_ON = 1;
final int STATUS_OFF = 0;

SoundFile[] soundFiles;
int[] lastStatuses;

///////////////////////////////////////////////
void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[SERIAL_INDEX], SERUAL_BAUDRATE);

  divWidth = (SCREEN_WIDTH - SIDE_MARGIN) / NUM_SENSORS;
  barWidth = int(0.5f * float(divWidth));
  barGap = divWidth - barWidth;
  
  font = createFont("Arial", 12);
  textFont(font);

  lastStatuses = new int[NUM_SENSORS];
  soundFiles = new SoundFile[NUM_SENSORS];
  for (int i = 0; i < NUM_SENSORS; i++) {
    soundFiles[i] = new SoundFile(this, dataPath("../../../doc/sounds/" + (i+1) + ".aif"));
    lastStatuses[i] = STATUS_OFF;
  }
}

void draw() {
  background(0);
  
  fill(255);
  textAlign(LEFT);
  text("PORT: " + Serial.list()[SERIAL_INDEX], SIDE_MARGIN, SIDE_MARGIN);
  
  textAlign(CENTER);
  for (int i=0; i<NUM_SENSORS; i++) {
    fill(225, (255 - bars[i]), 0);
    rect(i * divWidth + SIDE_MARGIN - barWidth / 2, SCREEN_HEIGHT - GRAPH_Y, barWidth, -bars[i] / 4);
    fill(255);
    text(bars[i], i * divWidth + SIDE_MARGIN, SCREEN_HEIGHT - bars[i] / 4 - 5 - GRAPH_Y);

    fill(255);
    text("[" + String.format("%02d",  i) + "]" + "\r\n" + String.format("%3d", bars[i]), i * divWidth + SIDE_MARGIN + barWidth / 2 - 5, SCREEN_HEIGHT - GRAPH_Y + 20);
  }
}

void serialEvent(Serial myPort) {
  String readStrings = myPort.readStringUntil('\n');
  if (lastStatuses != null && readStrings != null) {
    String sensorValues[] = split(readStrings, SENSOR_SEPARATOR);
    for (int i=0; i<sensorValues.length; i++) {
      if (i < bars.length) {
        int status = parseInt(sensorValues[i]);
        //print(status + "\t");
        
        bars[i] = status == STATUS_ON ? 100 : 0;
        
        try {
          if (lastStatuses[i] != status && status == STATUS_ON) {
            soundFiles[i].play(0.5, 1.0);
          }
        }
        catch (Exception e) {
          println("[" + i + "] error: " + e);
        }

        lastStatuses[i] = status;
      }
    }
    //println();
  }
}
