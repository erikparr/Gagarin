Server.local.options.device_("MOTU");
s.options.sampleRate = 48000;
s = Server.local.reboot;

(
//------------------------------
//pitch detection
SynthDef("pitchFollow1",{
	var in, amp, freq, hasFreq, out;
	in = Mix.new(SoundIn.ar([1]));
	// amp = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Tartini.kr(in, ampThreshold: 0.2, median: 7);
	SendTrig.kr(Impulse.kr(10),0,freq);
	Out.ar(0,(SinOsc.ar(MouseY.kr(560,567.5)) * MouseX.kr(0.0,10)));
}).play(s);
)
//------------------------------
//record and playback
(
SynthDef("soundIn", {
	Out.ar(0, SoundIn.ar(0));
}).send(s);

// this will record to the disk
SynthDef("recToDisk", {arg bufnum;
	DiskOut.ar(bufnum, In.ar(0,1));
}).send(s);

// this will play it back
SynthDef("playback", { arg bufnum = 0;
	var freq, hasFreq;
	# freq, hasFreq = Tartini.kr(PlayBuf.ar(1, 0, doneAction:2, loop:0));
		SendTrig.kr(Impulse.kr(10),0,freq);
    Out.ar(0, DiskIn.ar(1, 0));
}).send(s);
)
(
x = Synth.new("soundIn");
d = Synth(\test_in, [\inbus, 2, \outbus, 0]);

b= Buffer.alloc(s, 65536, 1);
b.write("/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest1.aiff", "aiff", "int16", 0, 0, true);
// create the diskout node; making sure it comes after the source
d = Synth.tail(nil, "recToDisk", ["bufnum", b]);
)
(
d.free;
x.free;
b.close;
b.free;
)
// play it back
(
x = Synth.basicNew("help-Diskin-2chan");
m = { arg buf; x.addToHeadMsg(nil, [\bufnum,buf])};

b = Buffer.cueSoundFile(s,"~/diskouttest.aiff".standardizePath, 0, 2, completionMessage: m);
)
x.free; b.close; b.free; // cleanup

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

NetAddr.langPort; // retrieve the current port SC is listening to
NetAddr.localAddr; // retrieve the current IP and port
//------------------------------

b = Buffer.read(s, "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff");
c = Buffer.alloc(s, b.numFrames / s.options.blockSize);
{RecordBuf.kr(Tartini.kr(PlayBuf.ar(1, b, doneAction:2, loop:0)).at(0), c)}.play;
c.postln