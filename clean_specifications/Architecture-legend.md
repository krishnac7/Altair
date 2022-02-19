# Blocks in the Graph:

## Identify Execution Unit (IDEXU)
Detects if the instruction should be considered as a branch, an arithmetic
instruction, a vector instruction...

Inputs:
| Name                | Description                                        |
|---------------------|----------------------------------------------------|
| Instruction (instr) | The instruciton to decode (cf ISA for more detail) |

Outputs:
| Name       | Description                                                         |
|------------|---------------------------------------------------------------------|
| is_alu     | The instruction needs to be decoded by the ALU  decoder             |
| is_mul_div | The instruction needs to be decoded by the mul/div decoder          |
| is_bru     | The instruction is a branch                                         |
| is_lsu     | The instruction needs to be decoded by the LSU decoder              |
| is_dma     | The instruction needs to be decoded by the DMA decoder              |
| is_cmp     | The instruction needs to be decoded by the CMP decoder par of ALU#0 |
| is_efu     |                                                                     |
| is_fpu_d   |                                                                     |
| is_vfpu    |                                                                     |


## Emulated instruction (Emul register)
The first ALU can write an instruction in this register and the instruction
will be fetched next cycle

## Product and Quotient registers (P Q Registers)
Read Write (RW) by the MUL/DIV Unit
Read Only by both ALU

## Arithmetic Logic Unit (ALU)

### ALU / Accumulator (ACCU)
<https://en.wikipedia.org/wiki/Accumulator_(computing)>
Local to each ALU - Act like some kind of forwarding of result in order for the
next instruction to use it without pipeline Stall
```
; Without Accumulator
add r0,r1,r2
add r5,r0,r1 ; <- pipeline stall because result will be available only next cycle after writting back to the registers

; With Accumulator
add acc,r1,r2
add r5,acc,r1 ; no pipeline stall
```

## Loop Register (L Register)
Read by the Branch Unit (BRU) to implement `for` loops


## Register File
Contains registers
6 simultaneous read per cycle
2 simultaneous write per cycle

## Branch Unit (BRU)
Contains 3 Registers:
 - LR: Link Register: Same as in ARM cpus, contains the function's return address
 - IR: IRQ Register: contains the address Program counter returns to after an interruption handler
 - BR: Buffer register: point to different part of the program the program wants to access

## Data memory (MEM)
4 different memories can be accessed depending on the 

# Glossary
 - Pipeline Stall
 - IRQ
 - SD
 - USB
 - SATA
 - Flash memory
 - SD card
 - Disk
 - ISA
