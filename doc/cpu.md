## Memory Barriers

Ref: https://www.kernel.org/doc/Documentation/memory-barriers.txt

Memory barriers are only required where there's a possibility of interaction
between two CPUs or between a CPU and a device.  If it can be guaranteed that
there won't be any such interaction in any particular piece of code, then
memory barriers are unnecessary in that piece of code.

## MMU

https://nieyong.github.io/wiki_cpu/CPU%E4%BD%93%E7%B3%BB%E6%9E%B6%E6%9E%84-MMU.html
https://en.wikipedia.org/wiki/Memory_management_unit

## How to get endianness on linux system?

```
lscpu | grep Endian
```
