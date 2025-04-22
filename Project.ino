const int ch1Pin = A0;
const int ch2Pin = A1;
const int toggleCh1Pin = 4;    // Used for switch 1 to toggle A0 monitoring
const int toggleCh2Pin = 1;    // Used for switch 2 to toggle A1 monitoring
const int LED_CH1 = 6;         // LED used to display A0 activity
const int LED_CH2 = 5;         // LED used to display A1 activity

bool prevCh1BtnState = HIGH; // Used to convert button to switch
bool prevCh2BtnState = HIGH; // Used to convert button to switch
bool ch1Enabled = false;
bool ch2Enabled = false;

void setup() {
  Serial.begin(115200);

  pinMode(toggleCh1Pin, INPUT_PULLUP);
  pinMode(toggleCh2Pin, INPUT_PULLUP);
  pinMode(LED_CH1, OUTPUT);
  pinMode(LED_CH2, OUTPUT);
}

void loop() {
  bool ch1BtnState = digitalRead(toggleCh1Pin);
  if (ch1BtnState == LOW && prevCh1BtnState == HIGH) {
    delay(50); 
    ch1Enabled = !ch1Enabled;
  }
  prevCh1BtnState = ch1BtnState;

  bool ch2BtnState = digitalRead(toggleCh2Pin);
  if (ch2BtnState == LOW && prevCh2BtnState == HIGH) {
    delay(50);
    ch2Enabled = !ch2Enabled;
  }
  prevCh2BtnState = ch2BtnState;

  int ch1 = ch1Enabled ? analogRead(ch1Pin) : 0;
  int ch2 = ch2Enabled ? analogRead(ch2Pin) : 0;
  Serial.print(ch1);
  Serial.print(",");
  Serial.println(ch2);

  digitalWrite(LED_CH1, ch1 > 50 ? HIGH : LOW);
  digitalWrite(LED_CH2, ch2 > 50 ? HIGH : LOW);

  delay(10);
}
