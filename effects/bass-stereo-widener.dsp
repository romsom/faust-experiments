import("stdfaust.lib");

DELAY_MS_MAX = 25;
SR_MAX = 192000.0;
SR_ = min(ma.SR, SR_MAX);

// ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
// ip = si.smooth(ba.tau2pole(ipt));

cutoff = hslider("cutoff", 90.0, 0, 300, 0.01) : si.smoo : min(200) : max(1);
spread = hslider("spread", 0.5, 0, 2, 0.01) : si.smoo : +(0.0) : min(2.5) : max(0);
delay_factor = hslider("delay factor", 7.5, 0, 15, 0.01) : si.smoo : min(15) : max(0);
del = delay_factor * spread; // ms
drive = hslider("drive", 0.0, 0, 1, 0.01) : si.smoo;
mix = hslider("mix", 0.5, 0, 1, 0.01) : si.smoo;
output_gain = hslider("output gain", 0.7, 0, 1, 0.01) : si.smoo;
// split signals at cutoff
// merge to mono below

// effects in upper band
//  - spread
//  - distortion

fixed_fdel(n) = \(x).((1-a) * x@nInt + a * x@(nInt + 1))
with {
     nInt = int(n);
     a = n - nInt;
};

split(x, y) = (x : fi.lowpass(3, cutoff)), (y : fi.lowpass(3, cutoff)),
	      (x : fi.highpass(3, cutoff)), (y : fi.highpass(3, cutoff));

proc_lows = + <: _,_;

width(g) = _,_ <: *(1-g), *(g), *(g), *(1-g) :> +, -;
						
widen(d) = _,_ : _,fixed_fdel(d * SR_ / 1000) <: +, - <: +,-;
mix_widened(g) = \(s1,d1,s2,d2).(s1, d2, s2, d1) : *(g), *(1-g), *(g), *(1-g) : +, +;

proc_highs(g) = ef.cubicnl(drive, 0.2), ef.cubicnl(drive, 0.2)
					: widen(del)
					//: mix_widened(g)
					: ef.stereo_width(g) ;

mix_down(g) = \(x1,x2,x3,x4).(x1, x3, x2, x4) : *(g), *(1-g), *(g), *(1-g) : +, +;
						     
process = split : proc_lows, proc_highs(spread) : mix_down(mix) : *(output_gain), *(output_gain);
