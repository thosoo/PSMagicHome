Import-Module -Name ./PSMagicHome.psm1

Write-Host 'Discovery:'
$devices = Invoke-MagicHomeDiscovery
Write-Host 'Discovery Done'

$prompt = Read-Host -Prompt 'Which Device should I talk to? Tell me the mac'
$device = $devices | Where-Object -Property mac -match $prompt
$turnon = Set-MagicHomePowerOn -device $device
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

