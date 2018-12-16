#  DeepSee_LastFactPlugin

DeepSee [plugins](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2MODADV_ch_plugin) returning the latest fact in a cell. 

### Description
### PluginLastDateTime
The Ale.PluginLastDate DeepSee Plugin returns the property of one single fact. The fact is, within the context of a cell, the one whose source record has the latest datetime stamp. 
The datetime stamp is indicated in the "datetimestamp" parameter and it must be a field of the source 
class in this format: 'YYY-MM-DD HH:MM:SS'. 
This feature is not yet available in DeepSee using "normal" cube measures or [calculated members](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2GMDX_ch_calculated_members). 

### LastFactPlugin
The Ale.LastFactPlugin DeepSee Plugin returns the property of one single fact. The fact is, within the context of a cell, the one whose source record has the highest ID. 
The word "Last" is used here because records in a source table are often added chronologically, and the ID is a good indicator of which record was most recently added to a table. 

### Install
The following commands import the plugins in the SAMPLES namespace:
```
USER>ZN "SAMPLES"
SAMPLES>W $system.OBJ.Load("/home/amarin/DeepSee_LastFactPlugin/Ale.PluginLastDateTime.cls","cf")
SAMPLES>W $system.OBJ.Load("/home/amarin/DeepSee_LastFactPlugin/Ale.LastFactPlugin.cls","cf")
```
If your instance does not support UDL formatting please use the .xml file.

### Usage
#### PluginLastDateTime
The PATIENTS cube in SAMPLES has a BirthDateTimeStamp field. The following call will return 
the most recent BirthDateTimeStamp time stamp: 
```
%KPI("PluginLastDateTime","LastDateTime",1,"datetimestamp","BirthDateTimeStamp","%CONTEXT")
```
You can create a [calculated measure](https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=D2GMDX_ch_calculated_members) with the expression above and use it in Analyzer (see figure below). This command sets a calculated measure for the PATIENTS cube with shared storage: 
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

#### LastFactPlugin
The HOLEFOODS cube in SAMPLES has a AmountOfSale field. The following call will return 
the AmountOfSale field for most recent record in the source table, where most recent is defined by the highest ID (as explained in the description): 
```
%KPI("LastFactByIDPlugin","LastFactByID",1,"outputfield","AmountOfSale","%CONTEXT")
```
MDX example in DeepSee: 
```
SAMPLES>do $System.DeepSee.Shell()
DeepSee Command Line Shell
----------------------------------------------------
Enter q to quit, ? for help.
>>SELECT {%LABEL([Measures].[Amount Sold],"","#.##"),[MEASURES].[LASTSALE]} ON 0,NON EMPTY [Product].[P1].[Product Category].Members ON 1 FROM [HOLEFOODS]
---------------------------------------------------------------------------
Elapsed time:       .328189s
Results pending...
                             Revenue             LastSale
1 Candy                        103.53                 5.75
2 Cereal                       471.38                 3.95
3 Dairy                        557.01                 5.95
4 Fruit                       1713.50                 8.95
5 Pasta                       2028.94                 6.95
6 Seafood                     3201.65                18.36
7 Snack                       4104.75                 4.25
8 Vegetable                    578.81                 5.95
```

### Limitations
This routine is **not officially supported by InterSystems Co.** I suggest using this routine only in test environments.

#### PluginLastDateTime
![Alt Text](https://github.com/aless80/DeepSee_LastFactPlugin/blob/master/last_datetime_by_doctor.png)

#### LastFactPlugin
![Alt Text](https://github.com/aless80/DeepSee_LastFactPlugin/blob/master/last_sale_by_product_category.png)

<!-- TO DO
Add a modified version of the MaxFieldPlugin in my [DeepSee_CubeManagerMonitor](https://github.com/aless80/DeepSee_CubeManagerMonitor.git) repository
-->
