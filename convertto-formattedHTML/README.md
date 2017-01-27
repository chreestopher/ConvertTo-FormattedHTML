# convertto-formattedHTML 
  
  A more complex drop in replacement for convertto-html
  Allows you to create HTML tables of arbitrary collections of homogeneous objects with diverse conditional formatting abilities.
  
  NAME
    convertto-formattedHTML
    
SYNOPSIS
    Makes an HTML table
    
    
SYNTAX
    convertto-formattedHTML [-inputObject] <PSObject> [[-TableId] <String>] [[-Tableclass] <String>] [[-TableStyle] <String>] [[-THClass] <String>] [[-THStyle] <String>] [[-style] <String>] [[-Formatting] 
    <Hashtable>] [-addReload] [<CommonParameters>]
    
    
DESCRIPTION
    Converts a collection of objects into a Stylized HTML Table.
    Accepts conditional formatting based on the values of properties of objects in the collection via a hashtable of formatting directives
    

PARAMETERS
    -inputObject <PSObject>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false
        
    -TableId <String>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Tableclass <String>
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -TableStyle <String>
        
        Required?                    false
        Position?                    4
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -THClass <String>
        
        Required?                    false
        Position?                    5
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -THStyle <String>
        
        Required?                    false
        Position?                    6
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -style <String>
        
        Required?                    false
        Position?                    7
        Default value                table {
          border-collapse: collapse;
          width: 100%;
          font-family: sans-serif;
        }
        th, td {
          padding: 8px;
          text-align: left;
          border-top: 1px solid black;
          border-bottom: 1px solid black;
          border-left: 2px solid black;
          border-right: 2px solid black;
        }
        th {
            background-color:lightgrey;
            color: black;
        }
        tr {
            background-color:#f5f5f5;
            color: black;
        }
        tr:hover{
            background-color:darkgrey !important;
            color: black !important;
        }
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Formatting <Hashtable>
        
        Required?                    false
        Position?                    8
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -addReload [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
INPUTS
    A collection of any Objects
    A hash table of formatting directives as follows:
         
     $formatting = @{
         "Completed"=@{
             "row"=@{
                 "background-color: red;"={[double]$args[0]."Completed" -lt 75}
             }
             "cell"=@{
                 "background-color: darkred !important; color: white !important" = {[double]$args[0]."Completed" -lt 70}
             }
         }
     }
You can have more than one style directive (hashtable key in the row and cell hashtables) for each row and cell for each property, if you are using more than one, make sure you use proper logic so that you exclude values that would be covered by the other style directive, unless you want to use CSS precedence to make more complex cascaded styles
    
OUTPUTS
    String of Stylized HTML Table
    
    
NOTES
    
    
        General notes
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>$collection = @(
    
    new-object psobject -property @{
                 Completed = 60
                 Status = "Failed"    
             }
             new-object psobject -property @{
                 Completed = 75
                 Status = "Success"    
             }
             new-object psobject -property @{
                 Completed = 99
                 Status = "Success"    
             }
         )
         $formatting = @{
             "Completed"=@{
                 "row"=@{
                     "background-color: red;"={[double]$_."Completed" -lt 75}
                 }
                 "cell"=@{
                     "background-color: darkred !important; color: white !important" = {[double]$_."Completed" -lt 70}
                 }
             }
         }
         $collection | convertto-formattedHTML -formatting $formatting 
    
         #Will Highlight any rows with Completed lower than 75 with red background
         #Will Highlight any cells for completed where Completed is lower than 70 with darkred background and white foreground
         #Each Property can have one row and one cell formatting directive
        
        -addReload adds javascript to reload the page every so often, useful for making dashboard scripts.

For a really quick Demo:

1) Place folder in $env:PSModulePath

2) run:
  
  import-module ConvertTo-FormattedHTML
  
3) run the following:
  
  gps | select Name, Handles, CPU | convertto-formattedHTML -formatting $formatting | out-file .\htmltest.html; invoke-item .\htmltest.html;
  
  This will create a file .\htmltest.html and open it in your default browser.

This was just an arbitrary example I decided to include to show people how to write the -formatting hashtables, its ugly and meaningless.

You would probaby be wise to setup a decent color convention for your success, warning, and error conditions, as I have done at work. Unfortunately I cant really share much about how I am using this at work.

If you have questions or concerns, feel free to raise issues or leave comments, would love to collaborate and actually complete this module.
