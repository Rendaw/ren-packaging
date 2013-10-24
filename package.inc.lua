Name = nil
Dependencies = nil
ArchLicenseStyle = nil
DebianSection = nil
Executables = {}
Libraries = {}
Resources = {}
Licenses = {}

local States =
{
	['--Dependencies'] = function(Argument) Dependencies = Argument end,
	['--ArchLicenseStyle'] = function(Argument) ArchLicenseStyle = Argument end,
	['--DebianSection'] = function(Argument) DebianSection = Argument end,
	['--Executables'] = function(Argument) Executables[#Executables + 1] = Argument end,
	['--Libraries'] = function(Argument) Libraries[#Libraries + 1] = Argument end,
	['--Resources'] = function(Argument) Resources[#Resources + 1] = Argument end,
	['--Licenses'] = function(Argument) Licenses[#Licenses + 1] = Argument end
}

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

