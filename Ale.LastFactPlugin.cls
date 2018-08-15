/// Ale.LastFactByIDPlugin
/// This DeepSee Plugin returns the property of one single fact. 
/// The fact is, within the context of a cell, the one whose source record has the highest ID. 
/// I use the word "Last" because records in a source table are often added chronologically. 
/// Example: create a calculated measure with expression: %KPI("LastFactByIDPlugin","LastFactByID",1,"outputfield","AmountOfSale","%CONTEXT")
/// The example above used with the Holefoods cube in SAMPLES will return the AmountOfSale of the fact with the highest ID 
Class Ale.LastFactPlugin Extends %DeepSee.KPIPlugIn
{

/// Cube(s) that this plug-in is based on.
Parameter BASECUBE = "*";

/// SourceTable
Parameter LISTINGSOURCE = "SourceTable";

Parameter PLUGINTYPE = "Pivot";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="LastFactByIDPlugin" displayName="LastFactByID" caption="LastFactByID" >
<filter name="%cube" displayName="Subject Area"/>
<filter name="%outputfield" displayName="outputfield" description="Field of source record to be returned as output"/>
<property name="LastFactByID" displayName="LastFactByID" description="" />
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
	Set tListingFields = "'ERROR:No outputfield' outputfield"
	If $IsObject(..%filterValues) {
		If (..%filterValues.%data("outputfield")'="") {		
			Set toutputfield = ..%filterValues.%data("outputfield")
			Set tListingFields = toutputfield _ " outputfield"
		}
	}
	Quit tListingFields_",%ID ID"  //Also pass the ID in case you want to use it in %OnCompute
}

/// Compute the value for the last fact using the result set.
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tErrMsg = ""
		Set tValue = ""
		Set n = 0
		While (pSQLRS.%Next(.tSC)) { 
			If $$$ISERR(tSC) {
				Set tErrMsg = $System.Status.GetErrorText(tSC)
				Quit
			}
			//Get the last fact added to the table
			Set tValue = pSQLRS.outputfield
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
		Set ..%seriesNames(1) = "LastFactByID"
		If (tErrMsg'="") {
			Set ..%data(1,"LastFactByID") = tErrMsg
		} Else {
			Set ..%data(1,"LastFactByID") = tValue
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}

