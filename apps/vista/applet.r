; chl 2003-12-23

make object! [

	doc: "embeds the VanillaVista applet" 
	notes: "The containing snip must be displayed with display-asis and contain a Content-type header."
	history: [
		2003-12-23 chl "created"
	]	

	handle: func [ param /local n ] [
		foreach [ k v ] reduce [
			"[jar]" rejoin [ resource-url "vista/VanillaVista-4.jar" ]
			"[display-url-prefix]" rejoin [ vanilla-display-url ]
			"[fetch-url-prefix]" rejoin [ 
				vanilla-get-url 
				{?selector=display-asis} 
				{&snip=vanilla-vista-graph-xml}
				{&xml-for-snip=} 
			]
			"[snip-name]" either none? n: attempt [ vista-for-snip ] [ "" ] [ n ]
		] [
			replace/all template k v
		]
		template
	]

	template: {

<html>
<head>
	<title>VanillaVista</title>
</html>
<body style="margin:0px;">
<!--"CONVERTED_APPLET"-->
<!-- HTML CONVERTER -->
<SCRIPT LANGUAGE="JavaScript"><!--
    var _info = navigator.userAgent; 
    var _ns = false; 
    var _ns6 = false;
    var _ie = (_info.indexOf("MSIE") > 0 && _info.indexOf("Win") > 0 && _info.indexOf("Windows 3.1") < 0);
//--></SCRIPT>
    <COMMENT>
        <SCRIPT LANGUAGE="JavaScript1.1"><!--
        var _ns = (navigator.appName.indexOf("Netscape") >= 0 && ((_info.indexOf("Win") > 0 && _info.indexOf("Win16") < 0 && java.lang.System.getProperty("os.version").indexOf("3.5") < 0) || (_info.indexOf("Sun") > 0) || (_info.indexOf("Linux") > 0) || (_info.indexOf("AIX") > 0) || (_info.indexOf("OS/2") > 0) || (_info.indexOf("IRIX") > 0)));
        var _ns6 = ((_ns == true) && (_info.indexOf("Mozilla/5") >= 0));
//--></SCRIPT>
    </COMMENT>

<SCRIPT LANGUAGE="JavaScript"><!--
    if (_ie == true) document.writeln('<OBJECT classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" WIDTH = "100%" HEIGHT = "100%" ALIGN = "baseline"  codebase="http://java.sun.com/products/plugin/autodl/jinstall-1_4-windows-i586.cab#Version=1,4,0,0"><NOEMBED><XMP>');
    else if (_ns == true && _ns6 == false) document.writeln('<EMBED \
	    type="application/x-java-applet;version=1.4" \
            CODE = "vanillavista.VanillaVistaApplet" \
            ARCHIVE = "[jar]" \
            WIDTH = "100%" \
            HEIGHT = "100%" \
            ALIGN = "baseline" \
            displayURLPrefix ="[display-url-prefix]" \
            fetchURLPrefix ="[fetch-url-prefix]" \
            snipName ="[snip-name]" \
	    scriptable=false \
	    pluginspage="http://java.sun.com/products/plugin/index.html#download"><NOEMBED><XMP>');
//--></SCRIPT>
<APPLET  CODE = "vanillavista.VanillaVistaApplet" ARCHIVE = "[jar]" WIDTH = "100%" HEIGHT = "100%" ALIGN = "baseline"></XMP>
    <PARAM NAME = CODE VALUE = "vanillavista.VanillaVistaApplet" >
    <PARAM NAME = ARCHIVE VALUE = "[jar]" >
    <PARAM NAME="type" VALUE="application/x-java-applet;version=1.4">
    <PARAM NAME="scriptable" VALUE="false">
    <PARAM NAME = "displayURLPrefix" VALUE="[display-url-prefix]">
    <PARAM NAME = "fetchURLPrefix" VALUE="[fetch-url-prefix]">
    <PARAM NAME = "snipName" VALUE="[snip-name]">

No Java 2 SDK, Standard Edition v 1.4.2 support for APPLET!
</APPLET>
</NOEMBED>
</EMBED>
</OBJECT>

<!--
<APPLET CODE = "vanillavista.VanillaVistaApplet" ARCHIVE = "[jar]" WIDTH = "100%" HEIGHT = "100%" ALIGN = "baseline">
<PARAM NAME = "displayURLPrefix" VALUE="[display-url-prefix]">
<PARAM NAME = "fetchURLPrefix" VALUE="[fetch-url-prefix]">
<PARAM NAME = "snipName" VALUE="[snip-name]">
No Java 2 SDK, Standard Edition v 1.4.2 support for APPLET!

</APPLET>
-->
<!--"END_CONVERTED_APPLET"-->
</body>
</html>

	}

]
