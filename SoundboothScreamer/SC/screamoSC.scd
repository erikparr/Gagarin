// register to receive this message
~p5Out = NetAddr("127.0.0.1", 47110);
//ins/outs
~isMachineMac = 0; //!!! Make sure machine is set to right OS, pc = false, mac = true
~glassMicIn=8;
~voiceMicIn=9;
~hornDriverOut=2; // output to driver on soundcard out 3 !
~referenceOut=3;
// ~hornDriverOut=0; // output to driver on soundcard out 3 !
// ~referenceOut=1;

// create a function called recordSample that executes the whole thing
~recordSample = {
	//record vars
	var win, playButton, oscRecord, adrs, recordState=0, onStart, onStop, resetAll, play, rec, buf, playbuf, freeAll,
	//analysis vars
	analyzeFreq, freqs, freqTrig, bag, dict, target, killFreq, oscAnalyze,rtAnalyze,
	//get frequency range vars
	getFreqRange,total, sIndex, eIndex, range, mRange, count, startFreq, endFreq, avgFreq, targetFreq, pitchVal,
	// visualizer vars
	toP5osc,freqOsc, refTone, startGame, oscRefTone, monitorOutput, playMixtone,oscMixTone,
	//high amplitude glass killing machine vars
	killShot, oscKill, breakGlass,startAgain,
	//paths
	 audioFilepath = "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff";
	// audioFilepath = "C:\\Users\\gagarin\\Documents\\Gagarin-master\\SoundboothScreamer\\SC\\samples\\diskouttest.aiff";

	//-- onStart routine to record----------------------------------

	onStart = 	Routine({
		analyzeFreq.reset;
		breakGlass.reset;
		"play that glassy shit".postln;
		buf = Buffer.alloc(s, 65536, 1);
		buf.write(audioFilepath,
			"aiff", "int16", 0, 0, true);
		// create the diskout node; making sure it comes after the source
		rec = Synth.tail(nil, "recToDisk", ["bufnum", buf]);

	});

	//-- onStop routine stops recording and frees---------------
	onStop = Routine({
		// stop recording and free it up
		rec.free;
		play.free;
		buf.close;
		buf.free;
		// playbuf = Buffer.read(s, "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff");

		0.1.wait;
		analyzeFreq.play;
	});

	//---analyze sample to get fundamental freqency-------------
	analyzeFreq = Routine({
		onStart.reset; onStop.reset; getFreqRange.reset;
		"analyzing...".postln;
		0.1.wait;
		//-- load newly recorded sound sample into buffer
		playbuf = Buffer.read(s, audioFilepath);
		//-----
		freqs = Array.newClear;
		freqTrig = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
			var newFreq = msg[3];
			if((newFreq>500) &&(newFreq<900),{
				freqs = freqs.add(newFreq);});
		}).add;
		1.wait; // do we need to wait for buffer to load?
		 "playing analysis..".postln;
		rtAnalyze = Synth(\playback, [\bufnum, playbuf.bufnum]);
		playbuf.duration.wait;
		freqTrig.free;
		"finished playing".postln;
		rtAnalyze.free;
		freqs=freqs.sort.round(0.1);
		freqs[0].postln;
		bag = freqs.as(Bag);
		dict=bag.contents;
		target = 0; // init at zero
		dict.size.do({|i| if(dict.values.at(i)>target,{target = dict.values.at(i)})});
		killFreq = dict.findKeyForValue(target);
		killFreq.postln;
		2.wait;
		"get freq range...".postln;
		//if we have a bad recording, reset and try again, otherwise continue to getFreqRange routine
		if(freqs[0].isNil,{~p5Out.sendMsg( "/isReady", 0.0); freeAll.value;},
			{~p5Out.sendMsg( "/isReady", 1.0);getFreqRange.value;});
	});
	//-----get most stabile frequency range-----------------------
	getFreqRange = Routine({
		"getting freq range".postln;
		analyzeFreq.stop; // stop previous routine
		total=0;//total count
		sIndex=0;//start index
		eIndex=0;//end index
		range=freqs.size-1; // size of array
		freqs.size.do({arg i;
			count=0;
			mRange = range-i;
			while ( { ( ((freqs[i]-freqs[min(i+count, range)]).abs < 2.0) && (count<mRange)) }, {
				if(count>total,{
					total=count; sIndex=i; eIndex=(i+count);
				});
				count = count + 1;
			});
			// "total run: ".post; total.postln; "start index: ".post; sIndex.postln; "end index: ".post; eIndex.postln; "i:".post; i.postln;(freqs[i]-freqs[min(i+count, range)]).abs.postln; "---".postln;
			startFreq = freqs[sIndex]; endFreq = freqs[eIndex];
			// startFreq.post; " -- ".post; endFreq.postln;
			avgFreq = ((startFreq+endFreq)/2).min(1000).max(400); //keep freqs in safe range for driver output (400-1000 hz)
			targetFreq = avgFreq*0.5;
			if(i==range,{
				"startFreq: ".post; startFreq.postln;
				"endFreq: ".post; endFreq.postln;
				"avgFreq: ".post; avgFreq.postln;
				"killFreq: ".post; killFreq.postln});
		});
		// 5.wait;
		// startGame.play;
	});
	//-- play the game via Processing----
	startGame = Routine({
		"playing...".postln;
		// getFreqRange.stop;
		//send target frequency to Processing
		~p5Out.sendMsg( "/target", targetFreq.asFloat);
		// {freqs.plot("Resonant freq: "+killFreq+" start: "+startFreq+" end: "+endFreq,discrete: true)}.defer;
		//------------------------------
		toP5osc = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
			// [time,responder,msg].postln;
			pitchVal = (msg[3]).min(500).max(60);
			// pitchVal.postln;
			~p5Out.sendMsg("/pitch", pitchVal.asFloat);
			// ~p5Out.sendMsg("/pitch", "pitch", 1, 0);
		}).add;

		freqOsc = Synth.new("pitchFollow");
		monitorOutput = Synth.new("gameplay", [\freq, killFreq, \amp, 0.02]); // not using freq arg
		playMixtone = Synth.new("mixTone", [\freq, killFreq, \amp, 0]);

		// refTone.free;
		"start game".postln;
	});
	//-- play the game via Processing----
	breakGlass = Routine({
		monitorOutput.free;
		playMixtone.free;
		startGame.stop;
		"avgFreq: ".post;
		avgFreq.postln;
		"killing...".postln; //((startFreq+endFreq)/2).postln;
		5.1.wait;
		// killShot.free; "killed.".postln;
		"resetting...".postln;
		resetAll.value;
		freeAll.value;
	});

	resetAll = Routine({
		monitorOutput.free;
		playMixtone.free;
		startGame.stop;
		onStart.reset; onStop.reset; analyzeFreq.reset; getFreqRange.reset; startGame.reset;//killShot.free;
	});

	freeAll = Routine({ refTone.free; freqOsc.free; killShot.free; playMixtone.free;
		 oscKill.free; playbuf.free; buf.free; "its freed".postln; });


	//-----processing OSC setup------------------------------------------
	adrs = NetAddr("localhost", 57120); // the url should be the one of computer of app 2 (or nil)
	oscRecord = OSCFunc({ arg msg, time, addr, recvPort;
		// [msg, time, addr, recvPort].postln;
		if(recordState==0,
			{onStart.value; "recording...".postln; recordState=1;},
			{onStop.play; "stopped recording".postln; recordState=0;});
		adrs }, '/1/toggle1');

	oscAnalyze = OSCFunc({ arg msg, time, addr, recvPort;
		// [msg, time, addr, recvPort].postln; "msg: ".post;
		// msg[1].postln;
		startGame.play; "starting game...".postln; // notice this is .PLAY instead of .value!!!!
		adrs }, '/oscGameStart');
	//-- get reference tone
	oscRefTone = OSCFunc({ arg msg, time, addr, recvPort;
		// [msg, time, addr, recvPort].postln; "msg: ".post;
		// msg[1].postln;
		refTone = Synth.new("referenceTone", [\freq, targetFreq]);
		adrs }, '/oscRefTone');

	oscKill = OSCFunc({ arg msg, time, addr, recvPort;
		if(msg[1]==1,
			{
				killShot = Synth(\deathByAudio, [\freq, avgFreq]);
				breakGlass.play;
			},
			{
		});
		adrs }, '/killTone');

	//cleanup when player loses

	//on osc message from TargetWave.pde, mix reference tone in to monitor speaker
	oscMixTone = OSCFunc({ arg msg, time, addr, recvPort;
		playMixtone.set(\amp, msg[1]*0.01);
		adrs }, '/oscMixTone');

	startAgain = OSCFunc({ arg msg, time, addr, recvPort;
		resetAll.value;
		adrs }, '/reset');

};
~recordSample.value;

//o.free;
//----------synthdefs------------------------------------------------
// Synth(\playback, [\bufnum, playbuf.bufnum]);
SynthDef("playback", { arg bufnum;
	var freq, hasFreq, src;
	//-> src = PlayBuf.ar(1, bufnum, doneAction:2, loop:0);
	src = PlayBuf.ar(1, bufnum, doneAction:2, loop:0)*0.5;
	# freq, hasFreq = Tartini.kr(src,threshold: 0.1);
	SendTrig.kr(Impulse.kr(100),0,freq);
	Out.ar(~referenceOut, src);
}).send(s);

SynthDef("deathByAudio",{arg freq;
	var sweep, rate, env, amp;
	env = Env([0,1.0,1.0,0],[0.2,2.5,0.5], 'sin');
	rate = 0.2;
	amp = 0.12;
	// sweep = SinOsc.ar(freq)+SinOsc.ar(rate))*0.15;
	sweep = SinOsc.ar(freq,0,amp)*EnvGen.kr(env, doneAction:2);
	// Out.ar(~hornDriverOut,sweep*EnvGen.kr(env, doneAction:2));
	Out.ar(~hornDriverOut,sweep); //Limiter.ar(LPF.ar(HPF.ar(sweep,400),1000), amp, 0.01));
}).send(s);


SynthDef("referenceTone", {arg freq;
	var env;
	env = Env([0,1.0,1.0,0],[0.2,1,0.5], 'sin');
	Out.ar(~referenceOut, SinOsc.ar(freq)*0.25*EnvGen.kr(env, doneAction:2))
}).load(s);

//mix in sine tone to reference speaker at the "kill frequency"
SynthDef("mixTone", {arg freq, amp=1;
	var env;
	env = Env([0,1.0,1.0,0],[0.2,1,0.5], 'sin');
	Out.ar(~referenceOut, SinOsc.ar(freq)*0.1*amp)
}).load(s);

SynthDef("pitchFollow",{
	var in, amp, freq, hasFreq, out;
	in = In.ar(~voiceMicIn);
	// amp = Amplitude.kr(in, 0.05, 0.05);
	# freq, hasFreq = Tartini.kr(LPF.ar(HPF.ar(in,60),500),0.1);
	SendTrig.kr(Impulse.kr(10),0,freq);
	// Out.ar(0,(SinOsc.ar(MouseY.kr(560,567.5)) * MouseX.kr(0.0,10)));
}).send(s);

// Synth(\deathByAudio, [\freq, 552.1]);
//------------------------------
//record

// this will record to the disk
SynthDef("recToDisk", {arg bufnum;
	DiskOut.ar(bufnum, LPF.ar(HPF.ar(In.ar(~glassMicIn),300),750));
	//DiskOut.ar(bufnum, In.ar(0,1));
}).send(s);

//basic mic out to monitor synth
SynthDef("gameplay", {arg freq,amp,gate;
	var env, envgen;
	env = Env.asr(1, 1, 1, 'sin');
	envgen = EnvGen.kr(env, gate, doneAction: 2);
	//monitor mic
	Out.ar(~referenceOut, LPF.ar(HPF.ar(In.ar(~voiceMicIn,1),400),1000));
	//	Out.ar(~referenceOut, LPF.ar(HPF.ar(In.ar(~voiceMicIn),400),1000)+ SinOsc.ar(freq,0,amp)*envgen);
	//sine tone mix
	//Out.ar(0, SoundIn.ar(0)*0.2);
}).load(s);

//s.reboot
//			playbuf = Buffer.read(s, "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff");
/*
Synth.new("gameplay");
*/
