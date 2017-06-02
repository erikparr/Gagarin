var gui, buffers, monoStereoSampleDirectory, monoStereoSampleDirectoryName, osc, osc1,osc2, osc3, osc4, osc5,osc6, cond, notes, dBufIndex,dNotes;
var windowWidth, windowHeight, textWidth, textHeight, projectDirectory,initFilePath;
var projectDirectoryText, monoStereoSampleDirectoryText, multichannelSampleDirectory;
var multichannelSampleDirectoryText, isSystemReady, loadBuffers, loadMultichanBuffers, initAndLoadBuffers;

Server.default = s = Server.local;
s.options.outDevice = "Windows DirectSound";
s.options.inDevice = "Windows DirectSound";
s.options.numOutputBusChannels = 4;

cond = Condition.new;
dBufIndex=Dictionary.new;
dNotes=Dictionary.new;
"RUNNING MULTICHANNEL SAMPLER".postln;
SynthDef ("monoPlay", {arg  bufnum, bus, dur, amp=1, gate=1, fadeIn, fadeOut;
	var in, env;
	in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop:1, doneAction:2);
	env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [fadeIn, 1.0-(fadeIn+fadeOut), fadeOut], \sin, releaseNode:2, loopNode:2), gate, timeScale: dur, doneAction:2);
	Out.ar(bus, in * env*amp );
}).add;


SynthDef ("stereoPlay", {arg  bufnum, bus, dur, amp=1, gate=1, fadeIn, fadeOut;
	var in, env;
	in = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop:1, doneAction:2);
	env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [fadeIn, 1.0-(fadeIn+fadeOut), fadeOut], \sin, releaseNode:2, loopNode:2), gate, timeScale: dur, doneAction:2);
	Out.ar(bus, in * env*amp );
}).add;

SynthDef ("multiPlay", {arg  bufnum, bus, dur, amp, gate=1, fadeIn, fadeOut;
	var in, env;
	in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),  loop:1, doneAction:2);
	env = EnvGen.ar(Env([0.0, 1.0, 1.0, 0.0], [fadeIn, 1.0-(fadeIn+fadeOut), fadeOut], \sin, releaseNode:2, loopNode:2), gate, timeScale: dur, doneAction:2);
	Out.ar(bus, in * env*amp );
}).add;

s.waitForBoot({




	//---------------------------------------------------------------------
	//---------------------------------------------------------------------
	//---------------------------------------------------------------------
	//---------------------------------------------------------------------

	// channelSelect = Dictionary.new;
	projectDirectory = "C:\\directory\\path\\here\\";
	multichannelSampleDirectory = "C:\\multichannel\\sample\\path\\here\\";
	monoStereoSampleDirectory = "C:\\monoAndStereo\\samples\\path\\here\\";

	gui = {

		windowWidth = 600;
		windowHeight = 300;
		textWidth= 600;
		textHeight=20;

		w = Window.new("Multichannel Sampler Setup", Rect(0,0,windowWidth,windowHeight)).front;
		//--------
		// a = StaticText(w, Rect((w.bounds.width/2)-(textWidth/2), 10, textWidth,textHeight));
		// a.string = "Project Directory Path";
		// a.align_(\left);
		// a.font_( "Helvetica", 11);
		//--------
		// projectDirectoryText = TextField(w, Rect((w.bounds.width/2)-(textWidth/2), 30, textWidth,textHeight))
		// .string_(projectDirectory);
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
		b.action = {var index;
			projectDirectory = projectDirectoryText.value;
			multichannelSampleDirectory = multichannelSampleDirectoryText.value;
			monoStereoSampleDirectory = monoStereoSampleDirectoryText.value;
			"writing to: ".post; initFilePath.postln;
			f = File(initFilePath, "w");
			f.write(projectDirectory++"\n"++multichannelSampleDirectory++"\n"++monoStereoSampleDirectory);
			f.close;
			// buffers.free;
			// loadBuffers.value;
			// loadMultichanBuffers.value;
	initAndLoadBuffers.value;

			// //this should be inside a function
			// Platform.case(
			// 	\osx,       { initFilePath = Platform.userHomeDir++"/input.sc" },
			// \windows,   { initFilePath = Platform.userHomeDir++"\input.sc"; });
			// if(FileReader.read(initFilePath) == nil,{
			// 	"loading gui".postln;
			// 	gui.value;
			// 	isSystemReady=false;
			// 	},{
			// 		projectDirectory = FileReader.read(initFilePath).flatten[0].asString;
			// 		multichannelSampleDirectory = FileReader.read(initFilePath).flatten[1].asString;
			// 		monoStereoSampleDirectory = FileReader.read(initFilePath).flatten[2].asString;
			// 		loadBuffers.value;
			// 		loadMultichanBuffers.value;
			// 		isSystemReady=true;
			// });

		};

	};








	//------Load the buffers here -------
	//-------This is executed either manually, when the Save button is pressed---------------
	//-------Or at startup, if an init file exists. (copy-pasted, but should be a task and called twice)-----

	loadBuffers={
		"system is ready. Loading buffers...".postln;

		// load buffers
		"monoStereoSampleDirectory: ".post; monoStereoSampleDirectory.postln;
		//***NOTE*** expects wav format
		buffers = (monoStereoSampleDirectory ++ "*").pathMatch.collect{arg path, i;
			var buf;

			//add to dictionary by following format: "multichannelSampleDirectory-filename.wav"
			Platform.case(
				\osx,       { monoStereoSampleDirectoryName = path.split },
				\windows,   { monoStereoSampleDirectoryName = path.split($\\); });
			monoStereoSampleDirectoryName = monoStereoSampleDirectoryName[monoStereoSampleDirectoryName.size-2];
			dBufIndex.add(monoStereoSampleDirectoryName++"-"++PathName.new(path).fileName -> i);

			buf = Buffer.read(s, path, action: {cond.test_(true).signal});
			// cond.wait;
			// cond.test_(false);
			buf;
		};
	};


	loadMultichanBuffers={ var index;

		index = dBufIndex.size;
		//iterate through list of subfolders (no files should be at this level)
		(multichannelSampleDirectory++"*").pathMatch.do{arg path, i;
			"path: ".post; path.postln;
			//collect all the multichan buffers and add them to  primary buffer array
			(path ++ "*").pathMatch.do{arg soundfilepath, j; var buf, multichannelSampleDirectoryName;
				"soundfilepath: ".post;soundfilepath.postln;
				if(PathName.new(soundfilepath).isFile){
					//add to dictionary by following format: "multichannelSampleDirectory-filename.wav"
					Platform.case(
						\osx,       { multichannelSampleDirectoryName = soundfilepath.split },
						\windows,   { multichannelSampleDirectoryName = soundfilepath.split($\\); });

					multichannelSampleDirectoryName = multichannelSampleDirectoryName[multichannelSampleDirectoryName.size-2];
					dBufIndex.add(multichannelSampleDirectoryName++"-"++PathName.new(soundfilepath).fileName -> index);
					index=index+1;

					buf = Buffer.read(s, soundfilepath);
					buffers=buffers++buf;
					"buffers size:: ".post; buffers.size.postln;
				};
			};
		};
		"buffers size: ".post;buffers.size.postln;
	};

initAndLoadBuffers = {

	//this should be inside a function
		initFilePath = Platform.userConfigDir++Platform.pathSeparator++"input.sc";

	if(FileReader.read(initFilePath) == nil,{
		"loading gui".postln;
		gui.value;
		isSystemReady=false;
	},{
		projectDirectory = FileReader.read(initFilePath).flatten[0].asString;
		multichannelSampleDirectory = FileReader.read(initFilePath).flatten[1].asString;
		monoStereoSampleDirectory = FileReader.read(initFilePath).flatten[2].asString;
		loadBuffers.value;
		loadMultichanBuffers.value;
		isSystemReady=true;
	});
	};
	initAndLoadBuffers.value;
	// "loading gui".postln;
	// projectDirectory = FileReader.read(initFilePath).flatten[0].asString;
	// multichannelSampleDirectory = FileReader.read(initFilePath).flatten[1].asString;
	// monoStereoSampleDirectory = FileReader.read(initFilePath).flatten[2].asString;
	// gui.value;
	//
	// loadBuffers.value;
	// loadMultichanBuffers.value;

	// if(isSystemReady==true,{
	// 	loadBuffers.value;
	// 	loadMultichanBuffers.value;
	// 	"buffers loaded".postln;
	// 	},{
	// 		"system is not ready. Please set sample directory paths".postln;
	// });



	osc = OSCFunc({ arg msg, time;
		var  outbus, filename, amp, bufferID, noteID, fadeIn, fadeOut;
		msg.postln;
		outbus = msg[1];
		filename = msg[2].asString; // dont forget asString
		amp = msg[3];
		fadeIn = msg[4].asFloat;
		fadeOut = msg[5].asFloat;
		bufferID = dBufIndex.at(monoStereoSampleDirectoryName++"-"++filename);
		noteID = outbus.asString++"-"++filename; //create unique noteid based on filename and output speaker
		"duration: ".post; buffers[bufferID].duration.postln;
		"play: ".post; noteID.postln;
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		if(buffers[bufferID].numChannels==1,{
			dNotes.add(noteID -> Synth("monoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", buffers[bufferID].duration, "fadeIn", fadeIn, "fadeOut", fadeOut, "amp", amp, "gate", 1]));
			"playing mono".postln;
		},{
			dNotes.add(noteID -> Synth("stereoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", buffers[bufferID].duration, "fadeIn", 0.05, "fadeOut", 0.5, "amp", amp, "gate", 1]));
			"playing stereo".postln;
		});
		//-------------------------------


	}, '/play');

	osc1 = OSCFunc({ arg msg, time;
		var  outbus, filename, noteID,stopNote,fadeOut;
		msg.postln;
		outbus = msg[1];
		filename = msg[2].asString; // dont forget asString
		fadeOut = (msg[3].asFloat * -1) + (-1); // gate release fade out time = -1 - fadeoutTime
		noteID = outbus.asString++"-"++filename;
		stopNote = dNotes.at(noteID.asString);
		"fadeOut: ".post; fadeOut.postln;
		stopNote.set("gate",fadeOut);
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
		var  outbusArray, outbusArrayName, replaceArray, ampArray, directoryName, amp, bufferID, noteID, totalSoundfiles, filenames, fadeIn, fadeOut;
		outbusArrayName="";
		directoryName = msg[2].asString; // dont forget asString
		amp = msg[3];
		fadeIn = msg[4].asFloat;
		fadeOut = msg[5].asFloat;

		filenames = (multichannelSampleDirectory ++directoryName++"/" "*").pathMatch.collect{arg path, i;
			totalSoundfiles = i+1;
			PathName.new(path).fileName
		};

		//outbusArray allows flexibility with output channel playback, can play x num of y total sound files
		replaceArray = msg[1].asString.split($,);
		"replaceArray size: ".post; replaceArray.size.postln;
		"totalSoundfiles size: ".post; totalSoundfiles.postln;
		outbusArray = Array.fill(totalSoundfiles,0); // num outbusses = num total sound files in dir
		outbusArray.do{arg channelString; channelString.postln; outbusArrayName =outbusArrayName++channelString.asString; };
		"outbusArrayName: ".post; outbusArrayName.postln;
		ampArray = Array.fill(totalSoundfiles,0); // num outbusses = num total sound files in dir
		replaceArray.do({arg item, i;
			outbusArray[i] = item;
			ampArray[i] = amp;
		});
		"outbusArray ready".postln;
		outbusArray.postln;
		ampArray.postln;
		filenames.postln;
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		totalSoundfiles.do{arg i;
			bufferID = dBufIndex.at(directoryName++"-"++filenames[i]);
			"buffer: ".post;bufferID.postln;
			noteID = outbusArrayName.asString++"-"++directoryName++"-"++i; //create unique noteid based on filename + output speaker + filenum
			dNotes.add(noteID -> Synth("multiPlay", ["bufnum", buffers[bufferID], "bus", outbusArray[i].asInt, "dur", buffers[bufferID].duration, "fadeIn", fadeIn, "fadeOut", fadeOut, "amp", ampArray[i].asInt, "gate", 1]));
		};
		"playing multichan".postln;

	}, '/playMultichan');

	// //stop multichannel
	osc4 = OSCFunc({ arg msg, time;
		var  outbusArray, replaceArray, outbusArrayName, directoryName, bufferID, noteID, totalSoundfiles, filenames, stopNote, fadeOut;

		outbusArray = msg[1].asString.split($,);
		outbusArray.do{arg channelString; outbusArrayName =outbusArrayName++channelString; };
		directoryName = msg[2].asString; // dont forget asString
		fadeOut = (msg[3].asFloat * -1) + (-1); // gate release fade out time = -1 - fadeoutTime
		filenames = (multichannelSampleDirectory ++directoryName++"/" "*").pathMatch.collect{arg path, i;
			path.postln;
			totalSoundfiles = i+1;
			PathName.new(path).fileName
		};
		//----Stop the note by releasing gate--------------
		totalSoundfiles.do{arg i;
			bufferID = dBufIndex.at(directoryName++"-"++filenames[i]);
			noteID = outbusArrayName.asString++"-"++directoryName++"-"++i; //create unique noteid based on filename + output speaker + filenum
			"stop: ".post; noteID.postln;
			stopNote = dNotes.at(noteID.asString);
			stopNote.set("gate",fadeOut);

		};
		"stop multichan".postln;

	}, '/stopMultichan');


	osc5 = OSCFunc({ arg msg, time;
		var  outbus, filename, amp, bufferID, noteID, fadeIn, fadeOut, duration;
		msg.postln;
		outbus = msg[1];
		filename = msg[2].asString; // dont forget asString
		amp = msg[3];
		fadeIn = msg[4].asFloat;
		fadeOut = msg[5].asFloat;
		duration = msg[6].asFloat;
		bufferID = dBufIndex.at(monoStereoSampleDirectoryName++"-"++filename);
		noteID = outbus.asString++"-"++filename; //create unique noteid based on filename and output speaker
		"duration: ".post; buffers[bufferID].duration.postln;
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		if(buffers[bufferID].numChannels==1,{
			dNotes.add(noteID -> Synth("monoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", duration, "fadeIn", fadeIn, "fadeOut", fadeOut, "amp", amp, "gate", 1]));
			"playing mono".postln;
		},{
			dNotes.add(noteID -> Synth("stereoPlay", ["bufnum", buffers[bufferID], "bus", outbus, "dur", duration, "fadeIn", 0.05, "fadeOut", 0.5, "amp", amp, "gate", 1]));
			"playing stereo".postln;
		});
		//-------------------------------


	}, '/loop');


	// //loop multichannel
	osc6 = OSCFunc({ arg msg, time;
		var  outbusArray, outbusArrayName,  replaceArray, ampArray, directoryName, amp, bufferID, noteID, totalSoundfiles, filenames, fadeIn, fadeOut, duration;
		outbusArrayName = "";
		directoryName = msg[2].asString; // dont forget asString
		amp = msg[3];
		fadeIn = msg[4].asFloat;
		fadeOut = msg[5].asFloat;
		duration = msg[6].asFloat;
		"PATH: ".post; multichannelSampleDirectory ++directoryName++"/".postln;
		filenames = (multichannelSampleDirectory ++directoryName++"/" "*").pathMatch.collect{arg path, i;
			path.postln;

			totalSoundfiles = i+1;
			PathName.new(path).fileName
		};

		//outbusArray allows flexibility with output channel playback, can play x num of y total sound files
		replaceArray = msg[1].asString.split($,);
		"replaceArray size: ".post; replaceArray.size.postln;
		"totalSoundfiles size: ".post; totalSoundfiles.postln;
		outbusArray = Array.fill(totalSoundfiles,0); // num outbusses = num total sound files in dir
		replaceArray.do{arg channelString; outbusArrayName =outbusArrayName++channelString.asString; };
		ampArray = Array.fill(totalSoundfiles,0); // num outbusses = num total sound files in dir
		replaceArray.do({arg item, i;
			outbusArray[i] = item;
			ampArray[i] = amp;
		});
		"outbusArray ready".postln;
		outbusArray.postln;
		ampArray.postln;

		filenames.postln;
		//-------------------------------
		//----Play the note----------------
		//-------------------------------
		totalSoundfiles.do{arg i;
			bufferID = dBufIndex.at(directoryName++"-"++filenames[i]);
			"buffer: ".post;bufferID.postln;
			noteID = outbusArrayName.asString++"-"++directoryName++"-"++i; //create unique noteid based on filename + output speaker + filenum
			"loop: ".post; noteID.postln;
			dNotes.add(noteID -> Synth("multiPlay", ["bufnum", buffers[bufferID], "bus", outbusArray[i].asInt, "dur", duration, "fadeIn", fadeIn, "fadeOut", fadeOut, "amp", ampArray[i].asInt, "gate", 1]));
		};
		"playing multichan".postln;

	}, '/loopMultichan');


});

/*
n = NetAddr("127.0.0.1", 57120);
n.sendMsg('/play', 0, "04.wav", 1, 0.05, 0.5);
n.sendMsg('/loop', 0, "04.wav", 1, 0.05, 0.5, 10);
n.sendMsg('/stop', 0, "04.wav", 0.5);
n.sendMsg('/loopMultichan', "1,2,3,4,5", "blabla", 1, 0.05, 0.5, 15);
n.sendMsg('/playMultichan', "1,2,3,4,5", "blabla", 1, 0.05, 0.5);
n.sendMsg('/stopMultichan', "1,2,3,4,5", "blabla", 1);
//[ /stop, 0, 04.wav ]
//[ /play, 0, 04.wav, 0.27343860268593 ]
*/
s.scope(numChannels:8);