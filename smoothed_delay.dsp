import("math.lib");
import("filter.lib");


SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

ipt = hslider("smooth_time", 0.001, 0, 0.1, 0.0001); // s
ip = smooth(tau2pole(ipt));
// : is aggregate, read as signal flow from left to right
// smooth to remove glitches, when moving the slider, then limit, so buffer size can be inferred
t = hslider("delay time", 10, 0, 1000, 0.1) : ip : min(1000) : max(0); // ms
a = hslider("amount", 0, 0, 1, 0.01) : ip; // relative amount
// normal infix syntax also works, x@n delays the signal x by n samples
d(x) =  (1-a) * x + a * x@(t * SR_ / 1000);
// , means process in parallel
process = d, d;