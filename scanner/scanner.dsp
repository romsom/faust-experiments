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
depth = nentry("depth", 2, 0, 2, 1) : min(0) : max(2) : int;
chorus_enable = checkbox("chorus");

// util functions
fixed_fdel(n) = \(x).((1-a) * x@nInt + a * x@(nInt + 1))
with {
     nInt = int(n);
     a = n - nInt;
};

//lfo(wf, p) = float(arg) / nSamples : wf : *(p)
lfo(wf, p) = p * float(arg) / nSamples : wf
with {
    nSamples = int(SR / s);
    arg = +(1) ~ \(x).( x * (x % nSamples != 0)) ;
};

// shifted 'hat' functions with width 2, amplitude 1
segment(n, i, phase) = max(0, 1 - abs(phase - i)) + max(0, 1 - abs(phase - (n + i))) : min(1);

scanner2(x1, x2) = crossfade * x1 + (1 - crossfade) * x2
with {
    // triangle lfo
    crossfade = lfo(\(x).(0.5 - abs(x - 0.5)), 1);
};
     
scanner3(x1, x2, x3) = c1*x1 + c2*x2 + c3*x3
with {
    
    phase = lfo(\(x).(x/3),3); // sawtooth lfo

	  c1 = segment(3, 0, phase);
	  c2 = segment(3, 1, phase);
	  c3 = segment(3, 2, phase);
 };
      

scanner9(morph, x1, x2, x3, x4, x5, x6, x7, x8, x9) = c1*x1 + c2*x2 + c3*x3 + c4*x4 + c5*x5 + c6*x6 + c7*x7 + c8*x8 + c9*x9
with {
    p = lfo(\(x).(9 - abs(x - 9)), 18);
    //p = lfo(_, n);
    //p = lfo(\(x).(8 - abs(x - 8)), 18); // triangle lfo, 
    c1 = segment(9, 0, p) : morph;
    c2 = segment(9, 1, p) : morph;
    c3 = segment(9, 2, p) : morph;
    c4 = segment(9, 3, p) : morph;
    c5 = segment(9, 4, p) : morph;
    c6 = segment(9, 5, p) : morph;
    c7 = segment(9, 6, p) : morph;
    c8 = segment(9, 7, p) : morph;
    c9 = segment(9, 8, p) : morph;
};

scanner(n, morph) = par(i, n, c(n, i) * _) :> _
with {
  p = lfo(\(x).(n - abs(x - n)), 2*n);
  c(n, i) = segment(n, i, p) : morph;
};

hammond_delay_per_stage = 520.0 / 18.0;

// delay stages for console hammond organs:
// stage(0, 0) = 0;
// stage(0, 1) = 1;
// stage(0, 2) = 2;
// stage(0, 3) = 3;
// stage(0, 4) = 4;
// stage(0, 5) = 5;
// stage(0, 6) = 6;
// stage(0, 7) = 7;
// stage(0, 8) = 8;

// stage(1, 0) = 0;
// stage(1, 1) = 1;
// stage(1, 2) = 2;
// stage(1, 3) = 4;
// stage(1, 4) = 6;
// stage(1, 5) = 8;
// stage(1, 6) = 9;
// stage(1, 7) = 10;
// stage(1, 8) = 12;

// stage(2, 0) = 0;
// stage(2, 1) = 1;
// stage(2, 2) = 3;
// stage(2, 3) = 6;
// stage(2, 4) = 11;
// stage(2, 5) = 12;
// stage(2, 6) = 15;
// stage(2, 7) = 17;
// stage(2, 8) = 18;

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
//stage(depth, n) = case { (0) => stage(0, n)

// delay stages for spinet hammond organs:
  /*
  {3, 4, 5, 6, 7, 8, 9, 10, 11},
  {3, 4, 5, 7, 9, 11, 12, 13, 15},
  {3, 4, 6, 9, 14, 15, 16, 17, 18}
  */


//process = 0, 1/7, 2/7, 3/7, 4/7, 5/7, 6/7, 1  : scanner8(plateau(pl));
//process = 1, 0, 0, 0, 0, 0, 0, 0  : scanner8(plateau(pl));
//process = scanner8(plateau(pl));
process = _ <: (_ <: par(i, 9, fixed_fdel(delay_per_stage_samples * stage(depth, i))) : scanner(9, plateau(pl))), *(chorus_enable) :> /(1.0 + chorus_enable)
with {
  // it's a really fun delay if you divide only by 1000.0 ;)
  delay_per_stage_samples = hammond_delay_per_stage * SR_ / 1000000.0;
};
