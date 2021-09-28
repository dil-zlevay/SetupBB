@echo off

SET BoardBooksPath= D:\work\Boardbooks
SET IdentityProviderPath= D:\work\IdentityProvider
SET IdentityServerPath= D:\work\identity-server
SET AccountSecurityPath= D:\work\account-security

SET BoardBooksScript= %BoardBooksPath%\Scripts\Modules\psake\psake.ps1
SET BoardBooksBuild= %BoardBooksPath%\build.ps1

For /F %%A In (
    'PowerShell -NoP -NoL "@('Setup','Build','Deploy')" 2^>Nul'
) Do Set "BoardBooksTasks=%%A"

SET IdentityProvider= %IdentityProviderPath%\Scripts\Modules\psake\psake.ps1
SET IdentityProviderBuild= %IdentityProviderPath%\build.ps1

For /F %%A In (
    'PowerShell -NoP -NoL "@('Build','Deploy')" 2^>Nul'
) Do Set "IdentityProviderTasks=%%A"

rem if some parts need to wait: timeout 5
git -C %BoardBooksPath% pull
PowerShell -NoProfile -Executionpolicy Bypass -Command ". {%BoardBooksScript% -buildFile %BoardBooksBuild% -taskList %BoardBooksTasks%}"
git -C %IdentityProviderPath% pull
PowerShell -NoProfile -Executionpolicy Bypass -Command ". {%IdentityProvider% -buildFile %IdentityProviderBuild% -taskList %IdentityProviderTasks%}"
git -C %IdentityServerPath% pull
cd /D %IdentityServerPath%
start /wait /b cmd /c npm install
start /wait /b cmd /c npm run init
start npm start
timeout 40
git -C %AccountSecurityPath% pull
cd /D %AccountSecurityPath%
start /wait /b cmd /c npm install
start /wait /b cmd /c npm run init
start npm start