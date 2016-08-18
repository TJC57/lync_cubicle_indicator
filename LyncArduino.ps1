# Lync Status Arduino via PowerShell script
# Written by Tim Chen

# Referenced Sources:
# http://www.ravichaganti.com/blog/finding-lync-contact-availability-using-powershell/


$prev = 'o'
$hosebreak = 0

if(-not (Get-Module -Name Microsoft.Lync.Model)){
    try{
        Import-Module -Name (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath "Microsoft Office\Office15\LyncSDK\Assemblies\Desktop\Microsoft.Lync.Model.dll") -ErrorAction Stop
    }
    catch{
        Write-Warning "Microsoft.Lync.Model cannot be found, install LyncSDK.exe"
        break
    }
}

try{
    # Initialize the Serial Port Settings
    $port = New-Object System.IO.Ports.SerialPort
    $port.PortName = "COM6"
    $port.BaudRate = "9600"
    $port.Parity = "None"
    $port.DataBits = 8
    $port.StopBits = 1
    $port.ReadTimeout = 2000 # 5 seconds
    #$port.DtrEnable = "true
}
catch [System.IO.IOException]
{
    Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Cannot access COM port, please check connection!"
    break
}

while($true){
    try{
        $client = [Microsoft.Lync.Model.LyncClient]::GetClient()
    }
    catch [Microsoft.Lync.Model.ClientNotFoundException]
    {
        Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Lync Client not found!"
        $char = 'o'
    }
    catch [Microsoft.Lync.Model.NotStartedByUserException]
    {
        Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Lync/Skype for Business is not open.  Please open it."
        break
    }

    # Check if client signed in.
    if($client.state -eq "SignedIn"){
        # Create a Lync contact object on yourself
        $contact = $client.ContactManager.GetContactByUri("tim.j.chen@hp.com")
        # Retrieve the Lync Status with the correct enumeration.
        # Enumeration is found at https://msdn.microsoft.com/en-us/library/microsoft.lync.controls.contactavailability_di_2_lyncctrlslmref.aspx
        $status = [Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability")
        #Write-Output "My Lync Status is: " $status
    
        # Map Lync Statuses with integers for Arduino Sketch Handling
        switch ($status){
            None {
                "PS Lync Status: None"
                 $char = 'o'   
                 break
            }
            Free {
                "PS Lync Status: Free"
                 $char = 'f'     
                 break
            }
            FreeIdle {
                "PS Lync Status: FreeIdle" 
                 $char = 'r'
                 break
            }
            Busy {
                "PS Lync Status: Busy"
                $char = 'b'
                break
            }
            BusyIdle {
                "PS Lync Status: BusyIdle"
                $char = 'i'
                break
            }
            DoNotDisturb {
                "PS Lync Status: Do Not Disturb"
                $char = 'd'
                break
            }
            TemporarilyAway {
                "PS Lync Status: Be Right Back"
                $char = 'r'
                break
            }
            Away {
                "PS Lync Status: Away"
                $char = 'a'    
                break
            }
            Offline {
                "PS Lync Status: Offline"
                $char = 'o'
                break
            }
            default {"Invalid Lync Status!!"; break}
        }

    }
    else{
        Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Lync is not running, or you are not signed in."
        $char = 'o'
        Start-Sleep 1
    }

    # Check if the Arduino is connected (verify hosebreak scenario)
    try
    {
        #$port = New-Object System.IO.Ports.SerialPort COM6,9600,None,8,one
        # Source: http://forum.arduino.cc/index.php?topic=39804.0
        if (!$port.IsOpen){
            try{
                $port.open()
                if ($prev -ne $char)
                {
                    $port.WriteLine($char)
                    $port.ReadLine()
                }
                elseif ($prev -eq $char -and $hosebreak -eq 1)
                {
                    $port.WriteLine($char)
                    $port.ReadLine()
                    $hosebreak = 0
                }
                # update previous character
                $prev = $char
            }
            catch [System.UnauthorizedAccessException]
            {
                Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Access to COM port denied, check for other instances & wait..."
                Start-Sleep 1
            }
            catch [System.TimeoutException]
            {
                Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") ReadLine timed out, continue script to recover..."
            }
            finally{
                $port.close()
                Write-Output "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Closed Port"
            }
        }
        else{
            Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Port is NOT open, continuing script..."
        }
    }
    catch [System.IO.IOException]
    {
        Write-Warning "$(Get-Date -Format "[MM-dd-yyyy hh:mm:ss]") Cannot access COM port, please check connection!"
        $hosebreak = 1
    }

    # wait 1s before checking again
    Start-Sleep 1
}