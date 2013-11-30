function Shell(Command)
	print(Command)
	if not os.execute(Command) then os.exit(1) end
end

local States = {}
local StringState = function(Name)
	States['--' .. Name] = function(Argument)
		_G[Name] = Argument
	end
end
local ArrayState = function(Name)
	if not _G[Name] then _G[Name] = {} end
	States['--' .. Name] = function(Argument)
		table.insert(_G[Name], Argument)
	end
end
StringState 'Dependencies'
StringState 'ArchLicenseStyle'
StringState 'DebianSection'
ArrayState 'Executables'
ArrayState 'Libraries'
ArrayState 'Resources'
ArrayState 'Licenses'
ArrayState 'ExtraLibraries'
ArrayState 'ExtraQt5PlatformLibraries'
ArrayState 'ExtraVLCPluginLibrariesDemux'
ArrayState 'ExtraVLCPluginLibrariesAudioOutput'
ArrayState 'ExtraVLCPluginLibrariesAudioMixer'
ArrayState 'ExtraVLCPluginLibrariesCodec'
ArrayState 'ExtraLicenses'

local ArgState
for Index = 1, #arg
do
	local Argument = arg[Index]
	if States[Argument] then ArgState = States[Argument]
	elseif not ArgState
	then
		if Name then error('Unknown argument parse state at argument \'' .. Argument .. '\'.') end
		Name = Argument
	else ArgState(Argument)
	end
end

