import("math.lib");
import("filter.lib");
LANCZOS_WINDOW_HALF = 15;
import("etxzat.lib");

DELAY_MS_MAX = 100;
SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
ip = smooth(tau2pole(ipt));

// TODO reduce number of parameters: fix delay (bass button to increase delay), amount
// TODO equalize parameter ranges: feedback
// TODO abstract out pitch shift amount (-> depth)
// : is aggregate, read as signal flow from left to right
// smooth to remove glitches, when moving the slider, then limit, so buffer size can be inferred
mod = hslider("mod depth", 0.35, 0, 1, 0.01) : ip : min(DELAY_MS_MAX) : max(0); // ms
del = hslider("delay", 6.57, 0, DELAY_MS_MAX, 0.01) : ip : min(DELAY_MS_MAX) : max(0); // ms
mix = hslider("mix", 0.4, 0, 1, 0.01) : ip : min(1) : max(0); // relative amount
f = hslider("feedback", 0.0, 0, 1, 0.001) : ip; // amount of feedback
s = hslider("speed", 0.32, 0.1, 25, 0.01) : ip : max(0.1); // hz
l = hslider("output level", 0.5, 0, 1, 0.01) : ip;
high_quality_enable = checkbox("high quality");

fixed_fdel(n, x) = if(high_quality_enable, x : lanczos_fixed_fdel(n), x : linear_fixed_fdel(n)) : _;

lfo(wf, p) = p * float(arg) / nSamples : wf
with {
    nSamples = int(SR / s);
    arg = +(1) ~ \(x).( x * (x % nSamples != 0)) ;
};

// TODO better algo?
// TODO filter, add noise, non-linearities
// discard util signal here
c(x) = cal(x) : \(x,y).(x)
with {
     cal(x) = (_, +(x)) ~ (sd : mux)
     with {
     	  // single delay stage, customize
	  // a instead of d works quite well for simple controls
	  // TODO: try to adjust depth according to speed, so depth defines the derivative of lfo
	  // note: /s is too much, also prohibits to set s=0
  // sd(x,y) = y : fixed_fdel(((lfo(sin, 2*PI) + 1) / 2 * mod + 1) * del * SR_ / 1000);
  sd(x,y) = y : fixed_fdel((modulation + 1) * del * SR_ / 1000)
  with {
  modulation = lfo(\(x).(1 - abs(x - 1)), 2) * 1 * mod : max(0) : min(1);
    //modulation = (lfo(sin, 2*PI) + 1) / 2 * mod;
  };
  
	  // output signal, feedback signal
       	  mux = _ <: _, *(f);
    };
};

process = *(l) <: _, c : *(1-mix), *(mix) <: +, -;
