Configuration InstallTools
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost'
    {
        Script InstallAzureCLI
        {
            GetScript = { @{ Result = (Get-Command az).Source } }
            TestScript = { Test-Path (Join-Path ${env:ProgramFiles(x86)} '\Microsoft SDKs\Azure\CLI2\wbin\az.cmd') }
            SetScript = {
                Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi
                Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
                Remove-Item AzureCLI.msi
            }
        }

        Script DownloadSSMS
        {
            SetScript = {
                $url = 'https://aka.ms/ssmsfullsetup'
                $path = 'D:\SSMS\SSMS-Setup-ENU.exe'

                Invoke-WebRequest -Uri $url -OutFile $path
            }
            TestScript = {
                $path = 'D:\SSMS\SSMS-Setup-ENU.exe'

                Test-Path $path
            }
            GetScript = { }
            DependsOn = '[File]SSMSFolder'
        }

        Package 'SSMS'
        {
            Name = 'SQL Server Management Studio'
            ProductId = '{7AA30E63-94C1-4BBA-A204-408EF4D4B7EA}'
            Path = 'D:\SSMS\SSMS-Setup-ENU.exe'
            Arguments = '/install /quiet /norestart'
            Ensure = 'Present'
            DependsOn = '[Script]DownloadSSMS'
        }

        File 'SSMSFolder'
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'D:\SSMS'
        }
    }
}

InstallTools