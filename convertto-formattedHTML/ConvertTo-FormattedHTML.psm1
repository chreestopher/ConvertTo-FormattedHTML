function start-table {
    Param(
        $id,
        $class,
        $style
    )
    $start = "<table "
    if($id){
        $start = $start + "id='$id' "
    }
    if($class){
        $start = $start + "class='$class' "
    }
    if($style){
        $start = $start + "style='$style' "
    }
    $start = $start + ">`n"
    write-output $start
}

function start-tr {
    Param(
        $id,
        $class,
        $style
    )
    $start = "`t<tr "
    if($id){
        $start = $start + "id='$id' "
    }
    if($class){
        $start = $start + "class='$class' "
    }
    if($style){
        $start = $start + "style='$style' "
    }
    $start = $start + ">`n"
    write-output $start
}

function start-td {
    Param(
        $class,
        $style
    )
    $start = "`t`t<td "
    if($class){
        $start += "class='$class' "
    }
    if($style){
        $start += "style='$style' "
    }
    $start += ">`n"
    write-output $start
}

function end-td {
    $start = "`t`t</td>`n"
    write-output $start
}

function end-tr {
    $start = "`t</tr>`n"    
    write-output $start
}

function make-th {
    Param(
        [parameter(valuefrompipeline=$true)]
        $inputObject
    )
    $start = ""
    $properties = $inputObject.psobject.properties | select -expand name
    foreach($prop in $properties){
        $start = $start + "`t`t<th>$prop</th>`n"
    }
    write-output $start
}

function end-table {
    write-output "</table>"
}

function convertto-formattedHTML{
<#
.Synopsis
   Makes an HTML table
.DESCRIPTION
   Converts a collection of objects into a Stylized HTML Table.
   Accepts conditional formatting based on the values of properties of objects in the collection via a hashtable of formatting directives 
.EXAMPLE
   PS>  $collection = @(
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

.INPUTS
   A collection of any Objects
   A hash table of formatting directives as follows:
        
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

.OUTPUTS
   String of Stylized HTML Table
.NOTES
   General notes
.FUNCTIONALITY
   Provides Stylized HTML Table of collection of data with arbitrary conditional formatting
#>  
    [cmdletbinding()]  
    Param(
        [parameter(valuefrompipeline=$true, mandatory=$true)]
        [psobject]$inputObject,

        [parameter(mandatory=$false, helpMessage="The ID to use for the table's DOM element")]
        [string]$TableId,
        
        [parameter(mandatory=$false, helpMessage="A string of css class names to use for the table's DOM element")]
        [string]$Tableclass,
        
        [parameter(mandatory=$false, helpMessage="A string of css styles to use for the table's DOM element")]
        [string]$TableStyle, 
        
        [parameter(mandatory=$false, helpMessage="A string of css class names to use for the table's TH DOM elements")]
        [string]$THClass,
        
        [parameter(mandatory=$false, helpMessage="A string of css styles to use for the table's DOM element")]
        [string]$THStyle,
        
        [parameter(mandatory=$false, helpMessage="A string of css to use as the document's base stylesheet")]
        [string]$style=@"

table {
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

"@,
        
        [parameter()]
        [hashtable]$Formatting,

        [parameter(mandatory=$false)]
        [switch]$addReload        
    )
    begin {
        $count = 0
        $output =""
        $output+=@"
<style>
$style
</style>

"@

        $output += start-table -id $TableId -class $Tableclass -style $TableStyle
        $output += start-tr -class $THClass -style $THStyle
        $ErrorActionPreference = "silentlycontinue"
    }
    process {
        foreach($obj in $inputObject){
            if($count -lt 1){
                $output += make-th -inputObject $inputObject 
                $output += end-tr
            }
            $rowStarted = $false;
            foreach($key in $formatting.keys){
                $currentFormattingITem = "";
                Write-verbose "Attempting $key with $obj"
                foreach($value in @($formatting.$key.row.keys)){
                    if(($formatting.$key.row."$value".invoke($obj))){
                        Write-verbose "$($formatting.$key.row."$value") is $true, Applying $value to ROW"
                        $currentFormattingITem+=$value
                    } else {
                        Write-verbose "$($formatting.$key.row."$value") is $false, NOT applying $value to ROW"
                    }
                }
                if(!([string]::IsNullOrEmpty($currentFormattingITem))){
                    $output += start-tr -class $class -style $currentFormattingITem
                    $rowstarted = $true;
                    break;
                }
            }
            if(!$rowStarted){
                $output += start-tr -class $class
            }
            foreach($prop in @($inputObject.psobject.properties | select -expandproperty name)){
                
                $currentFormattingITem = ""
                
                if(($formatting.keys -contains $prop)){
                    write-verbose "formatting keys -contains $prop"
                    foreach($value in $formatting.$prop.cell.keys){
                        if($formatting.$prop.cell."$value".invoke($obj)){
                            write-verbose "$($formatting.$prop.cell."$value") is $true for $prop with $obj, Applying Style $($value)"
                            write-verbose " "
                            $currentFormattingITem += $value     
                        } else {
                            write-verbose "$prop, $obj is false, Not applying style $value"
                        }
                    }
                    if(!([string]::IsNullOrEmpty($currentFormattingITem))){
                        $output += start-td -class $class -style $currentFormattingITem
                    } else {
                        $output += start-td -class $class
                    }                    
                } else {
                    $output += start-td -class $class
                }
                $output += "`t`t`t`t"+ $inputObject.$prop + "`n"
                $output += end-td
            }
            $count += 1
            $output += end-tr
        }
    }
    end {
        $output += end-table
        if($addReload.isPresent){
            $output += @"
<script>
function reload(){
    window.location.href = window.location.href
    setTimeout(reload, 30000)
}
setTimeout(function(){reload()}, 30000)
</script>
"@}
        write-output $output
    }
}

$missingFilesFormat = @{
    "AverageTime"=@{
        "row"=@{
            "background-color: red;"={[int]$args[0].AverageTime -lt [int](get-date -f "HH")}
        }
        "cell"=@{
            "background-color: darkred; color: white;"={[int]$args[0].AverageTime -lt [int]( get-date (get-date).addHours(-1) -f "HH")}
        }
    }
}

Export-ModuleMember -variable missingFilesFormat
Export-ModuleMember -function convertto-formattedHTML

function generate-formattingTemplate {
    Param(
        [hashtable[]]$properties
    )
    begin {
        $hash = @{}
    }
    process {
        foreach($property in $properties){
            $hash[$property['name']] = @{
                Row=@{
                }
                cell=@{
                
                }
            }
            write-host $property.high
            write-host $property.low
            write-host $property["name"]
            $celllookup = @{
                "background-color: darkgreen !important; color: white !important;"='{ ( [float]$PSItem.'+$property.name+' -lt ([float]'+$property.high+') ) }';
                "background-color: darkyellow !important; color: black !important;"='{( [float]$PSItem.'+$property.name+' -gt ([float]'+$property.low+') ) -and ( [float]$PSItem.'+$property.name+' -lt ('+$property.high+') ) }';
                "background-color: darkred !important; color: white !important;"='{( [float]$PSItem.'+$property.name+' -gt [float]'+$property.high+' ) }';
            }
            $rowlookup = @{
                "background-color: green; color: white;"='{( [float]$PSItem.'+$property.name+' -lt [float]'+$property.low+' ) }';
                "background-color: yellow; color: black;"='{([float]$PSItem.'+$property.name+' -gt [float]'+$property.low+' ) -and ( [float]$PSItem.'+$property["name"]+' -lt [float]'+$property.high+' ) }';
                "background-color: red; color: white;"='{( [float]$PSItem.'+$property.name+' -gt [float]'+$property.high+' ) }';
            }
            foreach($k in @($rowlookup.keys)){
                $hash[$property["name"]].row.add($k, [scriptblock]::create($rowlookup["$k"])) | out-null
            }
            foreach($h in @($celllookup.keys)){
                $hash[$property["name"]].cell.add($h, [scriptblock]::create($celllookup."$h")) | out-null
            }
        }
    }
    end {
        Write-Output $hash
    }
}

Export-ModuleMember -Function generate-formattingTemplate

$formatting = @{
    "Handles"=@{
        "row"=@{
            "background-color: red;"={[double]$args[0].handles -gt 200}
            "background-color: green;"={[double]$args[0].handles -lt 100}
        }
        "cell"=@{
            "background-color: darkred !important; color: white !important;" = {[double]$args[0].handles -gt 1000}
            "background-color: green !important; color: white !important;" = {[double]$args[0].handles -le 100}
        }
    }
    "CPU"=@{
        "row"=@{
            "background-color: red;"={[double]$args[0]."CPU" -ge 300}
            "background-color: green;"={[double]$args[0]."CPU" -le 100}
        }
        "cell"=@{
            "background-color: darkred !important; color: white !important;" = {[double]$args[0]."CPU" -gt 1000}
            "background-color: green !important; color: white !important;"={[double]$args[0]."CPU" -lt 0}
        }
    }
}

Export-ModuleMember -Variable formatting