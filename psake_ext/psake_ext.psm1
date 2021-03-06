# psake_ext v1.0
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
#
# ------------------------------------------------------------------------------
#
# psake_ext.psm1: psake extensions
# author: david buksbaum
# blog: http://buksbaum.us
# source: http://github.com/dbuksbaum
#
# Derived from Ayende's Texo psake_ext.ps1 script.
# - Moved into a module.
# - functions renamed to eliminate verb warnings and extra '-' warnings.
# - functions modified to be more flexible
# - Get-GitCommit now supports running in non-git directories
# - Export-AssemblyInfo now checks and ignores null or empty directory names    
# - added documentation
# - Export-AssemblyInfo now takes a path to specify directory
# - Export-AssemblyInfo defaults to AssemblyInfo.cs for file name

<# 
 .Synopsis
  Get the git commit id

 .Description
  Extracts the commit id from the git log. If the directory does not have the '.git'
  directory, it returns an empty string.

 .Example
   # Get the git commit id
   Get-GitCommit
#>
function Get-GitCommit
{
  $dir = [System.IO.Path]::Combine($pwd, '.git')

  if ([System.IO.Directory]::Exists($dir) -eq $true)
  {
	$gitLog = git log --oneline -1
	return $gitLog.Split(' ')[0]
  }
  else
  {
    return ''
  }
}

<# 
 .Synopsis
  Exports an C# file containing standard AssemblyInfo information

 .Description
  Exports a C# file containing the following AssemblyInfo attributes:
    CLSCompliantAttribute
    ComVisibleAttribute - always set to false
    AssemblyTitleAttribute
    AssemblyDescriptionAttribute
    AssemblyCompanyAttribute
    AssemblyProductAttribute
    AssemblyCopyrightAttribute
    AssemblyVersionAttribute
    AssemblyInformationalVersionAttribute - combination of version and 
      git commit id (version / commit id)
    AssemblyFileVersionAttribute - matches the value of version
    AssemblyDelaySignAttribute
  
  This function will try and retrieve the cit commit ID if this is
  a valid git source tree.

 .Parameter clsCompliant
  Sets the CLSCompliantAttribute.
  Defaults to true.

 .Parameter title
  Sets the AssemblyTitleAttribute.
  Defaults to true.

 .Parameter description
  Sets the AssemblyDescriptionAttribute.

 .Parameter company
  Sets the AssemblyCompanyAttribute.

 .Parameter product
  Sets the AssemblyProductAttribute.

 .Parameter copyright
  Sets the AssemblyCopyrightAttribute.

 .Parameter version
  Sets the AssemblyVersionAttribute.

 .Parameter path
  The path for the output file.
  Defaults to the current directory.

 .Parameter file
  The output file name. Path information is ignored in this parameter.
  Defaults to AssemblyInfo.cs

 .Example
   # Exports AssemblyInfo.cs into the current directory with all defaults
   Export-AssemblyInfo

 .Example
   # Exports MyAssemblyInfo.cs into the current directory with all defaults
   Export-AssemblyInfo -file MyAssemblyInfo.cs

 .Example
   # Exports AssemblyInfo.cs into the ./Test directory with all defaults
   Export-AssemblyInfo -path Test

 .Example
   # Exports CustomAssemblyInfo.cs into the ./Test directory with all defaults
   Export-AssemblyInfo -path Test -file CustomAssemblyInfo.cs

 .Example
   # Exports AssemblyInfo.cs into the current directory with a custom version and everything else as default
   Export-AssemblyInfo -version '1.0.1.0'
#>
function Export-AssemblyInfo
{
param
(
  [string]$clsCompliant = "true",
  [string]$title, 
  [string]$description, 
  [string]$company, 
  [string]$product, 
  [string]$copyright, 
  [string]$version,
  [string]$path,
  [string]$file = "AssemblyInfo.cs"
)
  $commit = Get-GitCommit
  $asmInfo = "using System;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: CLSCompliantAttribute($clsCompliant )]
[assembly: ComVisibleAttribute(false)]
[assembly: AssemblyTitleAttribute(""$title"")]
[assembly: AssemblyDescriptionAttribute(""$description"")]
[assembly: AssemblyCompanyAttribute(""$company"")]
[assembly: AssemblyProductAttribute(""$product"")]
[assembly: AssemblyCopyrightAttribute(""$copyright"")]
[assembly: AssemblyVersionAttribute(""$version"")]
[assembly: AssemblyInformationalVersionAttribute(""$version / $commit"")]
[assembly: AssemblyFileVersionAttribute(""$version"")]
[assembly: AssemblyDelaySignAttribute(false)]
"
  if([System.String]::IsNullOrEmpty($path) -eq $false)
  { # path is not null
    if([System.IO.Path]::IsPathRooted($path) -eq $false)
    {
      $dir = [System.IO.Path]::Combine($pwd, $path)
    }
    else
    {
      $dir = $path
    }
    #$dir = [System.IO.Path]::GetFullPath($path)
    if($dir.EndsWith('/') -eq $false)
    {
      $dir = [System.String]::Concat($dir, '/')
    }

    if ([System.IO.Directory]::Exists($dir) -eq $false)
    { # directory exists
      Write-Host "Creating directory $dir"
	  [System.IO.Directory]::CreateDirectory($dir)
    }
    $outFile = [System.IO.Path]::Combine($dir, $file)
  }
  else
  {
    $outFile = [System.IO.Path]::GetFileName($file)
  }
  
  Write-Host "Generating assembly info file: $outFile"
  Write-Output $asmInfo > $outFile
}

export-modulemember -function "Export-AssemblyInfo", "Get-GitCommit"