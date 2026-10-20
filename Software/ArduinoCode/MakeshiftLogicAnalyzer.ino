const uint8_t addrPins[16] = {
  22, 23, 24, 25,
  26, 27, 28, 29,
  30, 31, 32, 33,
  34, 35, 36, 37
};

const uint8_t dataPins[8] = {
  38, 39, 40, 41,
  42, 43, 44, 45
};

const uint8_t RW_PIN   = 46;
const uint8_t PHI2_PIN = 47;

uint16_t readAddress() {
  uint16_t value = 0;

  for (int i = 0; i < 16; i++) {
    if (digitalRead(addrPins[i])) {
      value |= (1 << i);
    }
  }

  return value;
}

uint8_t readData() {
  uint8_t value = 0;

  for (int i = 0; i < 8; i++) {
    if (digitalRead(dataPins[i])) {
      value |= (1 << i);
    }
  }

  return value;
}

void printBinary(uint16_t value, int bits) {
  for (int i = bits - 1; i >= 0; i--) {
    Serial.print((value >> i) & 1);
  }
}

void setup() {
  Serial.begin(115200);

  for (int i = 0; i < 16; i++) {
    pinMode(addrPins[i], INPUT);
  }

  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT);
  }

  pinMode(RW_PIN, INPUT);
  pinMode(PHI2_PIN, INPUT);
}

void loop() {

  while (digitalRead(PHI2_PIN) == LOW) {
  }

  delayMicroseconds(2);

  uint16_t address = readAddress();
  uint8_t data = readData();
  bool rw = digitalRead(RW_PIN);

  printBinary(address, 16);
  Serial.print("  ");

  printBinary(data, 8);
  Serial.print("  ");

  if (address < 0x1000) Serial.print("0");
  if (address < 0x0100) Serial.print("0");
  if (address < 0x0010) Serial.print("0");

  Serial.print(address, HEX);
  Serial.print("  ");

  if (rw)
    Serial.print("R");
  else
    Serial.print("W");

  Serial.print("  ");

  if (data < 0x10) Serial.print("0");
  Serial.println(data, HEX);

  while (digitalRead(PHI2_PIN) == HIGH) {
  }
}