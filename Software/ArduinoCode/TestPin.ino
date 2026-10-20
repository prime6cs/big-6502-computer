const int CLK_PIN = 47;
const int H320_PIN = 46;

unsigned long clockCount = 0;
int lastClock = LOW;

void setup() {
  pinMode(CLK_PIN, INPUT);
  pinMode(H320_PIN, INPUT);

  Serial.begin(115200);

  Serial.println("Starting...");
}

void loop() {
  int clk = digitalRead(CLK_PIN);
  if (clk == HIGH && lastClock == LOW) {
    clockCount++;

    int h320 = digitalRead(H320_PIN);

    Serial.print("Clock: ");
    Serial.print(clockCount);
    Serial.print(" | Pin: ");
    Serial.println(h320 ? "HIGH" : "LOW");
  }

  lastClock = clk;
}