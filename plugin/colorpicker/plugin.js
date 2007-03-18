/* DHTML Color Picker, Programming by Ulyses, ColorJack.com */

function $(v) { return(document.getElementById(v)); }
function $S(v) { return($(v).style); }
function browser(v) { return(Math.max(navigator.userAgent.toLowerCase().indexOf(v),0)); }
function toggle(v) { $S(v).display=($S(v).display=='none'?'block':'none'); }
function within(v,a,z) { return((v>=a && v<=z)?true:false); }
function XY(e,v) { var z=browser('msie')?Array(event.clientX+document.body.scrollLeft,event.clientY+document.body.scrollTop):Array(e.pageX,e.pageY); return(z[zero(v)]); }
function zero(v) { v=parseInt(v); return(!isNaN(v)?v:0); }
function zindex(d) { d.style.zIndex=zINDEX++; }

/* PLUGIN */

var maxValue={'h':'359','s':'100','v':'100'},HSV={0:359,1:100,2:100};
var SVHeight=165,wSV=162,wH=162,slideHSV={0:359,1:100,2:100},zINDEX=15,stop=1;

function HSVslide(d,o,e) {

	function tXY(e) { tY=XY(e,1)-top; tX=XY(e)-left; }
	function mkHSV(a,b,c) { return(Math.min(a,Math.max(0,Math.ceil((parseInt(c)/b)*a)))); }
	function ckHSV(a,b) { if(within(a,0,b)) return(a); else if(a>b) return(b); else if(a<0) return('-'+oo); }
	function drag(e) { if(!stop) {
	
		if(d=='SVslide') { tXY(e); ds.left=ckHSV(tX-oo,wSV)+'px'; ds.top=ckHSV(tY-oo,wSV)+'px';
		
			slideHSV[1]=mkHSV(100,wSV,ds.left); slideHSV[2]=100-mkHSV(100,wSV,ds.top); HSVupdate();
			
		}
		else if(d=='Hslide') {
		
			tXY(e); ds.top=(ckHSV(tY-oo,wH)-5)+'px'; slideHSV[0]=mkHSV(359,wH,ds.top);
 
			function commit() { var r='hsv',z={},j='';

				for(var i=0; i<=r.length-1; i++) { j=r.substr(i,1); z[i]=(j=='h')?maxValue[j]-mkHSV(maxValue[j],wH,ds.top):HSV[i]; }
				
				return(HSVupdate(hsv2hex(z)));

			}

			mkColor(commit()); $S('SV').backgroundColor='#'+hsv2hex(Array(HSV[0],100,100));
		
		}
		else if(d=='drag') { ds.left=XY(e)+oX-eX+'px'; ds.top=XY(e,1)+oY-eY+'px'; }

	}}

	if(stop) { stop=''; var ds=$S(d!='drag'?d:o);

		if(d=='drag') { var oX=parseInt(ds.left), oY=parseInt(ds.top), eX=XY(e), eY=XY(e,1); zindex($(o)); }
		else { var left=($(o).offsetLeft+10), top=($(o).offsetTop+22), tX, tY, oo=(d=='Hslide')?2:4; if(d=='SVslide') slideHSV[0]=HSV[0]; }

		document.onmousemove=drag; document.onmouseup=function(){ stop=1; document.onmousemove=''; document.onmouseup=''; }; drag(e);

	}
}

function HSVupdate(v) { HSV=v?hex2hsv(v):Array(slideHSV[0],slideHSV[1],slideHSV[2]);

	if(!v) v=hsv2hex(Array(slideHSV[0],slideHSV[1],slideHSV[2]));
	
	mkColor(v);
	//$('plugHEX').innerHTML=v;
	return(v);

}

function loadSV() { var z=''; for(var i=SVHeight; i>=0; i--) z+="<div style=\"background: #"+hsv2hex(Array(Math.round((359/SVHeight)*i),100,100))+";\"><br /><\/div>"; $('Hmodel').innerHTML=z; }

function updateH(v) { HSV=hex2hsv(v);

	$S('SV').backgroundColor='#'+hsv2hex(Array(HSV[0],100,100)); 
	$S('SVslide').top=(parseInt(wSV-wSV*(HSV[2]/100))-4)+'px';
	$S('SVslide').left=parseInt(wSV*(HSV[1]/100))+'px';
	$S('Hslide').top=(parseInt(wH*((maxValue['h']-HSV[0])/maxValue['h']))-7)+'px';

}

/* CONVERSIONS */

function toHex(v) { v=Math.round(Math.min(Math.max(0,v),255)); return("0123456789ABCDEF".charAt((v-v%16)/16)+"0123456789ABCDEF".charAt(v%16)); }
function hex2rgb(r) { return({0:parseInt(r.substr(0,2),16),1:parseInt(r.substr(2,2),16),2:parseInt(r.substr(4,2),16)}); }
function rgb2hex(r) { return(toHex(r[0])+toHex(r[1])+toHex(r[2])); }
function hsv2hex(h) { return(rgb2hex(hsv2rgb(h))); }	
function hex2hsv(v) { return(rgb2hsv(hex2rgb(v))); }

function rgb2hsv(r) { // easyrgb.com/math.php?MATH=M20#text20

	var max=Math.max(r[0],r[1],r[2]),delta=max-Math.min(r[0],r[1],r[2]),H,S,V;
	
	if(max!=0) { S=Math.round(delta/max*100);

		if(r[0]==max) H=(r[1]-r[2])/delta; else if(r[1]==max) H=2+(r[2]-r[0])/delta; else if(r[2]==max) H=4+(r[0]-r[1])/delta;

		var H=Math.min(Math.round(H*60),360); if(H<0) H+=360;

	}

	return({0:H?H:0,1:S?S:0,2:Math.round((max/255)*100)});

}

function hsv2rgb(r) { // easyrgb.com/math.php?MATH=M21#text21

	var R,B,G,S=r[1]/100,V=r[2]/100,H=r[0]/360;

	if(S>0) { if(H>=1) H=0;

		H=6*H; F=H-Math.floor(H);
		A=Math.round(255*V*(1.0-S));
		B=Math.round(255*V*(1.0-(S*F)));
		C=Math.round(255*V*(1.0-(S*(1.0-F))));
		V=Math.round(255*V); 

		switch(Math.floor(H)) {

			case 0: R=V; G=C; B=A; break;
			case 1: R=B; G=V; B=A; break;
			case 2: R=A; G=V; B=C; break;
			case 3: R=A; G=B; B=V; break;
			case 4: R=C; G=A; B=V; break;
			case 5: R=V; G=A; B=B; break;

		}

		return({0:R?R:0,1:G?G:0,2:B?B:0});

	}
	else return({0:(V=Math.round(V*255)),1:V,2:V});

}