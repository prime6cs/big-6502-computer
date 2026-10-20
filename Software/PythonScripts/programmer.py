import serial
import time
import os
import sys
# edit these variables to match your setup
PORT = "COM4"
BAUD = 57600
FILE = "program.bin"
SIZE = 32768
ERROR_FILE = "eeprom_read_errors.txt"

def update(cur, res):
    percent = (cur/res)*100
    print(f"\rAddress: {cur}/{res} " f"({percent:.1f}%)", end="", flush=True)

def respond(ser):
    response = ser.read(1)

    if response == b'A':
        return True
    return False
        
with open(FILE, "rb") as f:
    data = bytearray(f.read())

if len(data) > SIZE:
    print(f"Error: File size exceeds {SIZE} bytes of EEPROM.")
    sys.exit()

data += bytes([0xFF]*(SIZE-len(data)))
print("Opening serial port...")
ser = serial.Serial(PORT, BAUD, timeout=2)
time.sleep(2)
ser.reset_input_buffer()
ser.reset_output_buffer()
with open(ERROR_FILE, "w") as error_file:
    error_file.write("EEPROM READ ERRORS\n")
    error_file.write("==================\n")
    error_file.write(
        "Address    Expected    Got\n"
    )
    error_file.write(
        "--------------------------\n"
    )
read_errors = 0
write_errors = 0
start = time.perf_counter()
print("Writing:")
for adr, val in enumerate(data):
    send = bytes([
        ord('W'),
        (adr >> 8) & 0xFF,
        adr & 0xFF,
        val
    ])
    ser.write(send)
    time.sleep(0.01)
    if not respond(ser):
        write_errors += 1

        print(
            f"\nWrite error at address: {hex(adr)}"
        )
    read = bytes([
        ord('R'),
        (adr >> 8) & 0xFF,
        adr & 0xFF
    ])
    ser.write(read)
    got = ser.read(1)
    if len(got) == 0:
        # No byte received at all
        read_errors += 1
        with open(ERROR_FILE, "a") as error_file:
            error_file.write(
                f"${adr:04X}       ${val:02X}        TIMEOUT\n"
            )
    elif got != bytes([val]):
        # Wrong byte received
        read_errors += 1
        got_val = got[0]
        with open(ERROR_FILE, "a") as error_file:
            error_file.write(
                f"${adr:04X}       ${val:02X}        ${got_val:02X}\n"
            )
    update(adr + 1, SIZE)
end = time.perf_counter()
print(
    f"\n\nWrite + verification complete in: "
    f"{end - start:.2f} seconds."
)
print(f"Write errors: {write_errors}")
print(f"Read errors:  {read_errors}")
if read_errors > 0:
    print(
        f"\nRead errors were saved to: {ERROR_FILE}"
    )
else:
    print("\nNo read errors detected!")
ser.write(b'F')
ser.close()