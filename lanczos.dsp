import("math.lib");
import("filter.lib");
LANCZOS_WINDOW_HALF = 5;
import("etxzat.lib");

// TODO Unstetigkeiten bei 0.40 -> 0.41, 0.59 -> 0.60, 0.99 -> 1.00, Überdeckung bei window könnte eine Ursache sein

SR_MAX = 192000.0;
SR_ = min(SR, SR_MAX);
ip = smooth(tau2pole(0.05));

MAX_DELAY = 1000;
MAX_OFFSET = 1.0;

offs = hslider("offset", .3, 0, MAX_OFFSET, 0.001);
bd = hslider("base delay", 1000, 0, MAX_DELAY, 1);
use_one_slider = checkbox("use combined slider");
del = hslider("delay", 1000, 0, MAX_DELAY+MAX_OFFSET, 0.001) : ip : max(0) : min(MAX_DELAY + MAX_OFFSET);

arg = if(use_one_slider, del, bd+offs);
// process = _, _ : par(i, 2, lanczos_fdel(100.75)) : _, _;
process = _, _ : lanczos_fixed_fdel(arg), lanczos_fixed_fdel(arg) : _, _;

