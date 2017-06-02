var buffers, monoStereoSampleDirectory, osc, osc1,osc2, osc3, osc4, cond, notes, dBufIndex,dNotes;
var windowWidth, windowHeight, textWidth, textHeight, projectDirectory;
var projectDirectoryText, monoStereoSampleDirectoryText, multichannelSampleDirectory, multichannelSampleDirectoryText, channelSelect, isSystemReady;


cond = Condition.new;
dBufIndex=Dictionary.new;
dNotes=Dictionary.new;
"RUNNING MULTICHANNEL SAMPLER".postln;
s.waitForBoot({

	//---------------------------------------------------------------------
	//--------GUI----------------------------------------------------------
	//---------------------------------------------------------------------


	// channelSelect = Dictionary.new;
	projectDirectory = "C:/directory/path/here/";
	multichannelSampleDirectory = "C:/multichannel/samples/path/here/";
	monoStereoSampleDirectory = "C:/monoAndStereo/samples/path/here/";
	windowWidth = 600;
	windowHeight = 600;
	textWidth= 600;
	textHeight=20;

	w = Window.new("Multichannel Sampler Setup", Rect(0,0,windowWidth,windowHeight)).front;
	//--------
	a = StaticText(w, Rect((w.bounds.width/2)-(textWidth/2), 10, textWidth,textHeight));
	a.string = "Project Directory Path";
	a.align_(\left);
	a.font_( "Helvetica", 11);
	if(FileReader.read("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/input.sc") == nil,{
		"oops".postln;
		isSystemReady=false;
	},{
		FileReader.read("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/input.sc").flatten(1).postcs;
		projectDirectory = FileReader.read("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/input.sc").flatten[0].asString;
		multichannelSampleDirectory = FileReader.read("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/input.sc").flatten[1].asString;
		monoStereoSampleDirectory = FileReader.read("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/input.sc").flatten[2].asString;
		isSystemReady=true;
	});
	//--------
	projectDirectoryText = TextField(w, Rect((w.bounds.width/2)-(textWidth/2), 30, textWidth,textHeight))
	.string_(projectDirectory);
	//------- "Multichannel Sample Directory Path";----
	a = StaticText(w, Rect((w.bounds.width/2)-(textWidth/2), 60, textWidth,textHeight));
	a.string = "Multichannel Sample Directory Path";
	a.align_(\left);
	a.font_( "Helvetica", 11);
	//--------
	multichannelSampleDirectoryText = TextField(w, Rect((w.bounds.width/2)-(textWidth/2), 80, textWidth,textHeight))
	.string_(multichannelSampleDirectory);
	// multichannelSampleDirectoryText.valueAction_(multichannelSampleDirectory = multichannelSampleDirectoryText.string); //does the action, if the value has changed
	//-----"Mono/Stereo Sample Directory Path"----
	a = StaticText(w, Rect((w.bounds.width/2)-(textWidth/2), 110, textWidth,textHeight));
	a.string = "Mono/Stereo Sample Directory Path";
	a.align_(\left);
	a.font_( "Helvetica", 11);
	//--------
	monoStereoSampleDirectoryText = TextField(w, Rect((w.bounds.width/2)-(textWidth/2), 130, textWidth,textHeight))
	.string_(monoStereoSampleDirectory);
	// multichannelSampleDirectoryText.valueAction_(multichannelSampleDirectory = multichannelSampleDirectoryText.string); //does the action, if the value has changed
	//--------
	b=Button(w, Rect(10, 180, textWidth/4,textHeight)
	).states_([["Save"]]);
	b.action = {var fileString, index;
		projectDirectory = projectDirectoryText.value;
		multichannelSampleDirectory = multichannelSampleDirectoryText.value;
		monoStereoSampleDirectory = monoStereoSampleDirectoryText.value;
		fileString = projectDirectory.asString++"input.sc";
		f = File(fileString, "w+");
		f.write(projectDirectory++"\n"++multichannelSampleDirectory++"\n"++monoStereoSampleDirectory);
		f.close;

		// load buffers
		index = dBufIndex.size;
		(multichannelSampleDirectory ++ "*").pathMatch.do{arg path, i;
			//collect all the multichan buffers and add them to  primary buffer array
			(path ++ "*").pathMatch.do{arg soundfilepath, j; var buf, multichannelSampleDirectoryName;
				//add to dictionary by following format: "multichannelSampleDirectory-filename.wav"
				multichannelSampleDirectoryName = soundfilepath.split;
				multichannelSampleDirectoryName = multichannelSampleDirectoryName[multichannelSampleDirectoryName.size-2];
				dBufIndex.add(multichannelSampleDirectoryName++"-"++PathName.new(soundfilepath).fileName -> index);
				index=index+1;

				buf = Buffer.read(s, soundfilepath, action: {cond.test_(true).signal});
				buffers=buffers++buf;
			};
		};
	};
	//---------------------------------------
	// i = Image.open("/Users/erikparr/Documents/_2017/WORK/Gagarin_MultichannelSampler/SC/resources/speaker.png");
	// w.drawFunc_({
	// 	6.do{arg j; var box;
	// 		Pen.drawImage( Point((j*65), 240), i, operation: 'sourceOver', opacity:1);
	// 		box=CheckBox.new(w,Rect(25+(j*65), 320, 20,20));
	// 		box.action= {channelArray[j]=box.value.asInt; channelArray.postln};
	// 		// channelSelect.add("chan"++j -> box);
	// 	}
	// });



	//---------------------------------------------------------------------
	//-----------STARTUP--------------------------------------------------
	//---------------------------------------------------------------------


	if(isSystemReady==true,
		{var index;
			"system is ready. Loading buffers...".postln;

			// load buffers
			buffers = (monoStereoSampleDirectory ++ "*").pathMatch.collect{arg path, i;
				var buf,multichannelSampleDirectoryName;
				//add to dictionary by following format: "multichannelSampleDirectory-filename.wav"
				multichannelSampleDirectoryName = path.split;
				multichannelSampleDirectoryName = multichannelSampleDirectoryName[multichannelSampleDirectoryName.size-2];

				dBufIndex.add(multichannelSampleDirectoryName++"-"++PathName.new(path).fileName -> i);
				buf = Buffer.read(s, path, action: {cond.test_(true).signal});
				cond.wait;
				cond.test_(false);
				buf;
			};

			index = dBufIndex.size;
			(multichannelSampleDirectory ++ "*").pathMatch.do{arg path, i;
				"path: ".post; path.postln;
				//collect all the multichan buffers and add them to  primary buffer array
				(path ++ "*").pathMatch.do{arg soundfilepath, j; var buf, multichannelSampleDirectoryName;
					//add to dictionary by following format: "multichannelSampleDirectory-filename.wav"
					multichannelSampleDirectoryName = soundfilepath.split;
					multichannelSampleDirectoryName = multichannelSampleDirectoryName[multichannelSampleDirectoryName.size-2];
					dBufIndex.add(multichannelSampleDirectoryName++"-"++PathName.new(soundfilepath).fileName -> index);
					index=index+1;

					buf = Buffer.read(s, soundfilepath, action: {cond.test_(true).signal});
					buffers=buffers++buf;
				};
			};
			"buffers size: ".post;buffers.size.postln;
		},{
			"system is not ready. Please set sample directory paths".postln;
	});

	//---------------------------------------------------------------------
	//--------SYNTHS----------------------------------------------------------
	//---------------------------------------------------------------------


	SynthDef ("monoPlay", {arg  bufnum, bus, dur, amp=1, gate=1;
		var in, env;
		in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), doneAction:2);
		env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [0.05, 0.9, 0.05], \sin, 2), gate, timeScale: dur, doneAction:2);
		Out.ar(bus, in * env*amp );
	}).add;


	SynthDef ("stereoPlay", {arg  bufnum, bus, dur, amp=1, gate=1;
		var in, env;
		in = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2);
		env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [0.05, 0.9, 0.05], \sin, 2), gate, timeScale: dur, doneAction:2);
		Out.ar(bus, in * env*amp );
	}).add;

	SynthDef ("multiPlay", {arg  bufnum, bus, dur, amp=1, gate=1;
		var in, env;
		in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), doneAction:2);
		env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [0.05, 0.9, 0.05], \sin, 2), gate, timeScale: dur, doneAction:2);
		Out.ar(bus, in * env*amp );
	}).add;


	osc = OSCFunc({ arg msg, time;
		var  outbus, filename, amp, bufferID, noteID;
		msg.postln;
		outbus = msg[1];
		filename = msg[2].asString; // dont forget asString
		amp = msg[3];
		bufferID = dBufIndex.at(filename);
		noteID = outbus.asString++"-"++filename; //create unique noteid based on filename and output speaker
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		if(buffers[bufferID].numChannels==1,{
			dNotes.add(noteID -> Synth("monoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", buffers[bufferID].duration, "amp", amp, "gate", 1]));
			"playing mono".postln;
		},{
			dNotes.add(noteID -> Synth("stereoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", buffers[bufferID].duration, "amp", amp, "gate", 1]));
			"playing stereo".postln;
		});
		//-------------------------------


	}, '/play');

	//---------------------------------------------------------------------
	//--------OSC FUNCTIONS-----------------------------------------------
	//---------------------------------------------------------------------


	osc1 = OSCFunc({ arg msg, time;
		var  outbus, filename, noteID,stopNote;
		msg.postln;
		outbus = msg[1];
		filename = msg[2].asString; // dont forget asString
		noteID = outbus.asString++"-"++filename;
		stopNote = dNotes.at(noteID.asString);
		stopNote.set("gate",0);
	}, '/stop');

	osc2 = OSCFunc({ arg msg, time;
		var  isPlaying, outbus, amp, notes;
		"ok".postln;
		osc.disable;
		OSCFunc.allDisabled; // to see all the disabled function
		osc.free;
	}, '/free');

	// //play multichannel
	osc3 = OSCFunc({ arg msg, time;
		var  outbusArray, outbusArrayName, directoryName, amp, bufferID, noteID, totalSoundfiles, filenames;
		outbusArray = msg[1].asString.split($,);
		outbusArray.do{arg channelString; outbusArrayName =outbusArrayName++channelString; };
		directoryName = msg[2].asString; // dont forget asString
		amp = msg[3];

		filenames = (multichannelSampleDirectory ++directoryName++"/" "*").pathMatch.collect{arg path, i;
			totalSoundfiles = i;
			PathName.new(path).fileName
		};
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		totalSoundfiles.do{arg i;
			bufferID = dBufIndex.at(directoryName++"-"++filenames[i]);
			noteID = outbusArrayName.asString++"-"++directoryName++"-"++i; //create unique noteid based on filename + output speaker + filenum
			dNotes.add(noteID -> Synth("monoPlay", ["bufnum", buffers[bufferID], "bus", outbusArray[i].asInt, "dur", buffers[bufferID].duration, "amp", amp, "gate", 1]));
		};
		"playing multichan".postln;

	}, '/playMultichan');

	// //play multichannel
	osc4 = OSCFunc({ arg msg, time;
		var  outbusArray, outbusArrayName, directoryName, bufferID, noteID, totalSoundfiles, filenames, stopNote;
		outbusArray = msg[1].asString.split($,);
		outbusArray.do{arg channelString; outbusArrayName =outbusArrayName++channelString; };
		directoryName = msg[2].asString; // dont forget asString
		filenames = (multichannelSampleDirectory ++directoryName++"/" "*").pathMatch.collect{arg path, i;
			totalSoundfiles = i;
			PathName.new(path).fileName
		};
		//----Stop the note by releasing gate--------------
		totalSoundfiles.do{arg i;
			bufferID = dBufIndex.at(directoryName++"-"++filenames[i]);
			noteID = outbusArrayName.asString++"-"++directoryName++"-"++i; //create unique noteid based on filename + output speaker + filenum
			stopNote = dNotes.at(noteID.asString);
			stopNote.set("gate",0);

		};
		"stop multichan".postln;

	}, '/stopMultichan');



});
// n = NetAddr("127.0.0.1", 57120);

/*
n = NetAddr("127.0.0.1", 57120);
n.sendMsg('/play', 0, "04.wav", 1);
n.sendMsg('/playMultichan', "0,1,2,3,6,7", "blabla", 1);
n.sendMsg('/stopMultichan', "1,2,3,4,5,6", "blabla");
n.sendMsg('/stop', 0, "04.wav");
//[ /stop, 0, 04.wav ]
//[ /play, 0, 04.wav, 0.27343860268593 ]
*/
s.scope(numChannels:8);
