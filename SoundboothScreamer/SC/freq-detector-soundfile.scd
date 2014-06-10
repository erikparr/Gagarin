Server.local.options.device_("MOTU");
s.options.sampleRate = 48000;
s.reboot;




//------------------------------
// register to receive this message
(
//-- load newly recorded sound sample into buffer
~buf = Buffer.read(s, "/Users/erikwp/Documents/_Studio/2014-work/Gagarin/SoundboothScreamer/SC/samples/diskouttest.aiff");

//remove previous ==
p.size.do({	p.removeAt(0)});≥
r.remove; // don't forget to remove the responder once you're done

//==
p = Array.newClear;
r = OSCresponderNode(s.addr,'/tr',{ arg time, responder, msg;
	var pitch = msg[3];
	// [time,responder,msg].postln;
		// msg[3].postln;
	if((pitch>500) &&(pitch<900),{
		p = p.add(pitch);});
}).add;
)
x = Synth(\playback, [\bufnum, ~buf.bufnum]);
difference
(
p=p.sort.round(0.1);

q=0;//total count
r=0;//start index
t=0;//end index
p.size.do({arg i;
	c=0;
	while({(abs(p.at(i) - p.at(i+c))<2) && (i+c<10)},{c=c+1});
	if(c>q,{q=c; r=i; t=(i+c)});
		c.postln;
	});
b = p.as(Bag);
c=b.contents;
e = 0;
c.size.do({|i| if(c.values.at(i)>e,{e = c.values.at(i); e.postln})});
p.plot("Freqs",discrete: true);
f = c.findKeyForValue(e);

)
p.mean
y = Synth(\deathByAudio, [\freq, 603]);

(
p.size.do({	p.removeAt(0)});
r.remove; // don't forget to remove the responder once you're done
~buf.free;
)
