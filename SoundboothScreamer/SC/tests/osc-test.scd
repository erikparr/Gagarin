s.boot
n = NetAddr("192.168.2.2", 57120); // the url should be the one of computer of app 2 (or nil)
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; msg[1].postln; n }, '/1/toggle1');
o.free;    // remove the OSCresponderNode when you are done.