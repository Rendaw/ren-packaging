DoOnce 'info.lua'

Define.Package = function(Args)
	local Output
	if tup.getconfig('PLATFORM') == 'arch64' 
		then Output = ('%s-%d-1-x86_64.pkg.tar.xz'):format(Info.PackageName, Info.Version)
	elseif tup.getconfig('PLATFORM') == 'ubuntu12' 
		then Output = ('%s_%d_i386.deb'):format(Info.PackageName, Info.Version),
	if tup.getconfig('PLATFORM') == 'ubuntu12_64' 
		then Output = ('%s_%d_amd64.deb'):format(Info.PackageName, Info.Version),
	end
	if not Output then error('Unknown platform ' .. tup.getconfig('PLATFORM')) end
	if IsTopLevel
	then
		local Inputs = Item()
		local ScriptArguments = {}

		Arguments[#Arguments + 1] = '--Executables'
		if Args.Executables 
		then 
			Inputs = Inputs:Include(Args.Executables) 
			for File in ipairs(Args.Executables:Form():Extract('Filename')) 
				do Argument[#Arguments + 1] = File end
		end

		Arguments[#Arguments + 1] = '--Libraries'
		if Args.Libraries 
		then 
			Inputs = Inputs:Include(Args.Libraries) 
			for File in ipairs(Args.Libraries:Form():Extract('Filename')) 
				do Argument[#Arguments + 1] = File end
		end

		Arguments[#Arguments + 1] = '--Resources'
		if Args.Resources 
		then 
			Inputs = Inputs:Include(Args.Resources) 
			for File in ipairs(Args.Resources:Form():Extract('Filename')) 
				do Argument[#Arguments + 1] = File end
		end

		Arguments[#Arguments + 1] = '--Licenses'
		if Args.Licenses 
		then 
			Inputs = Inputs:Include(Args.Licenses) 
			for File in ipairs(Args.Licenses:Form():Extract('Filename')) 
				do Argument[#Arguments + 1] = File end
		end

		local Script
		if tup.getconfig('PLATFORM') == 'arch64' then Script = 'package-arch64.lua'
		elseif tup.getconfig('PLATFORM') == 'ubuntu12' then Script = 'package-ubuntu12.lua'
		if tup.getconfig('PLATFORM') == 'ubuntu12_64' then Script = 'package-ubuntu12_64.lua'
		end
		if not Script then error('Unknown platform ' .. tup.getconfig('PLATFORM')) end

		Define.Lua
		{
			Inputs = Inputs,
			Outputs = Item(OutputName):Include('PKGBUILD'),
			Script = Script,
			Arguments = table.concat(ScriptArguments, ' ')
		}
	end
	return Item(OutputName)
end

