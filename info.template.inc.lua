Info = 
{
	PackageName = '',
	Company = '',
	ShortDescription = '', -- One sentence
	ExtendedDescription = '', -- Three sentences
	Version = 0,
	Website = 'http://www.zarbosoft.com/PACKAGENAME',
	Forum = 'http://www.zarbosoft.com/forum/index.php?board=BOARDNUMBER',
	CompanyWebsite = 'http://www.zarbosoft.com/',
	Author = 'Rendaw',
	EMail = 'spoo@zarbosoft.com'
}

Arch =
{
	LicenseStyle = 'BSD',
	Dependencies = {} -- In the form 'pkg>=version' as from 'pacman -Q'
}

Ubuntu =
{
	Section = '',
	Dependencies = {} -- In the form 'pkg (>= version)' as from trial and error
}

if arg and arg[1]
then
	print(Info[arg[1]])
end

