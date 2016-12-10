import("math.lib");
import("filter.lib");

DELAY_MS_MAX = 1000;
SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
ip = smooth(tau2pole(ipt));
// : is aggregate, read as signal flow from left to right
// smooth to remove glitches, when moving the slider, then limit, so buffer size can be inferred
t = hslider("delay time", 160, 0, DELAY_MS_MAX, 0.01) : ip : min(DELAY_MS_MAX) : max(0); // ms
a = hslider("amount", 0.35, 0, 1, 0.01) : ip; // relative amount
f = hslider("feedback", 0.75, 0, 1, 0.001) : ip; // amount of feedback

// discard util signal here
d(x) = cal(x) : \(x,y).(x)
with {
     cal(x) = (+(x), +(a * x)) ~ (sd : mux)
     with {
     	  // single delay stage, customize
     	  sd(x,y) = y@(t * SR_ / 1000);
	  // output signal, feedback signal
       	  mux = _ <: _, f*_;
    };
};

process = d, d;