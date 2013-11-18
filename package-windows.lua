#!/usr/bin/lua

-- Boilerplate
local Root = arg[0]:match '(.+[/\\]).-'
dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Here = io.popen('pwd'):read() .. '/'

local FilenamePattern = ('%s-%s-x86_64'):format(Name, Info.Version)
local TreeBase = 'temp/' .. FilenamePattern
Shell('mkdir -p ' .. TreeBase)
for Index, Executable in ipairs(Executables)
	do Shell('cp ' .. Executable .. ' ' .. TreeBase) end
for Index, Library in ipairs(Libraries)
	do Shell('cp ' .. Library .. ' ' .. TreeBase) end
for Index, Library in ipairs(ExtraLibraries)
	do Shell('cp ' .. Library .. ' ' .. TreeBase) end
for Index, Resource in ipairs(Resources)
	do Shell('cp ' .. Resource .. ' ' .. TreeBase) end
for Index, License in ipairs(Licenses)
	do Shell('cp ' .. License .. ' ' .. TreeBase) end
for Index, License in ipairs(ExtraLicenses)
	do Shell('cp ' .. License .. ' ' .. TreeBase) end
Shell('cd temp && 7z a ' .. FilenamePattern .. '.7z ' .. FilenamePattern)
Shell('mv temp/' .. FilenamePattern .. '.7z .')
Shell('touch ' .. Name .. '-def.txt')
Shell('rm -r temp')
