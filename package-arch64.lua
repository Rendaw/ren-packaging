#!/usr/bin/lua

local Root = arg[0]:match '(.+[/\\]).-'
dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Here = io.popen('pwd'):read() .. '/'

local ScriptSituation = function(Filenames, Destination, Disambig)
	if #Filenames == 0 then return '' end
	local Out = {}
	for Index, Filename in ipairs(Filenames)
	do
		local DestFilename = Filename:gsub('[^/\\]*[/\\]', '')
		if Disambig then DestFilename = Disambig .. DestFilename end
		Out[#Out + 1] = '\tcp ' .. Here .. Filename .. ' $pkgdir' .. Destination .. '/' .. DestFilename .. '\n'
	end
	return '\tmkdir -p $pkgdir' .. Destination .. '\n' ..
		table.concat(Out)
end

Shell('mkdir temp')
io.open('temp/PKGBUILD', 'w+'):write([[
pkgname=]] .. Name .. '\n' .. [[
pkgver=]] .. Info.Version .. '\n' .. [[
pkgrel=1
epoch=
pkgdesc="]] .. Info.ShortDescription .. [["
arch=('x86_64')
url="]] .. Info.Website .. [["
license=(']] .. ArchLicenseStyle .. [[')
groups=()
depends=(]] .. (Dependencies or '') .. [[)
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=($pkgname-$pkgver.tar.gz)
noextract=()
md5sums=('')

package() {
]] .. ScriptSituation(Executables, '/usr/bin') .. [[
]] .. ScriptSituation(Libraries, '/usr/lib') .. [[
]] .. ScriptSituation(Resources, '/usr/share/' .. Info.ProjectName) .. [[
]] .. ScriptSituation(Licenses, '/usr/share/licenses/' .. Info.ProjectName, Name .. '-') .. [[
}
]]):close()

Shell('mkdir temp/src')
Shell('cd temp && makepkg --nodeps --repackage --noextract --nocheck --force')
Shell('cp temp/' .. Name .. '-' .. tostring(Info.Version) .. '-1-x86_64.pkg.tar.xz .')
Shell('cp temp/PKGBUILD ' .. Name .. '-def.txt')
Shell('rm -r temp')

