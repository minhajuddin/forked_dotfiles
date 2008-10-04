###############################################################################
# powershell initialization script
# call from profile.ps1, like this:
#     . "$env:HOME\_profile.ps1"
# (notice the '.')
###############################################################################

#
# Set the $HOME variable for our use
# and make powershell recognize ~\ as $HOME
# in paths
#
set-variable -name HOME -value (resolve-path $env:Home) -force
(get-psprovider FileSystem).Home = $HOME

#
# global variables and core env variables 
#
$TOOLS = 'e:\tools'
$SCRIPTS = "$HOME\scripts"
$env:EDITOR = 'gvim.exe'

#
# set path to include my usual directories
# and configure dev environment
#
function script:append-path { 
   $env:PATH += ';' + $args
}

& "$SCRIPTS\devenv.ps1"
& "$SCRIPTS\javaenv.ps1"

append-path $TOOLS
append-path (resolve-path "$TOOLS\svn-*\bin")
append-path (resolve-path "$TOOLS\nant-*")
append-path "$TOOLS\vim"
append-path "$TOOLS\gnu"
append-path "$TOOLS\git\bin"


#
# Define our prompt. Show '~' instead of $HOME
#
function shorten-path([string] $path) {
   $loc = $path.Replace($HOME, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}

function prompt {
   # our theme
   $cdelim = [ConsoleColor]::DarkCyan
   $chost = [ConsoleColor]::Green
   $cloc = [ConsoleColor]::Cyan

   write-host "$([char]0x0A7) " -n -f $cloc
   write-host ([net.dns]::GetHostName()) -n -f $chost
   write-host ' {' -n -f $cdelim
   write-host (shorten-path (pwd).Path) -n -f $cloc
   write-host '}' -n -f $cdelim
   return ' '
}

###############################################################################
# Other helper functions
###############################################################################
function to-hex([long] $dec) {
   return "0x" + $dec.ToString("X")
}
# open explorer in this directory
function exp([string] $loc = '.') {
   explorer $loc
}
# return all IP addresses
function get-ips() {
   $ent = [net.dns]::GetHostEntry([net.dns]::GetHostName())
   return $ent.AddressList | ?{ $_.ScopeId -ne 0 } | %{
      [string]$_
   }
}
# get the public IP address of my 
# home internet connection
function get-homeip() {
   $ent = [net.dns]::GetHostEntry("home.winterdom.com")
   return [string]$ent.AddressList[0]
}
# do a garbage collection
function run-gc() {
   [void]([System.GC]::Collect())
}
# launch VS dev webserver, from Harry Pierson
# http://devhawk.net/2008/03/20/WebDevWebServer+PowerShell+Function.aspx
function webdev($path,$port=8080,$vpath='/') {
    $spath = "$env:ProgramFiles\Common*\microsoft*\DevServer\9.0\WebDev.WebServer.EXE"

    $spath = resolve-path $spath
    $rpath = resolve-path $path
    &$spath "/path:$rpath" "/port:$port" "/vpath:$vpath"
    "Started WebDev Server for '$path' directory on port $port"
}

# start gitk without having to go through bash first
function gitk {
   wish "$TOOLS\git\bin\gitk"
}

# uuidgen.exe replacement
function uuidgen {
   [guid]::NewGuid().ToString('d')
}
# get our own process information
function get-myprocess {
   [diagnostics.process]::GetCurrentProcess()
}

###############################################################################
# aliases
###############################################################################
set-alias fortune ${SCRIPTS}\fortune.ps1
set-alias ss select-string

###############################################################################
# Other environment configurations
###############################################################################
# enable PowerTab
#`& "$TOOLS\powertab\Init-TabExpansion.ps1" -ConfigurationLocation $HOME 
set-location $HOME
