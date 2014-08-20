s.boot
p = [ 544.1, 544.1, 544.2, 544.2, 544.7, 544.7, 545, 545, 545, 545, 545, 545.2, 545.2, 545.2, 545.2, 545.2, 545.2, 545.2, 545.2, 545.3, 545.3, 545.3, 545.3, 545.3, 545.3, 545.3, 545.3, 545.3, 545.3, 545.4, 545.4, 545.4, 545.4, 545.4, 545.5, 545.5, 545.5, 545.5, 545.5, 545.5, 545.5, 545.5, 545.5, 545.6, 545.6, 545.7, 545.7, 545.7, 545.7, 545.7, 545.7, 545.7, 545.8, 545.8, 545.8, 545.8, 545.9, 545.9, 545.9, 545.9, 545.9, 546, 546, 546.1, 546.1, 546.2, 546.2, 546.2, 546.2, 546.3, 546.3, 546.4, 546.4, 546.4];
(
Routine({
	var total, sIndex, eIndex, range, mRange, count;
	total=0;//total count
	sIndex=0;//start index
	eIndex=0;//end index
	range=p.size-1; // size of array
	p.size.do({arg i;
		count=0;
		mRange = range-i;
		while ( { ( ((p[i]-p[min(i+count, range)]).abs < 2.0) && (count<mRange)) }, {
			if(count>total,{
				total=count; sIndex=i; eIndex=(i+count);
			});
			count = count + 1;
});
		"total run: ".post; total.postln; "start index: ".post; sIndex.postln; "end index: ".post; eIndex.postln; "i:".post; i.postln;(p[i]-p[min(i+count, range)]).abs.postln; "---".postln;
		"start freq: ".post; p[sIndex].postln; "end freq: ".post; p[eIndex].postln;
});}).play;
)
