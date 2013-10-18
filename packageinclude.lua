Executables = {}
Libraries = {}
Resources = {}
Licenses = {}

local ArgState
for Index = 1, #arg
do
	local Argument = arg[Index]
	if (Argument == '--Executables') or
		(Argument == '--Libraries') or
		(Argument == '--Resources') or
		(Argument == '--Licenses')
	then ArgState = Argument
	elseif not ArgState then error 'First state unspecified.'
	elseif ArgState == '--Executables' then Executables[#Executables + 1] = Argument
	elseif ArgState == '--Libraries' then Libraries[#Libraries + 1] = Argument
	elseif ArgState == '--Resources' then Resources[#Resources + 1] = Argument
	elseif ArgState == '--Licenses' then Licenses[#Licenses + 1] = Argument
	else error 'Unknown state.'
	end
end

