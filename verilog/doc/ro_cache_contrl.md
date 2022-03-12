# 4-way set-associative read-only cache

Verilog file: [../src/ro_cache_contrl.sv](../src/ro_cache_contrl.sv)


Parameters:
- `SET_ASSOCIATIVITY`: Number of way for the cache, 4
- `INSTR_SIZE`: Size of one instruciton in bit, 1 instruction = 4B = 32 bits
- `ADDR_LENGTH`: Length of the address, 32 bits
- `ADDRESSING_MODE`: (also called read line / read block)
  How many bits an address is indexing, we are indexing instructions = `INSTR_SIZE`
- `WRITE_LINE_SIZE`: (also called write block)
  How many bits we write at the same time (aka write line), 1024B= 8192 bits
- `CACHE_SIZE`: How many bits of information (instructions) does the cache
  contains, tags do not count, 64KB = 524288 bits
- `BITS_TO_ADDR_CACHE_SIZE`: How many bits do we need to index a cache of size
  `CACHE_SIZE` with a 'granularity' of `ADDRESSING_MODE`?
  `log2(CACHE_SIZE / (SET_ASSOCIATIVITY*ADDRESSING_MODE)) = 12 bits`

- `BITS_TO_ADDR_A_LINE`: How many bits do we need to addres a single cache line?
  `log2(CACHE_SIZE / ADDRESSING_MODE) = 8 bits`

- `TAG_LENGTH`: Number of bits in a tag, `ADDR_LENGTH - BITS_TO_ADDR_CACHE_SIZE = 20`
- `MMU_WRITE_LENGTH`: how many bits does the Memory Management Unit (MMU) can
  write in a single clock single to the cache, 32 bits here

Note: You have `CACHE_SIZE / ADDRESSING_MODE` 'items' in your cache, in our
  example 16384 instructions

Note: You would need `log2(16384) = 14 bits` to index all the instructions
  but we have with a 4 way cache -> the instructions are grouped by 4 therefore
  you need `log2(16384/4) = 12 bits = BITS_TO_ADDR_CACHE_SIZE`
  Each "Main memory" contains `(16384/4) / 2 = 2048 columns`

Note: You have `CACHE_SIZE / WRITE_LINE_SIZE` write lines in your cache,
  64 lines is our example, you have as many tags since 1 tag give you
  information about 1 line. You can see the overhead diminishing with the write
  cache line increasing. Since this is a 4-way set-associative cache (aka 4
  cache lines are grouped together to be a make a single entry) you need
  `log2(64/4) = 4 bits` to index the "Tag memory".
  The "Tag memory" only contains `64/16 = 4 columns`


## Cache controller for a dual bank 4 way set-associative read-only instruction cache

The cache make use of 3 memories (aka 3 banks):
- Tag memory
- Main memory for instruction 0
- Main memory for instruction 1

```
i_addr[BITS_TO_ADDR_CACHE_SIZE-1 : BITS_TO_ADDR_A_LINE] (cf [1])
  |
  |        ** Tag memory **
  v     Way0     Way1     Way2     Way3
 0x0     TAG      TAG      TAG      TAG
 ...    ...      ...      ...      ...
 0x3     TAG      TAG      TAG      TAG
          |        |        |        |
          |        |        |        |      i_addr[?:?]
          |        |        |        |         v
          \--------------------------------> COMPARE ---> {HIT/MISS, way#}

addr_bank0 = (i_addr[0] == 0)? i_addr[?:?]: i_addr[?:?]+1 (cf [1])
   |       ** Main memory - bank 0 **
   v    Way0     Way1     Way2     Way3
  0x0  4B instr 4B instr 4B instr 4B instr
  0x1  4B instr 4B instr 4B instr 4B instr
  ...
  0x?  4B instr 4B instr 4B instr 4B instr
          |        |        |        |
          v        v        v        v
          =========== MUX =========== <- way#
                       |
                       v
                   int_intr_b0

addr_bank1 = (i_addr[0] == 1)? i_addr[?:?]: i_addr[?:?]+1 (cf [1])
   |
   |       ** Main memory - bank 1 **
   v    Way0     Way1     Way2     Way3
  0x0  4B instr 4B instr 4B instr 4B instr
  0x1  4B instr 4B instr 4B instr 4B instr
  ...
  0x?  4B instr 4B instr 4B instr 4B instr
          |        |        |        |
          v        v        v        v
          =========== MUX =========== <- way#
                       |
                       v
                   int_intr_b1

?:? is BITS_TO_ADDR_CACHE_SIZE-1:1
```

Having the Tags in a separate memory results in two different modes:
- Performance: We fetch all caches in parallel, once we know if we have a cache
  miss or hit (tag comparison) we can select the way (via multiplexing) or
  discard the fetched data (if miss) (1 cycle in the current implementation)
- Power saving: We fetch the Main datas only if we have a cache hit. (it would
  take 2 cycles in the current implementation)

[1] The Branch Unit will ask to fetch `i_addr`, both the instruction at `i_addr`
and `i_addr+1` will be fetched. The fetch which address is even will be on bank
0 and it's result will be `instr_0` (instruction 0) the fetch which address is
odd will be on bank 1 and results in `instr_1`.
First if `i_addr` is a cache hit it's pairing bit [2] is checked.
If `i_addr` and `i_addr+1` are on the same cache lines (write lines/write
blocks) then `instr_1` can be fetched together with `instr_0` without extra cost
else `cache_line_crossing` is set and an extra cycle will be required to check
the tag of the other line is `instr_0`'s pairing bit requires `intr_1` to be
fetched together with `intr_1`.

[2] "pairing bit" a bit in the instruction which indication if the next
inxtruction (`i_addr+1`) should be fetched together with this one.

[3] On a cache miss:
- the processor will be stalled, it will take
  `ICACHE_FILL_LATENCY+WRITE_LINE_SIZE/MMU_WRITE_LENGTH` cycles to get a new line
  in the cache
TODO: we could resume fetching as soon as the missing cache line arrives with
little extra logic (and a dual port RAM instead of a single port one)
- if both `addr_bank0` and `addr_bank1` are misses it will takes
  `ICACHE_FILL_LATENCY+2*WRITE_LINE_SIZE/MMU_WRITE_LENGTH` (note the
  `ICACHE_FILL_LATENCY` is constant)

`ICACHE_FILL_LATENCY` is the latency it takes to fetch a new line from the MMU it
varies depending on the avaibility of the underlaying memories...

## Tags and replacement policy
TODO Add information about the Least-recently used (LRU) replacement policy

TODO Add information about the tag structure
```
    1 bit                      20 bits                                ?
VALID/INVALID   ADDRESS[ADDR_LENGTH-1:BITS_TO_ADDR_CACHE_SIZE]   LRU_COUNTER
```
