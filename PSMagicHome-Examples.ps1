Import-Module ./PSMagicHome.psm1

Write-Host 'Discovery:'
$devices = Discover-MagicHome 
Write-Host 'Discovery Done'
$device = $devices | Where-Object -Property mac -eq '40F520C82D93'
$turnon = MagicHome-PowerOn -device $device
if ($turnon -eq $true) {
    Write-Host 'ok'
} else {
    Write-Host 'nok'
}
for ($j = 0; $j -lt 100; $j++) {
    for ($i = 0; $i -lt 254; $i++) {
        $i
        Set-MagicHomeWhite -W $i -device $device
        start-sleep -Milliseconds 50
    }
    for ($i = 254; $i -gt 0; $i--) {
        $i
        Set-MagicHomeWhite -W $i -device $device
        start-sleep -Milliseconds 50
    } 
}

