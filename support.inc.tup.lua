DoOnce 'info.inc.lua'

local Scripts =
{
	['arch64'] = Item 'package-arch64.lua',
	['ubuntu'] = Item 'package-ubuntu.lua',
	['ubuntu64'] = Item 'package-ubuntu64.lua',
	['windows'] = Item 'package-windows.lua'
}

Define.Package = function(Arguments)
	local Output
	if tup.getconfig 'PLATFORM' == 'arch64'
		then Output = ('%s-%d-1-x86_64.pkg.tar.xz'):format(Arguments.Name, Info.Version)
	elseif tup.getconfig 'PLATFORM' == 'ubuntu'
		then Output = ('%s_%d_i386.deb'):format(Arguments.Name, Info.Version)
	elseif tup.getconfig 'PLATFORM' == 'ubuntu64'
		then Output = ('%s_%d_amd64.deb'):format(Arguments.Name, Info.Version)
	elseif tup.getconfig 'PLATFORM' == 'windows'
		then Output = ('%s-%s-x86_64.7z'):format(Arguments.Name, Info.Version)
	end
	if not Output
	then
		print('Unknown platform \'' .. tup.getconfig 'PLATFORM' .. '\'')
		return nil
	end
	if IsTopLevel()
	then
		local Inputs = Item()
		local ScriptArguments = {}

		ScriptArguments[#ScriptArguments + 1] = Arguments.Name

		local StringArgument = function(Name)
			if Arguments[Name]
				then ScriptArguments[#ScriptArguments + 1] = '--' .. Name .. ' "' .. Arguments[Name] .. '"' end
		end
		local ArrayArgument = function(Name, Input)
			if Arguments[Name]
			then
				ScriptArguments[#ScriptArguments + 1] = '--' .. Name
				if Input then Inputs = Inputs:Include(Arguments[Name]) end
				for Index, File in ipairs(Arguments[Name]:Form():Extract('Filename'))
					do ScriptArguments[#ScriptArguments + 1] = File end
			end
		end

		StringArgument 'Dependencies'
		StringArgument 'ArchLicenseStyle'
		StringArgument 'DebianSection'
		ArrayArgument('Executables', true)
		ArrayArgument('Libraries', true)
		ArrayArgument('Resources', true)
		ArrayArgument('Licenses', true)
		ArrayArgument 'ExtraLibraries'
		ArrayArgument 'ExtraQt5PlatformLibraries'
		ArrayArgument 'ExtraVLCPluginLibrariesAccess'
		ArrayArgument 'ExtraVLCPluginLibrariesDemux'
		ArrayArgument 'ExtraVLCPluginLibrariesAudioOutput'
		ArrayArgument 'ExtraVLCPluginLibrariesAudioFilter'
		ArrayArgument 'ExtraVLCPluginLibrariesAudioMixer'
		ArrayArgument 'ExtraVLCPluginLibrariesCodec'
		ArrayArgument 'ExtraLicenses'

		local Script = Scripts[tup.getconfig 'PLATFORM']
		if not Script then error('Unknown platform \'' .. tup.getconfig 'PLATFORM' .. '\'') end

		Define.Lua
		{
			Inputs = Inputs,
			Outputs = Item() + Output + (Arguments.Name .. '-def.txt'),
			Script = tostring(Script),
			Arguments = table.concat(ScriptArguments, ' ')
		}
	end
	return Item(OutputName)
end

