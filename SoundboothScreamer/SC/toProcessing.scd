s.options.sampleRate = 48000;
//Server.local.options.device_("Scarlett 2i4 USB");
 Server.local.options.device_("Komplete Audio 6");
s.boot
s.quit

//------------------------------
// register to receive this message
(
	~p5Out = NetAddr("127.0.0.1", 47110);
	// test it with one message:
	~p5Out.sendMsg("/from_SC", 500);

r = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
	// [time,responder,msg].postln;
	msg[3].postln;
	~p5Out.sendMsg("/s_new", \test, msg[3], 1, 0);
	// ~p5Out.sendMsg("/s_new", \test, 563.76007080078, 1, 0);

}).add
)

r.remove; // don't forget to remove the responder once you're done
//------------------------------
//pitch detection
(
SynthDef("pitchFollow",{
	var in, amp, freq, hasFreq, out;
	in = SoundIn.ar(9);
	// amp = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Tartini.kr(in,0.2);
	SendTrig.kr(Impulse.kr(10),0,freq);
	// Out.ar(0,(SinOsc.ar(MouseY.kr(560,567.5)) * MouseX.kr(0.0,10)));
}).load(s);
)
Synth.new("pitchFollow1");