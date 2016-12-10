import("math.lib");
import("filter.lib");

DELAY_MS_MAX = 15;
SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

ipt = hslider("smooth_time", 0.001, 0, 0.1, 0.0001); // s
ip = smooth(tau2pole(ipt));
// : is aggregate, read as signal flow from left to right
// smooth to remove glitches, when moving the slider, then limit, so buffer size can be inferred
t = hslider("delay time", 10, 0, DELAY_MS_MAX, 0.01) : ip : min(DELAY_MS_MAX) : max(0); // ms
a = hslider("amount", 0.2, 0, 1, 0.01) : ip; // relative amount
f = hslider("feedback", 0.01, 0, 1, 0.001) : ip; // amount of feedback
// ~ feeds output, buffered by 1 sample modified with following function to input
d(x) = + (x / 2.0) ~ f * a * _@(t * SR_ / 1000);
// , means process in parallel
process = d, d;