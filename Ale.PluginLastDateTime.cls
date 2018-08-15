/// Ale.PluginLastDateTime
/// This DeepSee Plugin returns the property of one single fact. 
/// The fact is, within the context of a cell, the one whose source record has the latest datetime stamp. 
/// The datetime stamp is indicated in the "datetimestamp" parameter and it must be a field of the source 
/// class in this format: 'YYY-MM-DD HH:MM:SS'. 
/// Examples: the PATIENTS cube in SAMPLES has a BirthDateTimeStamp field. The following call will return 
/// the most recent BirthDateTimeStamp time stamp:
/// %KPI("PluginLastDateTime","LastDateTime",1,"datetimestamp","BirthDateTimeStamp","%CONTEXT")
/// You can create a calculated measure with the expression above
Class Ale.PluginLastDateTime Extends %DeepSee.KPIPlugIn
{

/// Cube(s) that this plug-in is based on.
Parameter BASECUBE = "*";

/// SourceTable
Parameter LISTINGSOURCE = "SourceTable";

Parameter PLUGINTYPE = "Pivot";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="PluginLastDateTime" displayName="PluginLastDateTime" caption="PluginLastDateTime" >
<filter name="%cube" displayName="Subject Area"/>
<filter name="%datetimestamp" displayName="datetimestamp" description="Field of source record to be returned as output"/>
<filter name="%comparefield" displayName="comparefield"  description="Field of source record to maximize (%ID by default). The fact corresponding to the source record with maximum comparefield will be returned. %ID breaks ties"/>
<property name="LastDateTime" displayName="LastDateTime" description="" />

</kpi>
}

/// Get the base query for this plug-in.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
	Set tBaseCube = ""
	// Use %cube filter to find the base cube
	If $IsObject(..%filterValues) {
		If (..%filterValues.%cube'="") {
			Set tBaseCube = ..%filterValues.%cube
		}
	}
	If (tBaseCube'="") {
		Set pMDX = "SELECT FROM "_tBaseCube
	}
	Quit $$$OK
}

/// Returns the field list (RETURN clause) of the listing used to supply data for this plug-in.
/// In this case, determine which field in the source table we need.
Method %OnGetListingFields() As %String
{
	Set tListingFields = "'ERROR:No datetimestamp' datetimestamp"
	If $IsObject(..%filterValues) {
		If (..%filterValues.%data("datetimestamp")'="") {		
			Set tdatetimestamp = ..%filterValues.%data("datetimestamp")
			Set tListingFields = tdatetimestamp _ " datetimestamp"
			Set tcomparefield = "tdatetimestamp"
		}
	}
	Quit tListingFields _",%ID ID"  //Also pass the ID in case you want to use it in %OnCompute
}

/// Compute the value for the last fact using the result set.
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tValue = ""
		Set tErrMsg = ""
		Set highest = ""
		Set n = 0
		While (pSQLRS.%Next(.tSC)) { 
			If $$$ISERR(tSC) {
				Set tErrMsg = $System.Status.GetErrorText(tSC)
				Quit
			}
	   		//Get the number of seconds from a platform-specific origin date/time. Use that to get the most recent date
	   		//%ID breakes ties in case of identical datetime stamps
	   		Set numSecs = $ZDT($ZDTH(pSQLRS.datetimestamp,3),-2)
	   		if (numSecs >= highest) {
     			Set tValue = pSQLRS.datetimestamp
     			Set highest = $ZDT($ZDTH(pSQLRS.datetimestamp,3),-2)
  			}
			If ($ZSTRIP($P(tValue,":"),"<>W")="ERROR") {
				Set tErrMsg = $P(tValue,":",2)
				Quit
			}
			// update pct complete
			Set n = n + 1
			If (n#100 = 0) {
				Do ..%SetPercentComplete(100*(n/pFactCount))
			}
		}
		// place answer in KPI output
		Set ..%seriesCount = 1
		Set ..%seriesNames(1) = "LastDateTime"
		If (tErrMsg'="") {
			Set ..%data(1,"LastDateTime") = tErrMsg
		} Else {
			Set ..%data(1,"LastDateTime") = tValue
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}

