
local Root = arg[0]:match '(.+[/\\]).-'

Architecture = 'amd64'
dofile(Root .. 'package-ubuntu.lua')

