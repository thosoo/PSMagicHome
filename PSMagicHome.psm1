class Devicestatus{
    [byte]$packet_id
    [byte]$device_name
    [byte]$power_status
    [byte]$mode
    [byte]$run_status
    [byte]$speed
    [byte]$red
    [byte]$green
    [byte]$blue
    [byte]$warm_white
    [byte]$firmware_version
    [byte]$unused_payload1
    [byte]$unused_payload2
    [byte]$checksum
    Devicestatus(
        [byte[]]$status){
            $this.packet_id =           $status[0]
            $this.device_name =         $status[1]
            $this.power_status =        $status[2]
            $this.mode =                $status[3]
            $this.run_status =          $status[4]
            $this.speed =               $status[5]
            $this.red =                 $status[6]
            $this.green =               $status[7]
            $this.blue =                $status[8]
            $this.warm_white =          $status[9]
            $this.firmware_version =    $status[10]
            $this.unused_payload1 =     $status[11]
            $this.unused_payload2 =     $status[12]
            $this.checksum =            $status[13]
    }
    Devicestatus(
        [Devicestatus]$newstatus){
            $this.packet_id =           $newstatus.packet_id
            $this.device_name =         $newstatus.device_name
            $this.power_status =        $newstatus.power_status
            $this.mode =                $newstatus.mode
            $this.run_status =          $newstatus.run_status
            $this.speed =               $newstatus.speed
            $this.red =                 $newstatus.red
            $this.green =               $newstatus.green
            $this.blue =                $newstatus.blue
            $this.warm_white =          $newstatus.warm_white
            $this.firmware_version =    $newstatus.firmware_version
            $this.unused_payload1 =     $newstatus.unused_payload1
            $this.unused_payload2 =     $newstatus.unused_payload2
            $this.checksum =            $newstatus.checksum
        
    }
    [void]StatusHex(){
        Write-Host ('{0:X2}' -f $this.packet_id) -NoNewline
        Write-Host ('{0:X2}' -f $this.device_name) -NoNewline
        Write-Host ('{0:X2}' -f $this.power_status) -NoNewline
        Write-Host ('{0:X2}' -f $this.mode) -NoNewline
        Write-Host ('{0:X2}' -f $this.run_status) -NoNewline
        Write-Host ('{0:X2}' -f $this.speed) -NoNewline
        Write-Host ('{0:X2}' -f $this.red) -NoNewline
        Write-Host ('{0:X2}' -f $this.green) -NoNewline
        Write-Host ('{0:X2}' -f $this.warm_white) -NoNewline
        Write-Host ('{0:X2}' -f $this.firmware_version) -NoNewline
        Write-Host ('{0:X2}' -f $this.unused_payload1) -NoNewline
        Write-Host ('{0:X2}' -f $this.unused_payload2) -NoNewline
        Write-Host ('{0:X2}' -f $this.checksum)
    }
    [void]SetStatus([Devicestatus]$newstatus){
        $this.packet_id =           $newstatus.packet_id
        $this.device_name =         $newstatus.device_name
        $this.power_status =        $newstatus.power_status
        $this.mode =                $newstatus.mode
        $this.run_status =          $newstatus.run_status
        $this.speed =               $newstatus.speed
        $this.red =                 $newstatus.red
        $this.green =               $newstatus.green
        $this.blue =                $newstatus.blue
        $this.warm_white =          $newstatus.warm_white
        $this.firmware_version =    $newstatus.firmware_version
        $this.unused_payload1 =     $newstatus.unused_payload1
        $this.unused_payload2 =     $newstatus.unused_payload2
        $this.checksum =            $newstatus.checksum
    }
}

class Devices{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][System.Net.IPAddress]$ip
    [ValidateNotNullOrEmpty()][System.Net.NetworkInformation.PhysicalAddress]$mac
    [ValidateNotNullOrEmpty()][string]$model
    [Devicestatus]$status
    # optionally, have a constructor to 
    # force properties to be set:
    Devices([string]$ip, [string]$mac, [string]$model) {
       $this.ip = [System.Net.IPAddress]$ip
       $this.mac = [System.Net.NetworkInformation.PhysicalAddress]::Parse($mac)
       $this.model = $model
    }
    Devices([string]$ip, [string]$mac, [string]$model,[Devicestatus]$status) {
        $this.ip = [System.Net.IPAddress]$ip
        $this.mac = [System.Net.NetworkInformation.PhysicalAddress]::Parse($mac)
        $this.model = $model
        $this.status = $status
    }
    Devices([string]$ip, [string]$mac, [string]$model,[string]$status) {
        $this.ip = [System.Net.IPAddress]$ip
        $this.mac = [System.Net.NetworkInformation.PhysicalAddress]::Parse($mac)
        $this.model = $model
        $newstatus = New-Object($status)
        $this.status = $newstatus
    }
    [void]SetStatus(
        [Devicestatus]$newstatus
    ){
        $this.status=New-Object Devicestatus $newstatus
    }
}

function Write-Hex {
    param (
        [byte[]]$byte
    )
    $byte | ForEach-Object {
        Write-Host ('{0:X2}' -f $_) -NoNewline
    }
    Write-Host ''
}

function Invoke-MagicHomeDiscovery {
    param (
    )
    Begin{
        $devices =@()
    }
    Process{
        [string]$EndPoint = "255.255.255.255" #broadcast
        [int] $Port =  48899
        [string] $Message = "HF-A11ASSISTHREAD"
        $IP = [System.Net.Dns]::GetHostAddresses($EndPoint) 
        $Address = [System.Net.IPAddress]::Parse($IP) 
        $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
        $Socket = New-Object System.Net.Sockets.UDPClient 
        $EncodedText = [Text.Encoding]::ASCII.GetBytes($Message) 
        $send = $Socket.Send($EncodedText, $EncodedText.Length, $EndPoints)
        $receive = $Socket.receiveAsync()
        for ($i = 0; $i -lt 100; $i++) {
            $udppayload = ""
            if ($receive.iscompleted) {
                [string]$udppayload =([string]::join("",([System.Text.Encoding]::ASCII.GetChars($receive.Result.buffer))))
                write-host "Received UDP Data: $($udppayload)"
                if ($udppayload -ne "") {
                    $idsplit = $udppayload -split ","
                    $device= New-Object Devices($idsplit[0],$idsplit[1],$idsplit[2])
                    $devices +=$device
                }
                $receive = $Socket.receiveasync()
            }
            start-sleep -milliseconds 100        
        }
        $Socket.Close()
    }
    End{
        return $devices
    }
    
}

function Get-MagicHomeStatus {
    param (
        [Devices]$device
    )
    # Send 81 8A 8B 96
    # Receive 14 bytes
    Begin{

    }
    Process {
        $Socket = New-Object System.Net.Sockets.TCPClient
        $Socket.Connect($device.ip,'5577')
        [System.Net.Sockets.NetworkStream]$networkstream = $Socket.GetStream()
        [byte[]]$command = ("818A8B96" -replace '..', '0x$&,' -split ',' -ne '') 
        # Write-Host $command
        if ($Socket.Connected) {
            # Write-Host 'Write stream'
            $networkstream.Write($command,0,$command.length)
            $networkstream.Flush()
            # start-sleep -Milliseconds 100
            # Write-Host 'Read Stream'
            [byte[]]$byte = New-Object byte[] 14
            $networkstream.Read($byte, 0, $byte.Length)
            [Devicestatus]$devicestatus = New-Object -TypeName Devicestatus -ArgumentList (,$byte)
        }
        $networkstream.Close()
        $Socket.Close()
    }
    End{
        return [Devicestatus]$devicestatus
    }
}

function Get-MagicHomeChecksum {
    param (
        [byte[]]$byte,
        [string]$string
    )
    Begin{
        [int]$sum=0
        [string]$hex=""
        [string]$checksum=""
        [byte[]]$newbyte = New-Object byte[] ($byte.Count +1)
    }
    Process{
        if ($string -ne "") {
            $byte = ($string -replace '..', '0x$&,' -split ',' -ne '')
        }
        # Write-Host $byte.Count
        # Write-Host $newbyte.Count
        for ($i = 0; $i -lt $byte.Count; $i++) {
            $sum += $byte[$i]
        }
        $hex=('{0:x8}' -f $sum)
        #$hex
        $checksum= ($hex | Select-String -Pattern '[\S]{6}([\S]{2})' -AllMatches).Matches.Groups[1].Value
        #$checksum
        for ($i = 0; $i -lt $byte.Count; $i++) {
            $newbyte[$i] = $byte[$i]
        }
        $newbyte[($byte.Count)]="0x$checksum"
    }
    End{
        return $newbyte
    }
}

function Set-MagicHomePowerOn {
    param (
        [Devices]$device    
    )
    # Send      71 23 0F + Checksum (A3)
    # Receive   F0 71 23 + Checksum (84)
    Begin{
        [bool]$status = $false
        [byte[]]$send = ("71230FA3" -replace '..', '0x$&,' -split ',' -ne '') 
        [byte[]]$receive = ("F0712384" -replace '..', '0x$&,' -split ',' -ne '') 
    }
    Process{
    $Socket = New-Object System.Net.Sockets.TCPClient
    $Socket.Connect($device.ip,'5577')
    [System.Net.Sockets.NetworkStream]$networkstream = $Socket.GetStream()
    
    # Write-Host $command
    if ($Socket.Connected) {
        # Write-Host 'Write stream'
        $networkstream.Write($send,0,$send.length)
        $networkstream.Flush()
        # start-sleep -Milliseconds 100
        # Write-Host 'Read Stream'
        [byte[]]$byte = New-Object byte[] 4
        $byteCount = $networkstream.Read($byte, 0, $byte.Length)
        <#
        Write-host "Bytes received: $($bytecount)"
        $response += (1..$byteCount | ForEach-Object { $byte[$_-1] } )
        $response | ForEach-Object {
            Write-Host ('{0:X2}' -f $_)
        }#>
        for ($i = 0; $i -lt $byte.Count; $i++) {
            if ($byte[$i] -eq $receive[$i]) {
                $status = $true
            } else {
                $status = $false
            }
        }
        
    }
    $networkstream.Close()
    $Socket.Close()
    }
    
    End{
        return $status
    }
}

function Set-MagicHomePowerOff {
    param (
        [Devices]$device    
    )
    # Send      71 24 0F + Checksum (A4)
    # Receive   F0 71 24 + Checksum (85)
    Begin{
        [bool]$status = $false
        [byte[]]$send = ("71230FA3" -replace '..', '0x$&,' -split ',' -ne '') 
        [byte[]]$receive = ("F0712384" -replace '..', '0x$&,' -split ',' -ne '') 
    }
    Process{
    $Socket = New-Object System.Net.Sockets.TCPClient
    $Socket.Connect($device.ip,'5577')
    [System.Net.Sockets.NetworkStream]$networkstream = $Socket.GetStream()
    
    # Write-Host $command
    if ($Socket.Connected) {
        # Write-Host 'Write stream'
        $networkstream.Write($send,0,$send.length)
        $networkstream.Flush()
        # start-sleep -Milliseconds 100
        # Write-Host 'Read Stream'
        [byte[]]$byte = New-Object byte[] 4
        $byteCount = $networkstream.Read($byte, 0, $byte.Length)
        <#
        Write-host "Bytes received: $($bytecount)"
        $response += (1..$byteCount | ForEach-Object { $byte[$_-1] } )
        $response | ForEach-Object {
            Write-Host ('{0:X2}' -f $_)
        }#>
        for ($i = 0; $i -lt $byte.Count; $i++) {
            if ($byte[$i] -eq $receive[$i]) {
                $status = $true
            } else {
                $status = $false
            }
        }
        
    }
    $networkstream.Close()
    $Socket.Close()
    }
    End{
        return $status
    }
}

function Set-MagicHomeColor {
    param (
        [Devices]$device,
        [string]$R,
        [string]$G,
        [string]$B,
        [string]$W
    )
    # Send      31 (RR) (GG) (BB) (WW) + Checksum
    # Receive   No response
    Begin{
        [bool]$status = $false
        [byte[]]$command = New-Object byte[] 5
    }
    Process{
        $command[0]=49
        if ($null -ne $device.status) {   
            $command[1]=$device.status.red
            $command[2]=$device.status.green
            $command[3]=$device.status.blue
            $command[4]=$device.status.warm_white
        }else {
            $command[1]=0
            $command[2]=0
            $command[3]=0
            $command[4]=0
        }

    $Socket = New-Object System.Net.Sockets.TCPClient
    $Socket.Connect($device.ip,'5577')
    [System.Net.Sockets.NetworkStream]$networkstream = $Socket.GetStream()
    if ($R -ne "") {
        $command[1]=[int]$R
    }
    if ($G -ne "") {
        $command[2]=[int]$G
    }
    if ($B -ne "") {
        $command[3]=[int]$B
    }
    if ($W -ne "") {
        $command[4]=[int]$W
    }
    $send = Get-MagicHomeChecksum -byte $command
    $send | ForEach-Object {
        Write-Host ('{0:X2}' -f $_) -NoNewline
    }
    Write-Host ''
    # Write-Host 'Write stream'
        $networkstream.Write($send,0,$send.length)
        $networkstream.Flush()
    
    $networkstream.Close()
    $Socket.Close()
    }
    End{
    }
}

function Set-MagicHomeWhite {
    param (
        [Devices]$device,
        [string]$W
    )
    # Send      31 (RR) (GG) (BB) (WW) + Checksum
    # Receive   No response
    Begin{
        [bool]$status = $false
        [byte[]]$command = New-Object byte[] 5
    }
    Process{
        $command[0]=49
        if ($null -ne $device.status) {   
            $command[1]=$device.status.red
            $command[2]=$device.status.green
            $command[3]=$device.status.blue
            $command[4]=$device.status.warm_white
        }else {
            $command[1]=0
            $command[2]=0
            $command[3]=0
            $command[4]=0
        }

    $Socket = New-Object System.Net.Sockets.TCPClient
    $Socket.Connect($device.ip,'5577')
    [System.Net.Sockets.NetworkStream]$networkstream = $Socket.GetStream()
    if ($W -ne "") {
        $command[1]=[int]$W
    }
    $command | ForEach-Object {
        Write-Host ('{0:X2}' -f $_) -NoNewline
    }
    Write-Host ''
    $send = Get-MagicHomeChecksum -byte $command
    $send | ForEach-Object {
        Write-Host ('{0:X2}' -f $_) -NoNewline
    }
    Write-Host ''
    # Write-Host 'Write stream'
        $networkstream.Write($send,0,$send.length)
        $networkstream.Flush()
    
    $networkstream.Close()
    $Socket.Close()
    }
    End{
    }
}

function Invoke-MagicHomeHyperionBridgeWhite {
    param (
        [Devices]$device,
        [int]$hostport
    )
    Begin{
        [byte[]]$command = New-Object byte[] 5
    }
    Process{
        $command[0]=49
        $command[4]=0
        $UDPSocket = New-Object System.Net.Sockets.UDPClient $hostport
        $TCPSocket = New-Object System.Net.Sockets.TCPClient
        $TCPSocket.Connect($device.ip,'5577')
        $receive = $UDPSocket.receiveAsync()
        while($true){
            if ($receive.iscompleted) {
                $receive.Result.buffer | ForEach-Object {
                    Write-Host ('{0:X2}' -f $_) -NoNewline
                }

                $command[1]=math::Sqrt((0.299*([math]::Pow($receive.Result.buffer[0],2)))*(0.587*([math]::Pow($receive.Result.buffer[1],2)))*(0.114*([math]::Pow($receive.Result.buffer[2],2))))
                $command[2]=0
                $command[3]=0
                $send = Get-MagicHomeChecksum -byte $command
                $send | ForEach-Object {
                    Write-Host ('{0:X2}' -f $_) -NoNewline
                }
                Write-Host ''
                # Write-Host 'Write stream'
                $networkstream.Write($send,0,$send.length)
                $networkstream.Flush()
                
                $receive = $UDPSocket.receiveasync()
            }      
        }
    }
    End{
        $networkstream.Close()
        $TCPSocket.Close()
        $UDPSocket.Close()
    }
    
}

function Invoke-MagicHomeHyperionBridge {
    param (
        [Devices]$device,
        [int]$hostport
    )
    Begin{
        [byte[]]$command = New-Object byte[] 5
    }
    Process{
        $command[0]=49
        $command[4]=0
        $UDPSocket = New-Object System.Net.Sockets.UDPClient $hostport
        $TCPSocket = New-Object System.Net.Sockets.TCPClient
        $TCPSocket.Connect($device.ip,'5577')
        $receive = $UDPSocket.receiveAsync()
        while($true){
            if ($receive.iscompleted) {
                $receive.Result.buffer | Write-Hex
                $command[1]=$receive.Result.buffer[0]
                $command[2]=$receive.Result.buffer[1]
                $command[3]=$receive.Result.buffer[2]
                $send = Get-MagicHomeChecksum -byte $command
                $send | Write-Hex
                # Write-Host 'Write stream'
                $networkstream.Write($send,0,$send.length)
                $networkstream.Flush()
                
                $receive = $UDPSocket.receiveasync()
            }      
        }
    }
    End{
        $networkstream.Close()
        $TCPSocket.Close()
        $UDPSocket.Close()
    }
    
}

Export-ModuleMember -Function Write-Hex, Invoke-MagicHomeDiscovery, Get-MagicHomeStatus, Get-MagicHomeChecksum, Set-MagicHomePowerOn, Set-MagicHomePowerOff, Set-MagicHomeColor, Set-MagicHomeWhite, Invoke-MagicHomeHyperionBridgeWhite, Invoke-MagicHomeHyperionBridge
