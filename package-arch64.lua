#!/usr/bin/lua

dofile 'packageinclude.lua'

_G.arg = nil
dofile '../info.lua'

local Here = io.popen('pwd'):read() .. '/'

local ScriptSituation = function(Filenames, Destination)
	if #Filenames == 0 then return '' end
	local Out = {}
	for Filename in ipairs(Filenames)
		do Out[#Out + 1] = '\tcp ' .. Here .. Filename .. ' $pkgdir' .. Destination .. '\n' end
	return '\tmkdir -p $pkgdir/usr/bin/\n' .. 
		table.concat(Out) .. '\n'
end

os.execute('mkdir temp')
io.open('temp/PKGBUILD', 'w+'):write([[
pkgname=]] .. Info.PackageName .. '\n' .. [[
pkgver=]] .. Info.Version .. '\n' .. [[
pkgrel=1
epoch=
pkgdesc="]] .. Info.ShortDescription .. [["
arch=('x86_64')
url="]] .. Info.Website .. [["
license=(']] .. Arch.LicenseStyle .. [[')
groups=()
depends=(']] .. table.concat(Arch.Dependencies, '\', \'') .. [[')
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
]] .. ScriptSituation(Executables, '/usr/lib') .. [[
]] .. ScriptSituation(Resources, '/usr/share/' .. Info.PackageName .. [[
]] .. ScriptSituation(Licenses, '/usr/share/licenses/' .. Info.PackageName .. [[
}
]]):close()

os.execute('mkdir temp/src')
os.execute('cd temp && makepkg --repackage --noextract --nocheck --force')
os.execute('cp temp/' .. Info.PackageName .. '-' .. tostring(Info.Version) .. '-1-x86_64.pkg.tar.xz .')
os.execute('cp temp/PKGBUILD .')
os.execute('rm -r temp')

