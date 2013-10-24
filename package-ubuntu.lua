#!/usr/bin/lua

local Root = arg[0]:match '(.+[/\\]).-'

if not Architecture then Architecture = 'i386' end

dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Stem = Name .. '-temp/' .. Name
Shell('mkdir -p ' .. Stem)

local Place = function(Filenames, Destination, Disambig)
	if #Filenames == 0 then return end
	Shell('mkdir -p ' .. Stem .. Destination)
	for Index, Filename in ipairs(Filenames)
	do
		local DestFilename = Filename:gsub('[^/\\]*[/\\]', '')
		if Disambig then DestFilename = Disambig .. DestFilename end
		Shell('cp ' .. Filename .. ' ' .. Stem .. Destination .. '/' .. DestFilename)
	end
end

Place(Executables, '/usr/bin')
Place(Libraries, '/usr/lib')
Place(Resources, '/usr/share/' .. Info.ProjectName)
Place(Licenses, '/usr/share/doc/' .. Info.ProjectName, Name .. '-')

local InstalledSize = io.popen('du -s -BK ' .. Stem):read():gsub('[^%d].*$', '')
print('Installed size is ' .. InstalledSize)

Shell('mkdir -p ' .. Stem .. '/DEBIAN')
io.open(Stem .. '/DEBIAN/control', 'w+'):write([[
Package: ]] .. Name .. '\n' .. [[
Version: ]] .. Info.Version .. '\n' .. [[
Section: ]] .. DebianSection .. '\n' .. [[
Priority: Optional
Architecture: ]] .. Architecture .. '\n' .. [[
Depends: ]] .. (Dependencies or '') .. '\n' .. [[
Maintainer: ]] .. Info.Author .. ' <' .. Info.EMail .. [[>
Description: ]] .. Info.ExtendedDescription .. '\n' .. [[
Installed-Size: ]] .. InstalledSize .. '\n' .. [[
Homepage: ]] .. Info.Website .. '\n' .. [[
]]):close()

Shell('cd ' .. Name .. '-temp && fakeroot dpkg --build ' .. Name .. ' .')
Shell('cp ' .. Name .. '-temp/' .. Name .. '_' .. tostring(Info.Version) .. '_' .. Architecture .. '.deb .')
Shell('cp ' .. Stem .. '/DEBIAN/control ' .. Name .. '-def.txt')
Shell('rm -r ' .. Name .. '-temp')

