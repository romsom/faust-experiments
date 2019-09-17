import("stdfaust.lib");

DELAY_MS_MAX = 25;
SR_MAX = 192000.0;
SR_ = min(ma.SR, SR_MAX);

max_cutoff = 3000;
cutoff = hslider("cutoff", 180.0, 0, max_cutoff, 0.01) : si.smoo : min(max_cutoff) : max(1);
order = hslider("filter order", 3, 0, 9, 2) : int;
hi_gain = hslider("high frequency gain", 1.0, 0.0, 2.0, 0.01) : si.smoo : min(2.0) : max(0);
lo_gain = hslider("low frequency gain", 1.0, 0.0, 2.0, 0.01) : si.smoo : min(2.0) : max(0);
n_inputs = 2;
// ord = hslider("filter order", 3, 1, n_orders * 2 + 1, 2) : int;
ord = 5;

split(order, x) = lo_gain * lp, hi_gain * (x - lp)
with {
  lp = x : fi.lowpass(order, cutoff);
};


process = par(j, n_inputs, split(ord)) : \(x1, x2, x3, x4).(x1, x3, x2, x4);
