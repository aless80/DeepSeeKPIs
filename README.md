#  DeepSee_LastFactPlugin

DeepSee [plugin](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2MODADV_ch_plugin) returning the source property for the latest fact in a cell. 


### Description

The Ale.PluginLastDate DeepSee Plugin returns the property of one single fact. The fact is, within the context of a cell, the one whose source record has the latest datetime stamp. 
The datetime stamp is indicated in the "datetimestamp" parameter and it must be a field of the source 
class in this format: 'YYY-MM-DD HH:MM:SS'. 
This feature is not yet available in DeepSee using "normal" cube measures or [calculated members](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2GMDX_ch_calculated_members). 

WORK IN PROGRESS for Ale.LastFactPlugin.xml

### Install
The following commands import the plugin in the SAMPLES namespace:

```
USER>ZN "SAMPLES"

SAMPLES>W $system.OBJ.Load("/home/amarin/DeepSee_LastFactPlugin/Ale.PluginLastDateTime","cf")
Load started on 08/15/2018 10:58:44
Loading file /home/amarin/DeepSee_LastFactPlugin/Ale.PluginLastDateTime as xml
Imported class: Ale.PluginTest
Compiling class Ale.PluginTest
Compiling routine Ale.PluginTest.1
Load finished successfully.
1
```


### Usage
The PATIENTS cube in SAMPLES has a BirthDateTimeStamp field. The following call will return 
the most recent BirthDateTimeStamp time stamp: 
%KPI("PluginLastDateTime","LastDateTime",1,"datetimestamp","BirthDateTimeStamp","%CONTEXT")

You can create a [calculated measure](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2GMDX_ch_calculated_members) with the expression above and use it in Analyzer (see picture). This command sets a calculated measure for the PATIENTS cube with shared storage: 
```
SAMPLES>Set ^DeepSee.CalcMbrs("PATIENTS","MEASURES","LASTDATETIME")=$lb("MEASURES","LastDateTime","%KPI(""PluginLastDateTime"",""LastDateTime"",1,""datetimestamp"",""BirthDateTimeStamp"",""%CONTEXT"")","","0")
```

MDX example in DeepSee: 
```
SAMPLES>do $System.DeepSee.Shell()
DeepSee Command Line Shell
----------------------------------------------------
Enter q to quit, ? for help.
>>SELECT {[Measures].[%COUNT],[MEASURES].[LASTDATETIME]} ON 0,NON EMPTY [DocD].[H1].[Doctor].&[15] ON 1 FROM [PATIENTS]
                       Patient Count         LastDateTime
Zemaitis, Aviel                    30   2005-04-13 20:23:16
---------------------------------------------------------------------------
Elapsed time:       .021952s
```
This query shows that a Doctor has 30 patients facts. The latest BirthDateTimeStamp is shown in the second column
