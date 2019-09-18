import("math.lib");
import("filter.lib");

SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);
//STAGE_DELAY = 

// TODO:
//  - delay line
//  - different transistion functions
//  - scan freq from midi note

plateau(ratio_in) = f : ((_ - (ratio / 2)) / (1 - ratio))
with {
    ratio = min(ratio_in, 0.9);
    f = min(1 - (ratio / 2)) : max(ratio / 2);
};

ipt = 0.05; // interpolation time in s
ip = smooth(tau2pole(ipt));

// controls
s = hslider("speed", 7, 0.05, 20, 0.1) : ip : max(0.1); // hz
pl = hslider("plateau", 0, 0, 1, 0.01) : ip : min(1);
depth = nentry("depth", 3, 1, 3, 1) : int : -(1);
chorus_enable = checkbox("chorus");
delay_enable = checkbox("delay");

// util functions
// delay in samples (possibly non-integer, linearly interpolating)
fixed_fdel(n) = \(x).((1-a) * x@nInt + a * x@(nInt + 1))
with {
     nInt = int(n);
     a = n - nInt;
};

// wf: waveform, for values in [0, 1]
// p: scaling factor
lfo(wf, p) = float(arg) / nSamples : wf : *(p)
with {
    nSamples = int(SR / s);
    arg = +(1) ~ \(x).( x * (x % nSamples != 0)) ;
};

// shifted 'hat' functions with width 2, amplitude 1
segment(n, i, phase) = max(0, 1 - abs(phase - i)) + max(0, 1 - abs(phase - (n + i))) : min(1);

scanner(n, morph) = par(i, n, c(n, i) * _) :> _
with {
  p = lfo(\(x).(0.5 - abs(x - 0.5)), 2*(n-1));
  c(n, i) = segment(n, i, p) : morph;
};

hammond_delay_per_stage = 520.0 / 18.0;

// delay stages for console hammond organs:

// This is a flat list of numbers of delay stages
// Actually this would be a list of 3 lists of 9 integer values each
// but it seems faust can't do that.
// Adjust the number of assumed elements in stage_ if you change them here:
stages = 
  (0, 1, 2, 3, 4, 5, 6, 7, 8,
   0, 1, 2, 4, 6, 8, 9, 10, 12,
   0, 1, 3, 6, 11, 12, 15, 17, 18);

// I would really like to have proper list types in faust...
stage_(depth, n) = take(n+1, subseq(stages, 9*depth, 9));
stage(depth, n) = if(depth == 0, stage_(0, n), if(depth == 1, stage_(1, n), if(depth == 2, stage_(2, n), 0)));

// delay stages for spinet hammond organs:
  /*
  {3, 4, 5, 6, 7, 8, 9, 10, 11},
  {3, 4, 5, 7, 9, 11, 12, 13, 15},
  {3, 4, 6, 9, 14, 15, 16, 17, 18}
  */


process = _ <: (_ <: par(i, 9, fixed_fdel(delay_per_stage_samples * stage(depth, i))) : scanner(9, plateau(pl))), *(chorus_enable) :> /(1.0 + chorus_enable)
with {
  // it's a really fun delay if you divide only by 1000.0 ;)
  delay_per_stage_samples = hammond_delay_per_stage * SR_ / (if(delay_enable > 0.0, 1.0, 1000.0) * 1000.0);
};

// silent switch that waits until the two signals cross
// silent_switch(select_x, x, y) = \(a, b).(if(select_x && has_settled, a, b)) ~
// 				\(x, y, select_x, have_crossed, change).(x, y, _, 
