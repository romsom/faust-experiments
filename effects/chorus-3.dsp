import("stdfaust.lib");

DELAY_MS_MAX = 25;
SR_MAX = 192000.0;
SR_ = min(ma.SR, SR_MAX);

// schematic: https://music-electronics-forum.com/attachment.php?s=29ec8b940dac9eece5ad132141fc8031&attachmentid=29504&d=1404427474
//  -> filename: "boss CE3.pdf"
// BBD emulation: http://dafx10.iem.at/proceedings/papers/RaffelSmith_DAFx10_P42.pdf

depth = hslider("depth", 0.5, 0.0, 1.0, 0.01) : si.smoo : min(1.0) : max(0.0);
rate = hslider("rate", 0.5, 0.0, 1.0, 0.01) : si.smoo : min(1.0) : max(0.0);

// TODO
//  - how many stages does the MN3207 have? - 1024
//  - what sampling frequency range do we have?
//    - look at MN3102:
//  - what does the lfo waveform look like?
//    - sampling could be an option
//    - or sampling of the modulated clock signal and reconstruction of the lfo -> delay characteristic
//  - what is the frequency/phase response of the anti-aliasing and reconstruction filters?
//    - there are also some 0.33µF coupling caps that may limit the low end of the wet signal
//  - how do we emulate the filters?
//  - add noise
//  - implement using fixed length delay line with variable sampling frequency
//    - that requires resampling in C++ code - how does guitarix handle that?
// - what is the range of the lfo frequency?
// Info:
// Mixing:
//  - depending on the setting of the mode switch, either
//    - Out A: dry + wet, Out B: dry - wet
//    - Out A: wet, Out B: dry
//  - the dry signals come from the same OP-Amp output, that drives the anti-alias filter (through an 0.33µF cap in the latter case)

process = _ <: _, _;
