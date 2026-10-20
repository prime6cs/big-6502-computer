import serial
import time

PORT = "COM4"
BAUD = 57600

ser = serial.Serial(PORT, BAUD, timeout=2)

# Allow Arduino Uno reset
time.sleep(2)

# Clear old messages
ser.reset_input_buffer()
ser.reset_output_buffer()

print("Connected")
print("Commands:")
print("  W HH LL DD   (write)")
print("  R HH LL      (read)")
print("  Q            (quit)")


def write_byte(addr, data):
    packet = bytes([
        ord('W'),
        (addr >> 8) & 0xFF,
        addr & 0xFF,
        data
    ])

    ser.write(packet)

    while True:
        response = ser.read(1)

        if response == b'A':
            print("Write OK")
            return

        if response == b'':
            print("Write timeout")
            return


def read_byte(addr):

    packet = bytes([
        ord('R'),
        (addr >> 8) & 0xFF,
        addr & 0xFF
    ])

    ser.write(packet)

    value = ser.read(1)

    if value:
        print("Read:", hex(value[0]))
    else:
        print("Read timeout")


while True:

    cmd = input("> ").strip().upper()

    if cmd == "Q":
        break

    parts = cmd.split()

    try:

        if parts[0] == "W" and len(parts) == 4:

            address = (int(parts[1],16) << 8) | int(parts[2],16)
            data = int(parts[3],16)

            print(
                "Writing address",
                hex(address),
                "data",
                hex(data)
            )

            write_byte(address,data)


        elif parts[0] == "R" and len(parts) == 3:

            address = (int(parts[1],16) << 8) | int(parts[2],16)

            print(
                "Reading address",
                hex(address)
            )

            read_byte(address)


        else:
            print("Invalid command")

    except Exception as e:
        print("Error:", e)


ser.close()