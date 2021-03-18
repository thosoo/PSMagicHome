

Write-Host 'Discovery:'
$devices = Discover-MagicHome 
Write-Host 'Discovery Done'
#$devices | gm
# $devices[0]

#$newdevice = MagicHome-GetStatus -device $devices[0]
#$newdevice.status.StatusHex()
$testdevice=$devices[0]
$testdevice.SetStatus((MagicHome-GetStatus -device $testdevice))
$testdevice.SetStatus((MagicHome-GetStatus -device $testdevice))
$testdevice.SetStatus((MagicHome-GetStatus -device $testdevice))
$device = $devices | Where-Object -Property mac -eq '600194B39371'
$turnon = MagicHome-PowerOn -device $device
if ($turnon -eq $true) {
    Write-Host 'ok'
} else {
    Write-Host 'nok'
}

for ($j = 0; $j -lt 100; $j++) {
    for ($i = 0; $i -lt 254; $i++) {
        $i
        MagicHome-SetColor -R $i -device $device
        start-sleep -Milliseconds 100
    }
    for ($i = 254; $i -gt 0; $i--) {
        $i
        MagicHome-SetColor -R $i -device $device
        start-sleep -Milliseconds 100
    } 
}



[byte[]]$command = ("71240F" -replace '..', '0x$&,' -split ',' -ne '')
$newcommand = Get-MagicHomeChecksum -byte $command
$newcommand | ForEach-Object{
    ('{0:x2}' -f $_)
}


Write-Host 'Done'