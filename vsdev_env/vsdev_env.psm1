# vsdev_env v1.0
# Copyright (C) 2010 David Buksbaum
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#-- Private Module Variables (Listed here for quick reference)
[bool]$script:environmentSet
[string]$script:originalEnvPath
[string]$script:originalDirectory
[string]$script:vstudio_version
[string]$script:vstudio_path

function Configure-BuildEnvironment 
{
  $vstudio_path = $null
  $version = $null
  switch ($vstudio_version) 
  {
    '2008' 
      { 
        $vstudio_path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio 9.0" 
        $version = 'v3.5' 
      }
    '2010' 
      { # .NET 4.0 BETA
        $vstudio_path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio 10.0";
        $version = 'v4.0.21006' 
      }
    default { throw "Error: Unknown Visual Studio Environment, $devenv"}
  }

  $frameworkDir = "$env:windir\Microsoft.NET\Framework\$version\"
  
  $sdk_dir = (get-itemproperty -path "hklm:SOFTWARE\Microsoft\Microsoft SDKs\Windows" -name "CurrentInstallFolder").CurrentInstallFolder
  $sdkBin_dir = "$sdk_dir\bin"
  $sdkBin64_dir = "$sdk_dir\bin\x64"

  if($env:PROCESSOR_ARCHITECTURE -eq 'AMD64')
  {
    $sdk_path = "$sdkBin64_dir;$sdkBin_dir"
  }
  else
  {
    $sdk_path = $sdkBin_dir
  }

  $ide_dir = "$vstudio_path\Common7\IDE\"
  $tools_dir = "$vstudio_path\Common7\Tools\"
  $toolsbin_dir = "$vstudio_path\Common7\Tools\Bin\"
  
  $env:path = "$sdk_path;$frameworkDir;$ide_dir;$tools_dir;$toolsbin_dir;$env:path"
}

function Push-Environment
{
  if($script:environmentSet -eq $true)
  { # already set, and we dont support nested environments
    Pop-Environment
  }
  
  $script:vstudio_version = $devenv
  $script:originalEnvPath = $env:path
  $script:originalDirectory = Get-Location	
  $script:environmentSet = $true
}

function Pop-Environment 
{
  $env:path = $script:originalEnvPath	
  Set-Location $script:originalDirectory
  $script:environmentSet = $false
}


function Set-DevEnv()
{
  param(
    [Parameter(Position=0,Mandatory=0)]
    [string]$devenv = '2010'
  )

  Push-Environment
  Configure-BuildEnvironment
  write-host "Set Development Environment to Visual Studio $vstudio_version"
  #set-alias -name devenv -value "$base_dir\Common7\IDE\devenv.exe"
}

function Clear-DevEnv
{
  Pop-Environment
  write-host "Development Environment Restored"
}

export-modulemember -function "Set-DevEnv", "Clear-DevEnv"