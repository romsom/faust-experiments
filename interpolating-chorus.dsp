import("math.lib");
import("filter.lib");

DELAY_MS_MAX = 25;
SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
ip = smooth(tau2pole(ipt));
// : is aggregate, read as signal flow from left to right
// smooth to remove glitches, when moving the slider, then limit, so buffer size can be inferred
d = hslider("depth", 5, 0, DELAY_MS_MAX, 0.01) : ip : min(DELAY_MS_MAX) : max(0); // ms
a = hslider("amount", 0.35, 0, 1, 0.01) : ip : min(1) : max(0); // relative amount
f = hslider("feedback", 0.75, 0, 1, 0.001) : ip; // amount of feedback
s = hslider("speed", 7, 0.1, 25, 0.01) : ip : max(0.1); // hz
l = hslider("output level", 0.5, 0, 1, 0.01) : ip;

fixed_fdel(n) = \(x).((1-a) * x@nInt + a * x@(nInt + 1))
with {
     nInt = int(n);
     a = n - nInt;
};

lfo(wf, p) = p * float(arg) / nSamples : wf
with {
    nSamples = int(SR / s);
    arg = +(1) ~ \(x).( x * (x % nSamples != 0)) ;
};

// discard util signal here
c(x) = cal(x) : \(x,y).(x * l)
with {
     cal(x) = (+(x), +(a * x)) ~ (sd : mux)
     with {
     	  // single delay stage, customize
	  // a instead of d works quite well for simple controls
	  // TODO: try to adjust depth according to speed, so depth defines the derivative of lfo
	  // note: /s is too much, also prohibits to set s=0
     	  sd(x,y) = y : fixed_fdel((lfo(sin, 2*PI) + 1) / 2 * a * SR_ / 1000);
	  // output signal, feedback signal
       	  mux = _ <: _, f*_;
    };
};

process = c, c;