#!/usr/bin/lua

local Root = arg[0]:match '(.+[/\\]).-'
dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Here = io.popen('pwd'):read() .. '/'

local ScriptSituation = function(Filenames, Destination)
	if #Filenames == 0 then return '' end
	local Out = {}
	for Index, Filename in ipairs(Filenames)
		do Out[#Out + 1] = '\tcp ' .. Here .. Filename .. ' $pkgdir' .. Destination .. '\n' end
	return '\tmkdir -p $pkgdir' .. Destination .. '\n' ..
		table.concat(Out)
end

if not os.execute('mkdir temp') then os.exit(1) end
io.open('temp/PKGBUILD', 'w+'):write([[
pkgname=]] .. Info.PackageName .. '\n' .. [[
pkgver=]] .. Info.Version .. '\n' .. [[
pkgrel=1
epoch=
pkgdesc="]] .. Info.ShortDescription .. [["
arch=('x86_64')
url="]] .. Info.Website .. [["
license=(']] .. Arch64.LicenseStyle .. [[')
groups=()
depends=(']] .. table.concat(Arch64.Dependencies, '\', \'') .. [[')
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
]] .. ScriptSituation(Resources, '/usr/share/' .. Info.PackageName) .. [[
]] .. ScriptSituation(Licenses, '/usr/share/licenses/' .. Info.PackageName) .. [[
}
]]):close()

if not os.execute('mkdir temp/src') then os.exit(1) end
if not os.execute('cd temp && makepkg --nodeps --repackage --noextract --nocheck --force') then os.exit(1) end
if not os.execute('cp temp/' .. Info.PackageName .. '-' .. tostring(Info.Version) .. '-1-x86_64.pkg.tar.xz .') then os.exit(1) end
if not os.execute('cp temp/PKGBUILD .') then os.exit(1) end
if not os.execute('rm -r temp') then os.exit(1) end

