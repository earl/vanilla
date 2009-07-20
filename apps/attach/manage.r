; 2003-07-06	earl - created
; 2003-07-09
; 2003-07-10	earl - permissions
; 2003-07-11	earl - merged store
; 2003-07-14	earl - cleanup, outfactored lib.r

make object! [

    template-main: replace/all {
	<form method="POST" enctype="multipart/form-data">	    
	    <style type="text/css">
		.att_td \^{
		    padding-top:    2px;
		    padding-bottom: 2px;
		    font-size:	    10pt;
		    font-family;    Arial, Sans-Serif;
		\^}
		.att_th \^{ 
		    border-bottom:  1px #c9c9c9 dotted; 
		    padding-top:    5px;
		    padding-bottom: 5px;
		    text-align:	    left;
		    font-size:	    10pt;
		    font-family;    Arial, Sans-Serif;
		\^}
		.att_tf \^{ 
		    border-top:	    1px #c9c9c9 dotted; 
		    padding-top:    5px;
		    padding-bottom: 5px;
		    font-size:	    10pt;
		    font-family;    Arial, Sans-Serif;
		\^}
	    </style>
	    <table 
		    cellpadding="0" cellspacing="0"
		    style="background-color: #f9f9f9; border: 1px #c9c9c9 solid;" 
		    width="100%">
		<colgroup> <col width="5%" /> <col width="80%" /> <col width="15%" /> </colgroup>
		<thead>
		    <tr class="att_tr">
			<th class="att_th"> &nbsp; </th>
			<th class="att_th"> File Name </th>
			<th class="att_th"> Size </th>
		    </tr>
		</thead>
		<tbody>
		    [entries]
		</tbody>
		<tfoot>
		    <tr>
			<td class="att_tf"> &nbsp; </td>
			<td class="att_tf" colspan="2"> 
			    <input type="submit" name="do-attach.delete" value="delete selected"> 
			</td>
		    </tr> 
		</tfoot>
	    </table>
	    <br />
	    <table>
		<tr>
		    <td class="att_td"> File: </td>
		    <td class="att_td"> <input type="file" name="attach-data"> </td>
		    <td class="att_td"> <input type="submit" name="do-attach.add-file" value="upload!" style="width: 100px;"> </td>
		</tr>
		<tr>
		    <td class="att_td"> URL: </td>
		    <td class="att_td"> <input type="url" name="attach-url"> </td>
		    <td class="att_td"> <input type="submit" name="do-attach.add-url" value="download!" style="width: 100px;"> </td>
		</tr>
	    </table>
	</form>
    } newline ""

    template-entry: replace/all {
	<tr>
	    <td class="att_td" align="center"> <input type="checkbox" name="delete-att" value="[name]"> </td>
	    <td class="att_td"> <a href="[url]">[name]</a> </td>
	    <td class="att_td"> [size-in-kbyte] kB </td>	
	</tr>
    } newline ""

    template-noentries: replace/all {
	<tr> <td> &nbsp; </td> <td class="att_td" colspan="2"> no attachments </td> </tr>
    } newline ""

    ; ---

    handle: func [ /local for-snip att-module ] [
	att-module: do load to-file rejoin [ app-dir self/package-path "lib.r" ]
	att-module/template-main: template-main
	att-module/template-entry: template-entry
	att-module/template-noentries: template-noentries

	do att-module/decode-multipart-form-data 
		any [ system/options/cgi/content-type "" ] 
		any [ attempt [ __post-data ] "" ]

	for-snip: any [ attempt [ attach-snip ] snip ]

	att-module/handle-add for-snip
	att-module/handle-delete for-snip
	return att-module/handle-list for-snip
    ]

]
