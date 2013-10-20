#!/usr/bin/lua

local Root = arg[0]:match '(.+[/\\]).-'

if not Architecture then Architecture = 'i386' end

dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

if #Executables > 0 then
	local Dest = Info.PackageName .. '/usr/bin'
	os.execute('mkdir -p ' .. Dest)
	for Index, File in ipairs(Executables) do os.execute('cp ' .. File .. ' ' .. Dest) end
end
if #Libraries > 0 then
	local Dest = Info.PackageName .. '/usr/lib'
	os.execute('mkdir -p ' .. Dest)
	for Index, File in ipairs(Libraries) do os.execute('cp ' .. File .. ' ' .. Dest) end
end
if #Resources > 0 then
	local Dest = Info.PackageName .. '/usr/share/' .. Info.PackageName
	os.execute('mkdir -p ' .. Dest)
	for Index, File in ipairs(Resources) do os.execute('cp ' .. File .. ' ' .. Dest) end
end
if #Licenses > 0 then
	local Dest = Info.PackageName .. '/usr/share/doc/' .. Info.PackageName
	os.execute('mkdir -p ' .. Dest)
	for Index, File in ipairs(Licenses) do os.execute('cp ' .. File .. ' ' .. Dest) end
end

local InstalledSize = io.popen('du -s -BK ' .. Info.PackageName):read():gsub('[^%d].*$', '')
print('Installed size is ' .. InstalledSize)

if not os.execute('mkdir -p ' .. Info.PackageName .. '/DEBIAN') then os.exit(1) end
io.open(Info.PackageName .. '/DEBIAN/control', 'w+'):write([[
Package: ]] .. Info.PackageName .. '\n' .. [[
Version: ]] .. Info.Version .. '\n' .. [[
Section: ]] .. Ubuntu.Section .. '\n' .. [[
Priority: Optional
Architecture: ]] .. Architecture .. '\n' .. [[
Depends: ]] .. table.concat(Ubuntu.Dependencies, ', ') .. '\n' .. [[
Maintainer: ]] .. Info.Author .. ' <' .. Info.EMail .. [[>
Description: ]] .. Info.ExtendedDescription .. '\n' .. [[
Installed-Size: ]] .. InstalledSize .. '\n' .. [[
Homepage: ]] .. Info.Website .. '\n' .. [[
]]):close()

if not os.execute('fakeroot dpkg --build ' .. Info.PackageName .. ' .') then os.exit(1) end
if not os.execute('cp ' .. Info.PackageName .. '/DEBIAN/control packagedef.txt') then os.exit(1) end
if not os.execute('rm -r ' .. Info.PackageName) then os.exit(1) end

