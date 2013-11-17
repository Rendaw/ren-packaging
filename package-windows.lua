#!/usr/bin/lua

-- Boilerplate
local Root = arg[0]:match '(.+[/\\]).-'
dofile(Root .. 'package.inc.lua')

_G.arg = nil
dofile(Root .. '../info.inc.lua')

local Here = io.popen('pwd'):read() .. '/'

-- XML composition
local XMLMetatable =
{
	__tostring = function(Structure)
		return Structure:Form()
	end,
	__index =
	{
		Form = function(Structure, Depth)
			if not Depth then Depth = 0 end
			local Out = {}
			local Prefix = ''
			local InnerDepth = Depth
			if Structure.Group
			then
				Prefix = '\t'
				InnerDepth = Depth + 1
				Out[#Out + 1] = '<' .. Structure.Group .. (Structure.Parameters and (' ' .. Structure.Parameters) or '') .. '>'
			end
			for Index, Item in ipairs(Structure)
			do
				local Add = Prefix
				if type(Item) == 'table'
				then
					Add = Add .. Item:Form(InnerDepth)
				else
					Add = Add .. '<' .. Item .. (Item:sub(-1) == '?' and '>' or ' />')
				end
				Out[#Out + 1] = Add
			end
			if Structure.Group
				then Out[#Out + 1] = '</' .. Structure.Group .. '>' end
			return table.concat(Out, '\n' .. ('\t'):rep(Depth))
		end,
		Add = function(Structure, Items)
			for Index, Item in ipairs(Items)
			do
				Structure[#Structure + 1] = Item
			end
			return Structure
		end
	}
}

function XMLGroup(Group, Parameters)
	return setmetatable({Group = Group, Parameters = Parameters}, XMLMetatable)
end

-- RTF composition
local AggregateRTF = function(Out, In)
	local Outfile = io.open(Out, 'w+')
	Outfile:write('{\\rtf1\\ansi{\\fonttbl\\f0\\fmodern Pica;}\\f0\\pard\n')

	for Index, Filename in ipairs(In)
	do
		local Infile = io.open(Filename, 'r')
		while true
		do
			Line = Infile:read()
			if not Line then break end
			Outfile:write(Line .. '\\par \n')
		end
		Infile:close()
		Outfile:write('\\par \n\\par \n\\par \n')
	end
	Outfile:close()
end

-- Structure definition
local Version = '1.' .. tostring(Info.Version) .. '.0'

local LanguageCode = 1033
local LanguageCodepageCode = 1252
local LanguageSuffix = ''
--[[if arg[1]
then
	Language = arg[1]
	LanguageSuffix = '-' .. Language
	local LanguageCodes = {
		['ja'] = {1041, 932}
	}
	if LanguageCodes[Language] then
		LanguageCode = LanguageCodes[Language][1]
		LanguageCodepageCode = LanguageCodes[Language][2]
	end
end]]

local ProgramXML = XMLGroup()
local AdvancedStyleXML = XMLGroup()
local ProgramFolderXML = XMLGroup()
local StartMenuFolderXML = XMLGroup()
local EverythingFeaturesXML = XMLGroup()
local XML = XMLGroup():Add
{
	'?xml version="1.0"?',
	XMLGroup('Wix', 'xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension"'):Add
	{
		XMLGroup('Product',
			'Id="*" ' ..
			'UpgradeCode="' .. WIXUpgradeGUID .. '" ' ..
			'Name="' .. Info.ProjectName .. '" ' ..
			'Version="' .. Version .. '" ' ..
			'Manufacturer="' .. Info.Company .. '" ' ..
			'Language="' .. LanguageCode .. '" ' ..
			'Codepage="' .. LanguageCodepageCode .. '"'
		):Add
		{
			'Package InstallerVersion="200" Compressed="yes" Comments="Windows Installer Package" Languages="' .. LanguageCode .. '" SummaryCodepage="' .. LanguageCodepageCode .. '"',
			'Media Id="1" Cabinet="product.cab" EmbedCab="yes"',
			'Property Id="ARPHELPLINK" Value="' .. Info.Website .. '"',
			'Property Id="ARPURLINFOABOUT" Value="' .. Info.CompanyWebsite .. '"',
			ProgramXML,

			-- AdvancedUI stuff - also requires APPLICATIONFOLDER as Id below
			'UIRef Id="WixUI_Advanced"',
			'WixVariable Id="WixUILicenseRtf" Value="licenses.rtf"',
			'Property Id="ApplicationFolderName" Value="' .. Info.ProjectName .. '"',
			'Property Id="WixAppFolder" Value="WixPerMachineFolder"',
			AdvancedStyleXML,

			XMLGroup('Directory', 'Id="TARGETDIR" Name="SourceDir"'):Add
			{
				XMLGroup('Directory', 'Id="ProgramFilesFolder"'):Add
				{
					XMLGroup('Directory', 'Id="APPLICATIONFOLDER" Name="' .. Info.ProjectName .. '"'):Add{ProgramFolderXML}
				},
				XMLGroup('Directory', 'Id="ProgramMenuFolder"'):Add
				{
					XMLGroup('Directory', 'Id="ProgramMenuSubfolder" Name="' .. Info.ProjectName .. '"'):Add{StartMenuFolderXML}
				}
			},
			XMLGroup('Feature', 'Id="Core" Level="1" Absent="disallow" Title="Everything"'):Add{EverythingFeaturesXML}
		}
	}
}

if WIXIcon
then
	ProgramXML:Add
	{
		'Icon Id="Icon32" SourceFile="' .. WIXIcon .. '"',
		'Property Id="ARPPRODUCTICON" Value="Icon32"'
	}
end
if WIXTopBanner then AdvancedStyleXML:Add {'WixVariable Id="WixUIBannerBmp" Value="' .. WIXTopBanner .. '"'} end
if WIXSideBanner then AdvancedStyleXML:Add {'WixVariable Id="WixUIDialogBmp" Value="' .. WIXSideBanner .. '"'} end

local StartMenuFirst = true
for Index, Executable in ipairs(Executables)
do
	local ExecutableFile = Executable:gsub('[^/\\]*[/\\]', '')
	local ExecutableBase = ExecutableFile:gsub('%.%w*$', '')
	ProgramFolderXML:Add
	{
		XMLGroup('Component', 'Id="Executable' .. Index .. '" Guid="*"'):Add
			{'File Id="CoreComponentFile" Source="' .. Executable .. '" KeyPath="yes" Checksum="yes"'}
	}
	local StartMenuComponentXML = XMLGroup('Component', 'Id="ExecutableShortcut' .. Index .. '" Guid="*"'):Add
	{
		'Shortcut Id="ApplicationShortcutFile" Name="' .. ExecutableBase .. '" Target="[APPLICATIONFOLDER]' .. ExecutableFile .. '" WorkingDirectory="PersonalFolder" Icon="Icon32"',
		'RegistryValue Root="HKCU" Key="Software\\' .. Info.Company .. '\\' .. Info.ProjectName .. '" Name="ExecutableShortcut' .. Index .. 'File" Type="integer" Value="1" KeyPath="yes"',
	}
	if StartMenuFirst then StartMenuComponentXML:Add{'RemoveFolder Id="ProgramMenuSubfolder" On="uninstall"'} end
	StartMenuFolderXML:Add{StartMenuComponentXML}
	EverythingFeaturesXML:Add
	{
		'ComponentRef Id="Executable' .. Index .. '"',
		'ComponentRef Id="ExecutableShortcut' .. Index .. '"'
	}
end

StartMenuFolderXML:Add
{
	XMLGroup('Component', 'Id="WebsiteLink" Guid="*"'):Add
	{
		'util:InternetShortcut Id="WebsiteLinkFile" Name="' .. Info.ProjectName .. ' Website" Target="' .. Info.Website .. '"',
		'RegistryValue Root="HKCU" Key="Software\\' .. Info.Company .. '\\' .. Info.ProjectName .. '" Name="WebsiteLink" Type="integer" Value="1" KeyPath="yes"'
	},
	XMLGroup('Component', 'Id="ForumLink" Guid="*"'):Add
	{
		'util:InternetShortcut Id="ForumLinkFile" Name="' .. Info.ProjectName .. ' Forum" Target="' .. Info.Forum .. '"',
		'RegistryValue Root="HKCU" Key="Software\\' .. Info.Company .. '\\' .. Info.ProjectName .. '" Name="ForumLink" Type="integer" Value="1" KeyPath="yes"'
	}
}
EverythingFeaturesXML:Add
{
	'ComponentRef Id="WebsiteLink"',
	'ComponentRef Id="ForumLink"'
}

for Index, Library in ipairs(Libraries)
do
	ProgramFolderXML:Add
	{
		XMLGroup('Component', 'Id="Library' .. Index .. '" Guid="*"'):Add
			{'File Id="CoreComponentFile" Source="' .. Library .. '" KeyPath="yes" Checksum="yes"'}
	}
	EverythingFeaturesXML:Add{'ComponentRef Id="Library' .. Index .. '"'}
end

for Index, Resource in ipairs(Resources)
do
	ProgramFolderXML:Add
	{
		XMLGroup('Component', 'Id="Resource' .. Index .. '" Guid="*"'):Add
			{'File Id="CoreComponentFile" Source="' .. Resource .. '" KeyPath="yes" Checksum="yes"'}
	}
	EverythingFeaturesXML:Add{'ComponentRef Id="Resource"' .. Index .. '"'}
end

for Index, License in ipairs(Licenses)
do
	ProgramFolderXML:Add
	{
		XMLGroup('Component', 'Id="License' .. Index .. '" Guid="*"'):Add
			{'File Id="CoreComponentFile" Source="' .. License .. '" KeyPath="yes" Checksum="yes"'}
	}
	EverythingFeaturesXML:Add{'ComponentRef Id="License' .. Index .. '"'}
end

local FilenamePattern = ('%s-%s-x86_64'):format(Name, Info.Version)
Shell('mkdir temp')
local WIXAllLicenses = {}
for Index, License in ipairs(Licenses) do WIXAllLicenses[#WIXAllLicenses + 1] = License end
for Index, License in ipairs(WIXExtraLicenses) do WIXAllLicenses[#WIXAllLicenses + 1] = License end
AggregateRTF('temp/licenses.rtf', WIXAllLicenses)
io.open('temp/' .. FilenamePattern .. '.wxs',  'w+'):write(tostring(XML) .. '\n\n')
Shell('cat -n temp/' .. FilenamePattern .. '.wxs')
Shell('candle -ext WiXUtilExtension ./temp/' .. FilenamePattern .. '.wxs -out ./temp/' .. FilenamePattern .. '.wixobj')
Shell('light -ext WiXUIExtension ./temp/' .. FilenamePattern .. '.wixobj')
Shell('cp temp/' .. FilenamePattern .. '.msi .')
Shell('cp temp/' .. FilenamePattern .. '.wxs ' .. Name .. '-def.txt')
Shell('rm -r temp')
