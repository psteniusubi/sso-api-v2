Import-Module -Name "oauth2" -Scope Local

function Invoke-Api {
    [CmdletBinding()]
    Param(
        [Parameter()] [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        [Parameter(Position=0,ParameterSetName="Object",ValueFromPipeline=$true)] [PSTypeName("Object.Path")] $Object,
        [Parameter(Position=0,ParameterSetName="Link",ValueFromPipeline=$true)] [PSTypeName("Link.Path")] $Link,
        [Parameter(Position=0,ParameterSetName="Attribute",ValueFromPipeline=$true)] [PSTypeName("Attribute.Path")] $Attribute,
        [Parameter()] [hashtable] $Headers = $null,
        [Parameter()] [AllowNull()] [string] $ContentType = "application/x-www-form-urlencoded",
        [Parameter()] [AllowNull()] [string] $Accept = $null,
        [Parameter()] [AllowNull()] [object] $Body = $null,
        [Parameter()] [PSTypeName("Context")] $Context = (GetContext)
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $local:h = $Context.Bearer | ConvertTo-OAuthHttpBearer | ConvertTo-OAuthHttpAuthorization
        if($Accept) {
            $local:h += @{"Accept"=$Accept}
        }
        if($Headers) {
            $local:h += $Headers
        }
    }
    Process {
        switch($PSCmdlet.ParameterSetName) {
            "Object" {
                $Object | % {
                    $_ | ConvertFrom-SSOObjectPath | % { "$($Context.BaseUri)$_" } |
                    % { 
                        Write-Verbose "$Method $_ Content-Type:$ContentType Body:$Body" 
                        Invoke-RestMethod -Method $Method -Uri $_ -ContentType $ContentType -Headers $local:h -Body $Body
                    }
                }
                break
            }
            "Link" {
                $Link | % {
                    $_ | ConvertFrom-SSOLinkPath | % { "$($Context.BaseUri)$_" } |
                    % { 
                        Write-Verbose "$Method $_ Content-Type:$ContentType Body:$Body" 
                        Invoke-RestMethod -Method $Method -Uri $_ -ContentType $ContentType -Headers $local:h -Body $Body
                    }
                }
                break
            }
            "Attribute" {
                $Attribute | % {
                    $_ | ConvertFrom-SSOAttributePath | % { "$($Context.BaseUri)$_" } |
                    % { 
                        Write-Verbose "$Method $_ Content-Type:$ContentType Body:$Body" 
                        Invoke-RestMethod -Method $Method -Uri $_ -ContentType $ContentType -Headers $local:h -Body $Body
                    }
                }
                break
            }
        }
    }
}

