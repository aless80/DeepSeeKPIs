#  DeepSee_LastFactPlugin

DeepSee [plugin](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2MODADV_ch_plugin) returning the source property for the latest fact in a cell. 


### Description
TODO

Ale.PluginLastDate
This DeepSee Plugin returns the property of one single fact. The fact is, within the context of a cell, the one whose source record has the latest datetime stamp. 
The datetime stamp is indicated in the "datetimestamp" parameter and it must be a field of the source 
class in this format: 'YYY-MM-DD HH:MM:SS'. 

Examples: the PATIENTS cube in SAMPLES has a BirthDateTimeStamp field. The following call will return 
the most recent BirthDateTimeStamp time stamp:
%KPI("PluginLastDateTime","LastDateTime",1,"datetimestamp","BirthDateTimeStamp","%CONTEXT")
You can create a calculated measure with the expression above


Import the plugin, then set a calculated measure for the PATIENTS cube with shared storage
```
ZN "SAMPLES"



Set ^DeepSee.CalcMbrs("PATIENTS","MEASURES","LASTDATETIME")=$lb("MEASURES","LastDateTime","%KPI(""PluginLastDateTime"",""LastDateTime"",1,""datetimestamp"",""BirthDateTimeStamp"",""%CONTEXT"")","","0")
```