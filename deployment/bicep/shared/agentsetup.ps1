param (
    [string]$URL,
    [string]$PAT,
    [string]$POOL,
    [string]$AGENT,
    [string]$AGENTTYPE
)

Write-Output $URL
Write-Output $PAT
Write-Output $POOL
Write-Output $AGENT
Write-Output $AGENTTYPE

if ($AGENTTYPE -eq "AZUREDEVOPS")
{
    Write-Host "About to setup Azure DevOps Agent"
Start-Transcript
Write-Host "start"



#test if an old installation exists, if so, delete the folder
if (test-path "c:\agent")
{
    Remove-Item -Path "c:\agent" -Force -Confirm:$false -Recurse
}

#create a new folder
new-item -ItemType Directory -Force -Path "c:\agent"
set-location "c:\agent"
$global:ProgressPreference = 'SilentlyContinue'
$env:VSTS_AGENT_HTTPTRACE = $true

#github requires tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ProgressPreference = 'SilentlyContinue'
#get the latest build agent version
$wr = Invoke-WebRequest https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest -UseBasicParsing
$tag = ($wr | ConvertFrom-Json)[0].tag_name
$tag = $tag.Substring(1)

write-host "$tag is the latest version"
#build the url
$download = "https://vstsagentpackage.azureedge.net/agent/$tag/vsts-agent-win-x64-$tag.zip"

#download the agent
Invoke-WebRequest $download -Out agent.zip

#expand the zip
Expand-Archive -Path agent.zip -DestinationPath $PWD

Write-Output "--unattended --url $URL --auth pat --token "$PAT" --pool $POOL --agent $AGENT --acceptTeeEula --runAsService"
#run the config script of the build agent
.\config.cmd --unattended --url $URL --auth pat --token "$PAT" --pool $POOL --agent $AGENT --acceptTeeEula --runAsService --replace

#exit
Stop-Transcript
exit 0
}

else
 {
    Start-Transcript

    Write-Host "About to setup GitHub Runner"
    $ghrunnerdirectory="c:\actions-runner"


#test if an old installation exists, if so, delete the folder
if (test-path $ghrunnerdirectory)
{
    set-location $ghrunnerdirectory
    $servicename=(Get-Content .service)
    Stop-Service $servicename -ErrorAction SilentlyContinue
    set-location 'c:\'
    Remove-Item -Path $ghrunnerdirectory -Force -Confirm:$false -Recurse
}

#create a new folder
new-item -ItemType Directory -Force -Path $ghrunnerdirectory
set-location $ghrunnerdirectory
$global:ProgressPreference = 'SilentlyContinue'
$env:VSTS_AGENT_HTTPTRACE = $true

#github requires tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ProgressPreference = 'SilentlyContinue'
#get the latest build agent version
$wr = Invoke-WebRequest https://api.github.com/repos/actions/runner/releases/latest -UseBasicParsing
$tag = ($wr | ConvertFrom-Json)[0].tag_name
$tag = $tag.Substring(1)

write-host "$tag is the latest version"
#build the url

$download = "https://github.com/actions/runner/releases/download/v$tag/actions-runner-win-x64-$tag.zip"

#download the agent
Invoke-WebRequest $download -Out ghactionsrunner.zip

#expand the zip
Expand-Archive -Path ghactionsrunner.zip -DestinationPath $PWD


#run the config script of the build agent
set-location $ghrunnerdirectory
.\config.cmd --unattended --url $URL  --token "$PAT"  --runnergroup $POOL  --replace --runasservice --replace



#exit
Stop-Transcript
exit 0
}