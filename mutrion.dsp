import("instrument.lib");
import("math.lib");
import("filter.lib");

SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);
ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
ip = smooth(tau2pole(ipt));

peak = hslider("peak", 1, 0, 10, 0.01) : ip;
gain = hslider("gain", 1, 0, 100, 0.01) : ip;
cutoff = hslider("cutoff", 450, 0, 10000, 0.1) : ip;
// R_charge * C = 330 * 4.7u = 0.001551
ta = hslider("env attack", 0.0015, 0, 0.1, 0.0005) : ip;
// R_discharge * C = 47k * 4.7u = 0.2209
td = hslider("env decay", 0.22, 0, 0.5, 0.01) : ip;

/*
env = fabs(_) : fil
with {
     fil(x) = \(fb).(max(x, fb) : \(y).((fb < x) * lowpass(1, 1/ta, y) + (fb >= x) * highpass(1, 1/tf, y))) ~ _;
};
*/
m(x) = x : resonlp(cutoff * (1.0 + gain * sqrt(amp_follower_ud(ta, td, x))), peak, 1);

process = m, m;