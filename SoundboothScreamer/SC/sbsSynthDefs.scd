//
// SynthDef("playback", { arg bufnum;
// 	var freq, hasFreq, src;
// 	src = PlayBuf.ar(1, bufnum, doneAction:2, loop:0);
// 	# freq, hasFreq = Tartini.kr(src,threshold: 0.1);
//
// 	SendTrig.kr(Impulse.kr(100),0,freq);
// 	// Out.ar(3, LPF.ar(HPF.ar(src,50),2000));
// 	// Out.ar(3, LPF.ar(HPF.ar(src,50),2000));
// 	Out.ar(3,  LPF.ar(HPF.ar(src,50),2000));
// }).send(s);
//
// SynthDef("deathByAudio",{arg freq;
// 	Out.ar(2,(SinOsc.ar(freq+((SinOsc.ar(0.2)))) * 2.0));
// 	// Out.ar(2,(SinOsc.ar(freq) * 1.75));
// 	// Out.ar(2,(SinOsc.ar(freq) * 1.75));
// }).send(s);
//
//
// //------------------------------
// //record
//
// SynthDef("soundIn", {
// 	Out.ar(0, SoundIn.ar(0));
// }).send(s);
//
// // this will record to the disk
// SynthDef("recToDisk", {arg bufnum;
// 	DiskOut.ar(bufnum, In.ar(0,1));
// }).send(s);
