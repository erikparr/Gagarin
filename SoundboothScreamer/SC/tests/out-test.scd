
/*
INPUT
channel 8 -> DPA mini mic
channel 9 -> voice mic
OUTPUT
channel 0 -> horn driver
channel 1 -> reference

*/
SynthDef("help-out", { arg out=0, freq=440;

        // write to the bus, adding to previous contents
	Out.ar(out, SinOsc.ar(440, 0, 0.05));
	// Out.ar(out, 3*In.ar(8));

}).send(s);



Synth("help-out", [\out, 0]);