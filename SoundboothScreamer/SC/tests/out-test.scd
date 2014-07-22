
/*
INPUT
channel 8 -> DPA mini mic
channel 9 -> voice mic
OUTPUT
channel 0 -> horn driver
channel 1 -> reference

*/
(
SynthDef("help-out", { arg out=0, freq=440;

        // write to the bus, adding to previous contents
	Out.ar(out, SinOsc.ar(440)*0.001); //*EnvGen.kr(Env([0,1.0,1.0,0],[0.2,5,0.5], 'sin'), doneAction:2)));
	// Out.ar(out, In.ar(9));

}).send(s);

)

Synth("help-out", [\out, 2]);

{ Out.ar(2,SinOsc.ar(500, 0, 0.12*EnvGen.kr(Env([0,1.0,1.0,0],[0.5,10,0.5], 'lin'), doneAction:2))) }.play;
{ Out.ar(2,SinOsc.ar(500, 0, 0.14)) }.play; // reach "limit" on

//XL2 Sound Level Meter & Acoustic Analyzer - NTi
// SLMeter Test data:
// Komplete Audio 6 card
// reaches "limit" on SLMeter, excellent clean signal, noise burst at start, end. both methods generate same output:
{ Out.ar(2,SinOsc.ar(500, 0, 0.02)) }.play;
SynthDef("level", {Out.ar(2, SinOsc.ar(500, 0, 0.02))}).play(s);
//reaches "limit" on SLMeter, excellent clean signal, no noise burst with envelope, no diff w/ 'sin', 'lin' env curves
SynthDef("level", {Out.ar(2, SinOsc.ar(500, 0, 0.02)*EnvGen.kr(Env([0,1.0,1.0,0],[0.5,2,0.5], 'lin'), doneAction:2))}).play(s);
//well above "limit" on SLMeter (orange), pure sine frequency at 500 hz, but noise at nearest upper bandwidths at max 62 dB relative
SynthDef("level", {Out.ar(2, SinOsc.ar(500, 0, 0.14)*EnvGen.kr(Env([0,1.0,1.0,0],[0.1,2.5,0.5], 'sin'), doneAction:2))}).play(s);
/*0.12 is the level in which we are breaking glass, which registers  in SLMeter as:
as 114 dB L(AS)/ 120 L(CPK) / L(ASmax)47.8dB, which is consistent in all frequencies in range 400-800, previous double band observation was a mistake
*/
//MOTU:
{ Out.ar(2,SinOsc.ar(500, 0, 0.05)) }.play;
/*
0.05 is at 114 dB L(AS) / 120 L(CPK) -- same as Komplete -- highest nearest upper band at 60 dB relative (which = -40db?)
*/
//SINEWAVE GENERATOR NTi Minirator MR-PRO:
/*

*/