# Blocks in the Graph:

The full block diagram in inside <./doc/Architecture.odg> (LibreOffice Draw document)

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

# Memory access pattern
<https://en.wikipedia.org/wiki/Memory_access_pattern>
keywords: Random Access, RAM, Gather, Scatter, Strided

# Sound Interface - SIF
Directly connected to the RAM.

> Helba:
> No need for dedicated memory here, it is 44KHz x16 channels x 2 (stereo) x 2B
> (PCM) => 3MB/s
> DDR3 1600 is expected to have a throughput of 12Go/s
> With a clock of 88KHz it is 10000ns per cycle (DDR latency is 14ns + 1 for
> burst).

# Learning resources

## Caches
To learn more about CPU caching:
 - General description of CPU caches: <https://en.wikipedia.org/wiki/CPU_cache>

Keywords: cache enties, cache line, cache block, cache hit, cache miss, 
replacement policies (least-recently used (LRU)), non-cacheable memory ranges,
write policies (write-through, write-back, copy-back, dirty bit, store data queue,
cache coherence policies), associativity (placement policy, fully associative,
direct-mapped, N-way set associative, speculative execution, skewed cache,
pseudo-associative cache, content-addressable memory, hash-rehash cache,
column-associative cache), cache entry (tag, data block flab bits), virtual memory (address translation, memory management unit (MMU), translation lookaside buffer (TLB), page table, segment table, virtual addresses aliasing, granularity, page sizes)... Page coloring, victim cache, trace cache, branch target instruction cache. Inclusive/Exclusive caches, Separate/Unified caches, scratchpad memory (SPM)
 - <https://en.wikipedia.org/wiki/Cache_replacement_policies>
 - <https://en.wikipedia.org/wiki/Page_replacement_algorithm>
 - <https://www.d.umn.edu/~gshute/arch/cache-addressing.xhtml>
 - Cache placement policies: <https://en.wikipedia.org/wiki/Cache_placement_policies>


Caches can contain error correction code: <https://en.wikipedia.org/wiki/ECC_memory#cache>

## Direct mapped caches
 - Direct-mapped (no replacement policy)
 - Skewed (good hash function: TODO )

## Branch target instruction cache

## Other recommanded reading:
 - <https://en.wikipedia.org/wiki/Content-addressable_memory>
 - Computer architecture a quantitative approach.
Keywords: Sequential consistency (SC), release consistency (RC), store order (PSO), Total store order (TSO)
 - CMSO VLSI design, A circuits and systems perspective by Weste and Harris. 
