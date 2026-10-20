// this code needs to be uploaded to an Arduino Uno
#define SHIFT_DATA 13 // 13
#define SHIFT_CLK 12 // 12
#define SHIFT_LATCH 11 // 11
#define WRITE_EN 2 // 2
int dataPins[8] = {10, 9, 8, 7, 6, 5, 4, 3}; // EEPROM data lines D0-D7
#define LED_WRITE A0
#define LED_OK A1

/*
 * Output the address bits and outputEnable signal using shift registers.
 */
void setAddress(int address, bool outputEnable) {
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, (address >> 8) | (outputEnable ? 0x00 : 0x80));
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, address);

  digitalWrite(SHIFT_LATCH, LOW);
  digitalWrite(SHIFT_LATCH, HIGH);
  digitalWrite(SHIFT_LATCH, LOW);
}

void dataPolling(int address, byte data) {
  byte lastval;
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT);
  }
  setAddress(address, true);
  lastval = readEEPROM(address);
  while (true) {
    byte cur = readEEPROM(address);
    if ((cur & 0x80) == (lastval & 0x80)){
      break;
    }
    lastval = cur;
  }
}


/*
 * Read a byte from the EEPROM at the specified address.
 */
byte readEEPROM(int address) {
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT);
  }
  setAddress(address, true);

  byte data = 0;
  for (int i = 7; i >= 0; i--) {
    data = (data << 1) + digitalRead(dataPins[i]);
  }
  return data;
}


/*
 * Write a byte to the EEPROM at the specified address.
 */
void writeEEPROM(int address, byte data) {
  digitalWrite(LED_WRITE, HIGH);
  setAddress(address, false);
  delayMicroseconds(2);
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], OUTPUT);
  }

  for (int i = 0; i < 8; i++) {
    digitalWrite(dataPins[i], data & 1);
    data = data >> 1;
  }
  digitalWrite(WRITE_EN, LOW);
  delayMicroseconds(2);
  digitalWrite(WRITE_EN, HIGH);
  dataPolling(address, data);
  digitalWrite(LED_WRITE, LOW);
}

void setup() {
  Serial.begin(57600);
  pinMode(SHIFT_DATA, OUTPUT);
  pinMode(SHIFT_CLK, OUTPUT);
  pinMode(SHIFT_LATCH, OUTPUT);
  pinMode(WRITE_EN, OUTPUT);
  digitalWrite(WRITE_EN, HIGH);
  pinMode(LED_WRITE, OUTPUT);
  pinMode(LED_OK, OUTPUT);
  digitalWrite(LED_WRITE, LOW);
  digitalWrite(LED_OK, LOW);
  Serial.println("STANDBY");
}

void loop() {
  if (Serial.available()) {
    char cmd = Serial.read();
    if (cmd == 'W') {
      while (Serial.available() < 3);
      int adr = ((int)Serial.read() << 8) | Serial.read();
      byte data = Serial.read();
      writeEEPROM(adr, data);
      Serial.write('A');
    } else if (cmd == 'R') {
      while (Serial.available() < 2);
      int adr = ((int)Serial.read() << 8) | Serial.read();
      byte data = readEEPROM(adr);
      Serial.write(data);
    } else if (cmd == 'F') {
      digitalWrite(LED_OK, HIGH);
      Serial.println("Finished");
    }
  }
}
