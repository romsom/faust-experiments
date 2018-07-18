import("stdfaust.lib");
// ba = library("basics.lib");
// si = library("signals.lib");
//    import("filters.lib");
// import("math.lib");

SR_MAX = 192000.0;
SR_ = min(ma.SR, SR_MAX);

// smoothing filter
ipt = hslider("smooth_time", 0.05, 0, 0.1, 0.001); // s
ip = si.smooth(ba.tau2pole(ipt));

f = hslider("feedback", 0.985, 0.9, 1, 0.001) : ip : min(1) : max(0); // scaling factor
dry = hslider("dry", 0.2, 0, 1, 0.01) : ip : min(1) : max(0); // scaling factor
wet = hslider("wet", 0.1, 0, 1, 0.01) : ip : min(1) : max(0); // scaling factor
transps = hslider("transpose", 0, -24, 24, 1) : ip : min(24) : max(-24);
detune = hslider("detune", 0.066, -1, 1, 0.001) : ip : min(1) : max(-1);


fixed_fdel(n) = \(x).((1-wet) * x@nInt + wet * x@(nInt + 1))
with {
     nInt = int(n);
     wet = n - nInt;
};

// discard util signal here
d(t) = \(x).(cal(x)) : \(x,y).(x)
with {
     cal(x) = (+(x), +(wet* x)) ~ (sd : mux)
     with {
     	  // single delay stage, customize
     	  sd(x,y) = y@(t * SR_);
	  // output signal, feedback signal
       	  mux = _ <: _, f*_;
    };
};

resonator(note) = \(x).(dry * x + wet * x : del)
with {
    del = d(1 / ba.midikey2hz(note + detune));
};

//d_dorian = (50, 55, 60, 65, 71, 76, 81);
d_dorian(0) = 50;
d_dorian(1) = 55;
d_dorian(2) = 60;
d_dorian(3) = 65;
d_dorian(4) = 71;
d_dorian(5) = 76;
d_dorian(6) = 81;

dorian_resonator(offset_from_d) = par(i, ba.count(d_dorian), resonator(d_dorian(i) + offset_from_d));


//process = dorian_resonator(0), dorian_resonator(4);//process = resonator(50), resonator(65);
process = _ <: resonator(50 + transps), resonator(43 + transps);
//process = _ <: resonator(50 + transps), resonator(52 + transps);
//process = _ <: resonator(52 + transps), resonator(58 + transps);
