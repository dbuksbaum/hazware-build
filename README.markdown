This is where I store scripts and tools used for building most Hazware projects.

- [Dave's blog](http://buksbaum.us/)

psake_ext/psake_ext.psm1: psake extensions
  I derived this from Ayende's Texo psake_ext.ps1 script.
  Key Changes
    - Moved into a module.
    - functions renamed to eliminate verb warnings and extra '-' warnings.
    - functions modified to be more flexible
    - Get-GitCommit now supports running in non-git directories
    - Export-AssemblyInfo now checks and ignores null or empty directory names    
    - added documentation
    - Export-AssemblyInfo now takes a path to specify directory
    - Export-AssemblyInfo defaults to AssemblyInfo.cs for file name

vsdev_env/vsdev_env.psm1: Visual Studio Environment Helper
	I am running both VS 2008 and VS 2010 on my machine, and I have
	grown very tired of having two different command shells in order
	to work with them. So I created this module to allow me to set/unset
	the current development environment.
	
	I expose two functions in this module: Set-DevEnv and Clear-DevEnv.
	
	Set-DevEnv defaults to VS 2010, because it is what I am using the most, but
	this is easily changable. You can also pass in 2008 as a parameter to
	select VS 2008. This function just sets the path for that environment,
	and it is 64bit aware. 
	NOTE: It does not set any of C++ required environment	variables.
	
	Clear-DevEnv restores the path to what it was before Set-DevEnv was called.
