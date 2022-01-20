<#
  .SYNOPSIS
    A module to provide slightly less basic output messages via 3 separate levels - Info, Debug and Error.

  .DESCRIPTION
    The code allows a script to output messages (via Write-Host) at 3 separate levels (Info, Debug and Error).
    Controlling whether the messages are output or not is the responsibility of the script importing the functionality
    (i.e. these methods do no checking to verify a "Debug" flag is present before outputting a debug level message).

    Messages are of the format:
        [SYMBOL] Message
    Where the symbol and colour of the symbol can be configured. Messages can also be indented.
#>

# Settings for each output level
$MessageConfig = @{
    Info = @{
        Label = "*"
        LabelColor = "Cyan"
        IndentLabel = "-"
    }
    Debug = @{
        Label = ">"
        LabelColor = "Green"
    }
    Error = @{
        Label = "!"
        LabelColor = "Red"
        PrintLabelOnIndent = $false
    }
    Input = @{
        Label = "?"
        LabelColor = "Green"
    }
}

Enum MessageLevel {
    DEBUG  = 1
    INFO   = 2
    ERROR  = 3
    SILENT = 4
}

$global:CurrentMessageLevel = [MessageLevel]::INFO

function Set-MessageLevel {
    param(
        [MessageLevel]$Level
    )

    $global:CurrentMessageLevel = $Level
}

function Get-MessageLevel {
    return $global:CurrentMessageLevel
}

function Write-Info {
    param(
        [string] $Message,
        [int]    $Indent = 0,
        [bool]   $NoNewline = $false
    )

    if ([MessageLevel]::INFO -ge $global:CurrentMessageLevel) {
        Do-Write-With-Config -Message $Message -Indent $Indent -Config $MessageConfig.Info -NoNewLine $NoNewline
    }
}

function Write-Debug {
    param(
        [string] $Message,
        [int]    $Indent = 0,
        [bool]   $NoNewline = $false
    )

    if ([MessageLevel]::DEBUG -ge $global:CurrentMessageLevel) {
        Do-Write-With-Config -Message $Message -Indent $Indent -Config $MessageConfig.Debug -NoNewLine $NoNewline
    }
}

function Write-Error {
    param(
        [string] $Message,
        [int]    $Indent = 0,
        [bool]   $NoNewline = $false
    )
    
    if ([MessageLevel]::ERROR -ge $global:CurrentMessageLevel) {
        Do-Write-With-Config -Message $Message -Indent $Indent -Config $MessageConfig.Error -NoNewLine $NoNewline
    }
}

function Get-Input {
    param(
        [string]$Message,
        [int]$Indent = 0
    )
    
    Do-Write -Message $Message -Label $MessageConfig.Input.Label -LabelColor $MessageConfig.Input.LabelColor -NoNewline $true
    return (Read-Host)
}

function Print-Menu {
    param (
        [string] $Message,
        $Options
    )

    $choice = -1
    while($true) {
        # Start with a newline
        Write-Host ""

        # Print the menu message, simulating a "Get-Input" type message
        Do-Write -Message $Message -Label $MessageConfig.Input.Label -LabelColor $MessageConfig.Input.LabelColor
        
        # Now print the options
        $count = 0
        foreach($option in $Options) {
            $OptionStr = "$($count + 1) - $Option"
            Do-Write -Message $OptionStr -Indent 1 -PrintLabel $False
            $count++
        }

        # Read the user's choice and parse as numeric
        $choice = Get-Input -Message "Enter Choice: "
        try {
            $choiceValid = [int]::TryParse($choice, [ref]$choice)
        } catch {
            Write-Error "Option entered must be numeric"
            continue
        }

        # Check input provided is within range (subtract 1 to make index 0-based)
        $choice--
        if(($choice -lt 0) -or ($choice -ge $Options.Count)) {
            Write-Error "Option entered is not within range 1-$($Options.Count) (You entered: $($choice  +1))"
            continue
        }

        # Got here, choice was valid
        break
    }

    # Return the selected index and the text representing the choice
    return @{
        Index = $choice
        Item = $Options[$choice]
    }
}

function Do-Write-With-Config {
    param(
        [string] $Message,
        [int]    $Indent = 0,
                 $Config,
        [bool]  $NoNewline = $false
    )

    # Set the defaults
    $Label = $Config.Label
    $LabelColor = $Config.LabelColor
    $PrintLabel = $true

    # Indent > 0 might change label behaviour
    if ($Indent -gt 0) {
        # Check if we need to use a different label for indented lines
        if ($Config.IndentLabel) {
            $Label = $Config.IndentLabel
        }

        # Check if we should even print the label on indented lines
        if ($Config.ContainsKey("PrintLabelOnIndent")) {
            $PrintLabel = $Config.PrintLabelOnIndent
        }
    }

    # Pass the extracted params to Do-Write
    Do-Write -Message $Message -Indent $Indent -Label $Label -LabelColor $LabelColor -PrintLabel $PrintLabel -NoNewline $NoNewline
}

function Do-Write {
    param(
        [string] $Message,
        [bool]   $PrintLabel = $true,
        [string] $Label,
        [string] $LabelColor = "White",
        [int]    $Indent = 0,
        [bool]   $NoNewline = $false
    )

    if ($PrintLabel) {
        Write-Host "[" -NoNewline -ForegroundColor Gray
        Write-Host $Label -NoNewline -ForegroundColor $LabelColor
        Write-Host "] " -NoNewline -ForegroundColor Gray
    }

    if ($NoNewline) {
        Write-Host "$("  " * $Indent)$Message" -NoNewline
    } else {
        Write-Host "$("  " * $Indent)$Message"
    }
}

Export-ModuleMember -Function Write-Info, Write-Debug, Write-Error, Get-Input, Print-Menu, Do-Write, Set-MessageLevel, Get-MessageLevel