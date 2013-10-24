DoOnce 'info.inc.lua'

local Scripts =
{
	['arch64'] = Item 'package-arch64.lua',
	['ubuntu'] = Item 'package-ubuntu.lua',
	['ubuntu64'] = Item 'package-ubuntu64.lua'
}

Define.Package = function(Arguments)
	local Output
	if tup.getconfig 'PLATFORM' == 'arch64'
		then Output = ('%s-%d-1-x86_64.pkg.tar.xz'):format(Arguments.Name, Info.Version)
	elseif tup.getconfig 'PLATFORM' == 'ubuntu'
		then Output = ('%s_%d_i386.deb'):format(Arguments.Name, Info.Version)
	elseif tup.getconfig 'PLATFORM' == 'ubuntu64'
		then Output = ('%s_%d_amd64.deb'):format(Arguments.Name, Info.Version)
	end
	if not Output then error('Unknown platform \'' .. tup.getconfig 'PLATFORM' .. '\'') end
	if IsTopLevel()
	then
		local Inputs = Item()
		local ScriptArguments = {}

		ScriptArguments[#ScriptArguments + 1] = Arguments.Name

		if Arguments.Dependencies
			then ScriptArguments[#ScriptArguments + 1] = '--Dependencies "' .. Arguments.Dependencies .. '"' end

		if Arguments.ArchLicenseStyle
			then ScriptArguments[#ScriptArguments + 1] = '--ArchLicenseStyle ' .. Arguments.ArchLicenseStyle end

		if Arguments.DebianSection
			then ScriptArguments[#ScriptArguments + 1] = '--DebianSection ' .. Arguments.DebianSection end

		ScriptArguments[#ScriptArguments + 1] = '--Executables'
		if Arguments.Executables
		then
			Inputs = Inputs:Include(Arguments.Executables)
			for Index, File in ipairs(Arguments.Executables:Form():Extract('Filename'))
				do ScriptArguments[#ScriptArguments + 1] = File end
		end

		ScriptArguments[#ScriptArguments + 1] = '--Libraries'
		if Arguments.Libraries
		then
			Inputs = Inputs:Include(Arguments.Libraries)
			for Index, File in ipairs(Arguments.Libraries:Form():Extract('Filename'))
				do ScriptArguments[#ScriptArguments + 1] = File end
		end

		ScriptArguments[#ScriptArguments + 1] = '--Resources'
		if Arguments.Resources
		then
			Inputs = Inputs:Include(Arguments.Resources)
			for Index, File in ipairs(Arguments.Resources:Form():Extract('Filename'))
				do ScriptArguments[#ScriptArguments + 1] = File end
		end

		ScriptArguments[#ScriptArguments + 1] = '--Licenses'
		if Arguments.Licenses
		then
			Inputs = Inputs:Include(Arguments.Licenses)
			for Index, File in ipairs(Arguments.Licenses:Form():Extract('Filename'))
				do ScriptArguments[#ScriptArguments + 1] = File end
		end

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

