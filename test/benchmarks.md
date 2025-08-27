Benchmarking `kim_api.jl` using KIMNeighbourList.jl

used potential: SW StillingerWeber si from OpenKIM

Outputs of the Julia Benchmarking script `benchmark.jl`:

```
# Using KIMNeighbourList.jl
============================================================
Benchmarking: SW_StillingerWeber_1985_Si__MO_405512056662_006
============================================================

Small System (2 atoms):
BenchmarkTools.Trial: 10000 samples with 1 evaluation per sample.
 Range (min … max):  368.142 μs …  1.313 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     377.730 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   393.702 μs ± 73.158 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▇█▅▄▃▁            ▁▂▁                                        ▂
  ███████▇▅▆▅▅▅▆▆▆▅▄███▆▆▄▄▄▄▅▅▃▄▄▄▅▆▆▅▄▄▅▅▄▄▁▄▅▃▄▄▃▃▃▃▃▃▁▃▁▁▄ █
  368 μs        Histogram: log(frequency) by time       870 μs <

 Memory estimate: 4.86 KiB, allocs estimate: 140.

Medium System (64 atoms):
BenchmarkTools.Trial: 8268 samples with 1 evaluation per sample.
 Range (min … max):  550.214 μs …  19.087 ms  ┊ GC (min … max): 0.00% … 61.73%
 Time  (median):     562.618 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   601.827 μs ± 499.222 μs  ┊ GC (mean ± σ):  1.70% ±  2.03%

  ██▅▄▃▂▁    ▁▂▁                                                ▂
  ████████▇▆▇████▇▇▇▆▇▆▆▆▇▆▆▆▅▅▄▅▄▁▅▄▄▅▃▄▁▄▃▃▃▃▁▁▁▃▁▁▁▁▃▁▃▄▄▁▃▄ █
  550 μs        Histogram: log(frequency) by time       1.23 ms <

 Memory estimate: 91.62 KiB, allocs estimate: 2622.

Large System (512 atoms):
BenchmarkTools.Trial: 2242 samples with 1 evaluation per sample.
 Range (min … max):  2.012 ms … 14.565 ms  ┊ GC (min … max): 0.00% … 51.13%
 Time  (median):     2.056 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.228 ms ±  1.080 ms  ┊ GC (mean ± σ):  3.40% ±  5.91%

  █▃                                                          
  ███▆▅▄▅▅▄▃▁▃▁▁▄▅▁▃▁▄▄▄▅▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▃▁▁▁▁▅▃▅▅ █
  2.01 ms      Histogram: log(frequency) by time     9.74 ms <

 Memory estimate: 722.02 KiB, allocs estimate: 20568.

# Using NeighbourLists.jl

Small System (2 atoms):
BenchmarkTools.Trial: 10000 samples with 1 evaluation per sample.
 Range (min … max):  402.847 μs …  15.943 ms  ┊ GC (min … max): 0.00% … 74.70%
 Time  (median):     413.772 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   434.864 μs ± 177.882 μs  ┊ GC (mean ± σ):  0.27% ±  0.75%

  ██▅▄▂▁        ▁▂▁                                             ▂
  ██████▇▇▆▇█▆▆▇████▇▆▆▅▆▄▆▅▅▅▅▅▆▄▅▃▅▅▄▄▃▅▄▄▄▄▄▄▃▃▅▃▃▁▃▄▄▁▃▃▁▅▆ █
  403 μs        Histogram: log(frequency) by time       1.01 ms <

 Memory estimate: 13.27 KiB, allocs estimate: 302.

Medium System (64 atoms):
BenchmarkTools.Trial: 4551 samples with 1 evaluation per sample.
 Range (min … max):  991.975 μs …   9.134 ms  ┊ GC (min … max): 0.00% … 81.27%
 Time  (median):       1.020 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):     1.095 ms ± 368.052 μs  ┊ GC (mean ± σ):  3.17% ±  8.07%

  █▇▄▄▃▁▁▁                                                      ▁
  ██████████▆▆▅▃▄▃▄▁▃▃▄▃▁▁▃▁▃▃▁▁▃▁▁▃▅▃▁▁▃▄▃▅▁▅▃▅▄▅▅▆▆▅▆▆▆▆▅▆▅▄▅ █
  992 μs        Histogram: log(frequency) by time       2.72 ms <

 Memory estimate: 438.48 KiB, allocs estimate: 7431.

Large System (512 atoms):
BenchmarkTools.Trial: 1214 samples with 1 evaluation per sample.
 Range (min … max):  3.764 ms …  12.489 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     3.839 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.117 ms ± 779.840 μs  ┊ GC (mean ± σ):  4.65% ± 8.84%

  █▇▃▁           ▁▂▂ ▁                                         
  ██████▆▆▄▄▄▁▁▄▇█████▇▅▆▆▄▆▆▆▄▄▆▁▁▁▆▄▄▄▁▄▄▄▁▁▁▁▁▄▁▄▁▁▁▁▁▁▁▄▄ █
  3.76 ms      Histogram: log(frequency) by time      7.83 ms <

 Memory estimate: 2.58 MiB, allocs estimate: 42292.
 ```
