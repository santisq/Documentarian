# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ProviderFlags.psm1
using module ../Classes/ParameterInfo.psm1

function Get-ParameterInfo {
    [CmdletBinding()]
    [OutputType([ParameterInfo])]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ParameterName,

        [Parameter(Mandatory, Position = 1)]
        [string]$CmdletName,

        [switch]$AsObject
    )

    $cmdlet = Get-Command -Name $CmdletName -ErrorAction Stop
    $providerList = Get-PSProvider

    foreach ($pname in $ParameterName) {
        try {
            $paraminfo = $null
            $param = $null
            foreach ($provider in $providerList) {
                Push-Location $($provider.Drives[0].Name + ':')
                $param = $cmdlet.Parameters.Values | Where-Object Name -EQ $pname
                if ($param) {
                    if ($paraminfo) {
                        $paraminfo.ProviderFlags = $paraminfo.ProviderFlags -bor [ProviderFlags]($provider.Name)
                    } else {
                        $paraminfo = [ParameterInfo]::new(
                            $param,
                            [ProviderFlags]($provider.Name)
                        )
                    }
                }
                Pop-Location
            }
        } catch {
            Write-Error "Cmdlet $CmdletName not found."
            return
        }

        if ($paraminfo) {
            if ($AsObject) {
                $paraminfo
            } else {
                $paraminfo.ToMarkdown()
            }
        } else {
            Write-Error "Parameter $pname not found."
        }
    }
}

# Get-ParameterInfo path, Options set-item