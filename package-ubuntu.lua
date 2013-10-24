#!/usr/bin/lua

local Root = arg[0]:match '(.+[/\\]).-'

if not Architecture then Architecture = 'i386' end

dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Place = function(Filenames, Destination, Disambig)
	if #Filenames == 0 then return end
	os.execute('mkdir -p ' .. Name .. '$pkgdir' .. Destination)
	for Index, Filename in ipairs(Filenames)
	do
		local DestFilename = Filename:gsub('[^/\\]*[/\\]', '')
		if Disambig then DestFilename = Disambig .. DestFilename end
		os.execute('cp ' .. Filename .. ' ' .. Destination .. '/' .. DestFilename)
	end
end

Place(Executables, '/usr/bin')
Place(Libraries, '/usr/lib')
Place(Resources, '/usr/share/' .. Info.ProjectName)
Place(Licenses, '/usr/share/doc/' .. Info.ProjectName, Name .. '-')

local InstalledSize = io.popen('du -s -BK ' .. Name):read():gsub('[^%d].*$', '')
print('Installed size is ' .. InstalledSize)

if not os.execute('mkdir -p ' .. Name .. '/DEBIAN') then os.exit(1) end
io.open(Name .. '/DEBIAN/control', 'w+'):write([[
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

if not os.execute('fakeroot dpkg --build ' .. Name .. ' .') then os.exit(1) end
if not os.execute('cp ' .. Name .. '/DEBIAN/control ' .. Name .. '-def.txt') then os.exit(1) end
if not os.execute('rm -r ' .. Name) then os.exit(1) end

