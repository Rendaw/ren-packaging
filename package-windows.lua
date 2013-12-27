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

if (#ExtraQt5PlatformLibraries > 0) then Shell('mkdir -p ' .. TreeBase .. '/platforms') end
for Index, Library in ipairs(ExtraQt5PlatformLibraries)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/platforms') end

if (#ExtraVLCPluginLibrariesAccess > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/access') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesAccess)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/access') end

if (#ExtraVLCPluginLibrariesDemux > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/demux') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesDemux)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/demux') end

if (#ExtraVLCPluginLibrariesAudioOutput > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/audio_output') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesAudioOutput)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/audio_output') end

if (#ExtraVLCPluginLibrariesAudioFilter > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/audio_filter') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesAudioFilter)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/audio_filter') end

if (#ExtraVLCPluginLibrariesAudioMixer > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/audio_mixer') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesAudioMixer)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/audio_mixer') end

if (#ExtraVLCPluginLibrariesCodec > 0) then Shell('mkdir -p ' .. TreeBase .. '/plugins/codec') end
for Index, Library in ipairs(ExtraVLCPluginLibrariesCodec)
	do Shell('cp ' .. Library .. ' ' .. TreeBase .. '/plugins/codec') end

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
