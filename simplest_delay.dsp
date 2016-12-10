import("math.lib");


SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);

t = hslider("delay time", 10, 0, 1000, 0.1); // ms
a = hslider("amount", 0, 0, 1, 0.01); // relative amount
// normal infix syntax also works, x@n delays the signal x by n samples
d(x) =  (1-a) * x + a * x@(t * SR_ / 1000);

process = d, d;