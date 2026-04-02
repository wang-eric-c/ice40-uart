# iCE40 UART 7-Segment Display

A Verilog project for the Lattice iCE40 FPGA that receives a digit character over UART, echoes it back over UART, and displays it on a 7-segment display.

---

## How It Works

1. A digit character (`'0'`–`'9'`) is sent to the FPGA over UART from a host (e.g. a serial terminal).
2. The UART RX module receives the byte and asserts a valid signal.
3. The received byte is echoed back immediately via the UART TX module.
4. If the byte is an ASCII digit, the 7-segment display module decodes it and drives the display accordingly.

```
Host PC
  │
  │  UART (9600 baud, 8N1)
  ▼
┌─────────────────────────────────┐
│  iCE40 FPGA                     │
│                                 │
│  UART_RX ──► Seg7 ──► Display  │
│      │                          │
│      └──► UART_TX ──► Host PC  │
└─────────────────────────────────┘
```

---

## File Structure

| File | Description |
|------|-------------|
| `top.v` | Top-level module — wires RX, TX, and 7-segment together |
| `rx.v` | UART receiver — 4-state FSM (IDLE, START, DATA, STOP) |
| `tx.v` | UART transmitter — 4-state FSM (IDLE, START, DATA, STOP) |
| `seg7.v` | 7-segment decoder — maps nibble `0x0`–`0x9` to segment pattern |
| `parts.pcf` | Pin constraint file for the iCE40 target board |
| `clk.sdc` | Timing constraint — 25 MHz clock (40 ns period) |

---

## UART Configuration

| Parameter | Value |
|-----------|-------|
| Baud rate | 9600 |
| Clock frequency | 25 MHz |
| Data bits | 8 |
| Parity | None |
| Stop bits | 1 |
| Baud divider (`MAX_BAUD`) | 2604 |

The baud divider is calculated as: `Clock Frequency / Baud Rate = 25,000,000 / 9600 ≈ 2604`

---

## Pin Assignments

| Signal | Pin | Description |
|--------|-----|-------------|
| `i_Clk` | 15 | 25 MHz clock input |
| `i_RX` | 73 | UART receive line |
| `o_TX` | 74 | UART transmit line |
| `o_Segment1_A` | 2 | Segment A |
| `o_Segment1_B` | 1 | Segment B |
| `o_Segment1_C` | 90 | Segment C |
| `o_Segment1_D` | 91 | Segment D |
| `o_Segment1_E` | 93 | Segment E |
| `o_Segment1_F` | 4 | Segment F |
| `o_Segment1_G` | 3 | Segment G |

---

## 7-Segment Encoding

Segments are active-low (`0` = on, `1` = off). The display order in the output wire is `{A, B, C, D, E, F, G}`.

```
 _
|_|
|_|

A = top
B = top-right
C = bottom-right
D = bottom
E = bottom-left
F = top-left
G = middle
```

Only ASCII digits `'0'` (0x30) through `'9'` (0x39) will update the display. Any other character is ignored by the Seg7 module (though it will still be echoed back over TX).

---

## Reset Behavior

The design uses a soft power-on reset. A 4-bit counter increments on every clock cycle after power-up, and the reset signal is deasserted once the counter reaches 8 (bit 3 goes high). This ensures all modules start in a clean state.

---

## Build (iCEcube2)

1. Open iCEcube2 and create a new project targeting your iCE40 device.
2. Add `top.v`, `rx.v`, `tx.v`, and `seg7.v` as source files.
3. Set `parts.pcf` as the pin constraint file.
4. Set `clk.sdc` as the timing constraint file.
5. Run synthesis, place-and-route, and bitstream generation.
6. Program the device using the iCEcube2 programmer or `iceprog`.

---

## Usage

1. Connect the board to your PC via a USB-to-serial adapter.
2. Open a serial terminal (e.g. PuTTY, minicom, or the Arduino Serial Monitor) at **9600 baud, 8N1**.
3. Type any digit key (`0`–`9`).
4. The digit will appear on the 7-segment display and be echoed back in the terminal.
