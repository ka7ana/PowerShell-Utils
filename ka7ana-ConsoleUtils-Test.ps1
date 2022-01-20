Import-Module $PSScriptRoot\ka7ana-ConsoleUtils.psm1 -WarningAction Ignore

function Print-Banner {
    $Banner = @"

███╗   ███╗██╗   ██╗    ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗██╗
████╗ ████║╚██╗ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██║
██╔████╔██║ ╚████╔╝     ███████╗██║     ██████╔╝██║██████╔╝   ██║   ██║
██║╚██╔╝██║  ╚██╔╝      ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚═╝
██║ ╚═╝ ██║   ██║       ███████║╚██████╗██║  ██║██║██║        ██║   ██╗
╚═╝     ╚═╝   ╚═╝       ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚═╝
"@
    $BannerColor = "Cyan"

    Write-Host $Banner -ForegroundColor $BannerColor
}

# Output the banner
if (!$Quiet) {
    Print-Banner
}

Set-MessageLevel -Level INFO

Write-Info -Message "Starting script..."
Write-Info -Message "Started!" -Indent 1

Write-Info -Message "Current message level set to: $(Get-MessageLevel)"
Write-Debug -Message "This debug message should not be shown"

# Set the level back to debug, the two folloing Write-Debugs should be shown
Set-MessageLevel -Level DEBUG
Write-Info -Message "Current message level set to: $(Get-MessageLevel)"
Write-Debug -Message "This is a debug message"
Write-Debug -Message "Indented debug message" -Indent 1

Write-Error -Message "This is an error!"
Write-Error -Message "This is a further explanation of the above error" -Indent 1

$MainOptions = @("Print the banner again", "Say 'hello, world!'", "Exit the script")
while($true) {
    $opt = Print-Menu -Message "Choose an option" -Options $MainOptions
    Write-Info "You entered: $($opt.Item)"
    switch ($opt.Index) {
        0 { Print-Banner }
        1 { Write-Info "Hello, world!" }
        2 { Exit }
    }
}
