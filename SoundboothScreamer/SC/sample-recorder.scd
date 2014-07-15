// register to receive this message
~p5Out = NetAddr("127.0.0.1", 47110);
// test it with one message:
~p5Out.sendMsg("/from_SC", 500);

// create a function called recordSample that executes the whole thing
~recordSample = {
	//record vars
	var win, playButton, oscRecord, adrs, onStart, onStop, play, rec, buf,freeAll,
	//analysis vars
	analyzeFreq, freqs, freqTrig, bag, dict, target, killFreq, oscAnalyze,rtAnalyze,
	//get frequency range vars
	getFreqRange,total, sIndex, eIndex, range, mRange, count, startFreq, endFreq, avgFreq, refFreq,
	// visualizer vars
	toP5osc,freqOsc, refTone,
	//high amplitude glass killing machine vars
	killShot, oscKill, playTrig;

	//-- onStart routine to record----------------------------------

	onStart = 	Routine({
		"play that glassy shit".postln;
		// play = Synth.new("soundIn"); // dont need this... delete

		buf = Buffer.alloc(s, 65536, 1);
		buf.write("/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff",
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
	});

	//---analyze sample to get fundamental freqency-------------
	analyzeFreq = Routine({
		"analyzing...".postln;
		0.1.wait;
		//-- load newly recorded sound sample into buffer
		~buf = Buffer.read(s, "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff");
		//-----
		freqs = Array.newClear;
		freqTrig = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
			var newFreq = msg[3];
			if((newFreq>500) &&(newFreq<900),{
				freqs = freqs.add(newFreq);});
		}).add;
		1.wait; // do we need to wait for buffer to load?
		"playing..".postln;
		rtAnalyze = Synth(\playback, [\bufnum, ~buf.bufnum]);
		~buf.duration.wait;
		freqTrig.free;
		"finished playing".postln;
		rtAnalyze.free;
		freqs=freqs.sort.round(0.1);
		bag = freqs.as(Bag);
		dict=bag.contents;
		target = 0; // init at zero
		dict.size.do({|i| if(dict.values.at(i)>target,{target = dict.values.at(i)})});
		killFreq = dict.findKeyForValue(target);
	});
	//-----get most stabile frequency range-----------------------
	getFreqRange = Routine({
		"getting freq range".postln;
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
			avgFreq = ((startFreq+endFreq)/2).min(1000).max(400); //keep freqs in safe range for driver output (400-1000 hz)
			refFreq = avgFreq*0.5;
			if(i==range,{
				"startFreq: ".post; startFreq.postln;
				"endFreq: ".post; endFreq.postln;
				"avgFreq: ".post; avgFreq.postln;
				"killFreq: ".post; killFreq.postln});
	});
});

	//-----button setup-------------------------------------------
	// win = Window("record", Rect(128, 64, 340, 360));
	//
	// win.view.decorator = FlowLayout(win.view.bounds);
	// // w.addFlowLayout; // you can als write this instead of the line above
	//
	// win.view.background = Color(0.8,0.8,0.8);
	// playButton = Button(win, Rect(0,0, 340, 360));
	// playButton.states = [["Start ", Color.black, Color.green],
	// ["Stop ", Color.white, Color.red]];
	// playButton.action_({ arg butt;
	// 	if(butt.value == 1,{
	// 		onStart.value;
	// 		},{
	// 			onStop.value;
	// 	})
	// });
	// win.front;
	//-----TouchOSC setup------------------------------------------
	adrs = NetAddr("localhost", 57120); // the url should be the one of computer of app 2 (or nil)
	oscRecord = OSCFunc({ arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		if(msg[1]==1,
			{onStart.value; "recording...".postln},
			{onStop.value; "stopped recording".postln; });
		adrs }, '/1/toggle1');

	oscAnalyze = OSCFunc({ arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln; "msg: ".post;
		msg[1].postln;
		if(msg[1]==1,
			{analyzeFreq.play; }, // notice this is .PLAY instead of .value!!!!
			{ getFreqRange.play});
		adrs }, '/1/toggle2');

	oscKill = OSCFunc({ arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].postln;
		msg[1].postln;
		if(msg[1]==1,
			// playTrig = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
			// 	// msg[3].postln;
			// }).add;

			{
								//send target frequency to Processing
				~p5Out.sendMsg("/s_new", \target, avgFreq, 1, 0);
				// {freqs.plot("Resonant freq: "+killFreq+" start: "+startFreq+" end: "+endFreq,discrete: true)}.defer;
				//------------------------------
				toP5osc = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
					// [time,responder,msg].postln;
					msg[3].postln;
					~p5Out.sendMsg("/s_new", \test, msg[3], 1, 0);
				}).add;

				refTone = Synth.new("referenceTone", [\freq, refFreq]);
				freqOsc = Synth.new("pitchFollow1");

				refTone.free;
				"killing...".postln; //((startFreq+endFreq)/2).postln;
			},
			{
				killShot = Synth(\deathByAudio, [\freq, avgFreq]);
				// killShot.free; "murder death kill!".postln
		});
		adrs }, '/1/toggle3');

	freeAll = OSCFunc({ arg msg, time, addr, recvPort;
		// [msg, time, addr, recvPort].postln;
		if(msg[1]==1,
			{analyzeFreq.reset; onStart.reset; onStop.reset;
				"resetting...".postln},
			{ refTone.free; freqOsc.free; toP5osc.free; playTrig.free; killShot.free; oscRecord.free; oscAnalyze.free;
				oscKill.free; freeAll.free; ~buf.free; "its freed".postln; });
		adrs }, '/1/toggle4');
};
~recordSample.value;

//o.free;
//----------synthdefs------------------------------------------------
// Synth(\playback, [\bufnum, ~buf.bufnum]);
SynthDef("playback", { arg bufnum;
	var freq, hasFreq, src;
	//-> src = PlayBuf.ar(1, bufnum, doneAction:2, loop:0);
	src = PlayBuf.ar(1, bufnum, doneAction:2, loop:0);
	# freq, hasFreq = Tartini.kr(src,threshold: 0.1);
	//     SendTrig.kr(Dust.kr(1.0),0,0.9);

	SendTrig.kr(Impulse.kr(100),0,freq);
	Out.ar(1, src);
	// Out.ar(3, LPF.ar(HPF.ar(src,50),2000));
	// Out.ar(3,  LPF.ar(HPF.ar(src,50),2000));
}).send(s);
// Synth(\deathByAudio, [\freq, 560]);

SynthDef("deathByAudio",{arg freq;
	var sweep, rate, env;
	env = Env([0,1.0,1.0,0],[0.2,5,0.5], 'sin');
	rate = 0.2;
	// sweep = SinOsc.ar(freq)+SinOsc.ar(rate))*0.15;
	sweep = SinOsc.ar(freq);
	// SendTrig.kr(Impulse.kr(10),0,sweep);
	// SendTrig.kr(Impulse.kr(10),0,(SinOsc.kr(((sFreq+eFreq)/2)+SinOsc.kr(rate))));
	Out.ar(0,Limiter.ar(LPF.ar(HPF.ar(sweep,400),1000), 1.0, 0.01)* EnvGen.kr(env, doneAction:2));
	// Out.ar(2,SinOsc.ar(sweep) * 2.0);
	// Out.ar(2,(SinOsc.ar(freq+(0.5*(SinOsc.ar(0.3)))) * 2.0));
	// Out.ar(2,(SinOsc.ar(freq+(SinOsc.ar(0.2)))) * 2.0);
	// Out.ar(2,SinOsc.ar(freq) * 2.0);
}).send(s);


SynthDef("referenceTone", {arg freq;
	Out.ar(1, SinOsc.ar(freq)*0.0025);
}).load(s);


//------------------------------
//record

// SynthDef("soundIn", {
// 	Out.ar(1, SoundIn.ar(8));
// 	//Out.ar(0, SoundIn.ar(0));
// }).send(s);

// this will record to the disk
SynthDef("recToDisk", {arg bufnum;
	DiskOut.ar(bufnum, In.ar(8,1));
	//DiskOut.ar(bufnum, In.ar(0,1));
}).send(s);

//basic mic out to monitor synth
SynthDef("in", { arg out=0, in=0;
	Out.ar(1, SoundIn.ar(9)*0.2);
	//Out.ar(0, SoundIn.ar(0)*0.2);
}).play(s);

//s.reboot