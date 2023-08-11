# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --includeRecommended `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

RUN `
    curl -SL --output git.zip https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/MinGit-2.41.0.3-64-bit.zip `
    && mkdir "%ProgramFiles%\Git" `
    && powershell -command "Expand-Archive -Path C:\git.zip -DestinationPath '%ProgramFiles%\git'" `
    && powershell -command "(Get-Content 'C:/Program Files/Git/etc/gitconfig') -replace 'path = C:/Program Files/Git/etc/gitconfig', '' | Set-Content 'C:/Program Files/Git/etc/gitconfig'" `
    && del /q git.zip `
    && SETX /M PATH "%ProgramFiles%\Git\cmd;%ProgramFiles%\Git\mingw64\bin;%ProgramFiles%\Git\usr\bin;%PATH%

RUN `
    git clone https://github.com/microsoft/vcpkg.git C:\vcpkg `
    && cd vcpkg `
    && bootstrap-vcpkg.bat `
    && SETX /M PATH "C:\vcpkg;%PATH%" `
    && vcpkg install zlib:x64-windows --clean-after-build `
    && vcpkg remove zlib:x64-windows

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
