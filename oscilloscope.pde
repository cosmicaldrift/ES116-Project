import processing.serial.*;

Serial myPort;
String inData;

int[] buffer1;
int[] buffer2;
int bufferSize = 500;
int bufferIndex = 0;

float xScale = 1.0;  
float yScale = 1.0;  
float yOffset = 0.0; 

void setup() {
  size(800, 400);
  printArray(Serial.list());
  String portName = "/dev/cu.usbmodem141011"; 
  myPort = new Serial(this, portName, 115200);
  myPort.bufferUntil('\n');

  buffer1 = new int[bufferSize];
  buffer2 = new int[bufferSize];
}

void draw() {
  background(30);

  if (bufferIndex == 0) {
    fill(255, 255, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("Waiting for data...", width / 2, height / 2);
    return;
  }

  stroke(40);  
  strokeWeight(1);

  for (int i = 0; i < width; i += 80) {
    line(i, 0, i, height);
  }
  for (int j = 0; j < height; j += 40) {
    line(0, j, width, j);
  }

  stroke(100);
  line(0, height / 2, width, height / 2);  
  line(width / 2, 0, width / 2, height);   

  int min1 = 1023, max1 = 0;
  int min2 = 1023, max2 = 0;
  for (int i = 0; i < bufferSize; i++) {
    if (buffer1[i] < min1) min1 = buffer1[i];
    if (buffer1[i] > max1) max1 = buffer1[i];
    if (buffer2[i] < min2) min2 = buffer2[i];
    if (buffer2[i] > max2) max2 = buffer2[i];
  }
  float vpp1 = (max1 - min1) * (5.0 / 1023.0);  
  float vpp2 = (max2 - min2) * (5.0 / 1023.0);  

  fill(0, 0, 0, 150);
  stroke(255);
  strokeWeight(1);
  rect(width - 120, 10, 110, 60);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Ch1 Vpp: " + nf(vpp1, 1, 2) + " V", width - 110, 20);
  text("Ch2 Vpp: " + nf(vpp2, 1, 2) + " V", width - 110, 40);

  stroke(0, 255, 0); 
  noFill();
  beginShape();
  for (int i = 0; i < bufferSize; i++) {
    float x = map(i, 0, bufferSize, width / 2 - width / (2 * xScale), width / 2 + width / (2 * xScale));
    float y = map(buffer1[i], 0, 1023, height, 0) * yScale + yOffset;
    vertex(x, y);
  }
  endShape();

  stroke(0, 150, 255); 
  noFill();
  beginShape();
  for (int i = 0; i < bufferSize; i++) {
    float x = map(i, 0, bufferSize, width / 2 - width / (2 * xScale), width / 2 + width / (2 * xScale));
    float y = map(buffer2[i], 0, 1023, height, 0) * yScale + yOffset;
    vertex(x, y);
  }
  endShape();

  fill(0, 0, 0, 150);  
  stroke(255);
  strokeWeight(1);
  rect(10, 10, 100, 40);  

  fill(0, 255, 0);  
  textAlign(LEFT, TOP);
  text("Ch1", 20, 15);

  fill(0, 150, 255);  
  text("Ch2", 20, 30);

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Commands:", 10, height - 100);
  text("Zoom In/Out (X-axis): + / -", 10, height - 80);
  text("Zoom In/Out (Y-axis): W / S", 10, height - 60);
  text("Move Up/Down: Up / Down", 10, height - 40);
  text("Reset: R", 10, height - 20);
}

void serialEvent(Serial p) {
  String line = trim(p.readStringUntil('\n'));

  if (line == null || line.length() == 0) return;

  String[] parts = split(line, ',');
  if (parts.length == 2) {
    try {
      int val1 = int(parts[0]);
      int val2 = int(parts[1]);
      buffer1[bufferIndex] = val1;
      buffer2[bufferIndex] = val2;
      bufferIndex = (bufferIndex + 1) % bufferSize;
    } catch (Exception e) {
      println("Parse error: " + line);
    }
  }
}

void keyPressed() {
  if (key == '+') {
    xScale *= 1.1; 
  } else if (key == '-') {
    xScale *= 0.9;  
  } else if (key == 'w' || key == 'W') {
    yScale *= 1.1;  
  } else if (key == 's' || key == 'S') {
    yScale *= 0.9; 
  } else if (keyCode == UP) {
    yOffset -= 10;  
  } else if (keyCode == DOWN) {
    yOffset += 10;  
  } else if (key == 'r' || key == 'R') {
    xScale = 1.0;
    yScale = 1.0;
    yOffset = 0.0;
  }
}
