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

// util functions
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
      

scanner8(morph, x1, x2, x3, x4, x5, x6, x7, x8) = c1*x1 + c2*x2 + c3*x3 + c4*x4 + c5*x5 + c6*x6 + c7*x7 + c8*x8
with {
    p = lfo(_, 8);
    //p = lfo(\(x).(8 - abs(x - 8)), 16); // triangle lfo, 
    c1 = segment(8, 0, p) : morph;
    c2 = segment(8, 1, p) : morph;
    c3 = segment(8, 2, p) : morph;
    c4 = segment(8, 3, p) : morph;
    c5 = segment(8, 4, p) : morph;
    c6 = segment(8, 5, p) : morph;
    c7 = segment(8, 6, p) : morph;
    c8 = segment(8, 7, p) : morph;
};

//hammond_delayline(stage_del) = 

//process = 0, 1/7, 2/7, 3/7, 4/7, 5/7, 6/7, 1  : scanner8(plateau(pl));
//process = 1, 0, 0, 0, 0, 0, 0, 0  : scanner8(plateau(pl));
process = scanner8(plateau(pl));
