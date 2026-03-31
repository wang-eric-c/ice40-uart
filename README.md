# UART Echo: Lattice iCE40 HX1K (Nandland Go Board)

The UART transmitter and receiver have been written from scratch in Verilog. Any character sent from a PC serial monitor is received by the FPGA and echoed back, so if you type 'a' the terminal should return 'a' back. 

## Hardware

- **Board:** Nandland Go Board (Lattice iCE40 HX1K, VQ100 package)
- **Clock:** 25 MHz onboard oscillator (pin 15)
- **UART RX:** Pin 73
- **UART TX:** Pin 74

## UART Settings

| Setting | Value |
|---------|-------|
| Baud rate | 9600 |
| Data bits | 8 |
| Stop bits | 1 |
| Parity | None |
| Flow control | None |

## File Structure

| File | Description |
|------|-------------|
| `top.v` | Top level — wires TX and RX together for echo |
| `tx.v` | UART transmitter with internal baud counter |
| `rx.v` | UART receiver with internal baud counter and noise rejection |
| `parts.pcf` | Pin constraints mapping signal names to physical pins |
| `clk.sdc` | Timing constraint declaring 25 MHz clock (40 ns period) |

## How It Works

**TX** has four states: IDLE, START, DATA, STOP. When `i_TX_Start` pulses high it latches the input byte and starts transmitting. Each state holds for exactly 2604 clock cycles (25 MHz / 9600 baud). Data bits are sent LSB first. The internal counter resets on every state transition so timing is always clean regardless of when transmission starts.

**RX** watches the RX line for a falling edge indicating a start bit. It waits 1302 cycles (half a bit period) to sample the center of the start bit and confirm it is not noise. It then samples each of the 8 data bits at the center of their bit periods. On a valid stop bit it pulses `o_Valid` for one clock cycle and latches the received byte to `o_RX_Data`.

**Top** connects `o_Valid` directly to `i_TX_Start` and `o_RX_Data` directly to `i_TX_Data`, creating a direct echo loop. Reset is tied low and the design runs immediately on power up.

## Building

### Requirements

- [Lattice iCEcube2](https://www.latticesemi.com/iCEcube2) — synthesis and place and route
- [Lattice Diamond Programmer](https://www.latticesemi.com/programmer) — flashing

### Steps

1. Open iCEcube2 and create a new project
   - Device: iCE40HX1K
   - Package: VQ100
2. Add all five files to the project
3. Confirm pin assignments in the Pin Planner:
   - Pin 15 → `i_Clk`
   - Pin 73 → `i_RX`
   - Pin 74 → `o_TX`
4. Run `Tool → Run All`
5. Locate the output bitstream:
```
[project]_Implmnt/sbt/outputs/bitmap/[project].bin
```
6. Flash with Diamond Programmer

## Testing

1. Plug the Go Board into your PC via USB
2. Open PuTTY or any serial monitor
3. Connect to the board's COM port with these settings:
   - Speed: 9600
   - Data bits: 8
   - Stop bits: 1
   - Parity: None
   - Flow control: None
   - Local echo: Force off
4. Type any character — it should appear back in the terminal

## Baud Rate Math

```
Clock frequency:  25,000,000 Hz
Baud rate:        9,600 bps
Cycles per bit:   25,000,000 / 9,600 = 2604
Half period:      2604 / 2 = 1302  (used by RX to sample start bit center)
```

To change baud rate update `MAX_BAUD` in both `tx.v` and `rx.v`, and update `HALF_BAUD` in `rx.v`. Both modules use parameterized values so no logic changes are needed.
