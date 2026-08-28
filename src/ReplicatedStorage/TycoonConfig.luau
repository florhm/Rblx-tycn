local Config = {}

Config.PlotCount = 6

Config.PlotLayout = {
	{ X = -150, Z = -110, Yaw = 180 },
	{ X = 0, Z = -110, Yaw = 180 },
	{ X = 150, Z = -110, Yaw = 180 },
	{ X = -150, Z = 110, Yaw = 0 },
	{ X = 0, Z = 110, Yaw = 0 },
	{ X = 150, Z = 110, Yaw = 0 },
}
Config.StartingCash = 0

Config.Layout = {
	FloorSize = Vector3.new(90, 2, 70),
	WallHeight = 14,
	BeltCenterZ = -2,
	BeltLength = 40,
	GroundButtonCols = { 28, 35, 42 },
	GroundButtonRows = { -25, -17, -9, -1, 7, 15 },
	Floor2ButtonCols = { 28, 35, 42 },
	Floor2ButtonRows = { -25, -17, -9, -1, 7, 15 },
	Floor3ButtonCols = { 28, 35, 42 },
	Floor3ButtonRows = { -25, -17, -9, -1, 7, 15 },
}

Config.Belt = {
	SpeedTiers = { 10, 16, 24, 34, 46, 60 },
	Colors = {
		Color3.fromRGB(63, 65, 70),
		Color3.fromRGB(70, 130, 220),
		Color3.fromRGB(235, 170, 45),
		Color3.fromRGB(255, 70, 120),
		Color3.fromRGB(180, 90, 255),
		Color3.fromRGB(255, 200, 60),
	},
}

Config.ValueMultiplierTiers = { 1, 2, 4, 8, 16, 32 }

Config.Droppers = {
	Dirt = { Interval = 1.6, Value = 8, Side = "Left", DropZ = -19, Height = 7, SizeScale = 0.9,
		ItemColor = Color3.fromRGB(134, 98, 72), ItemMaterial = Enum.Material.Ground },
	Stone = { Interval = 1.6, Value = 10, Side = "Right", DropZ = -15, Height = 7, SizeScale = 1.0,
		ItemColor = Color3.fromRGB(150, 152, 160), ItemMaterial = Enum.Material.Slate },
	Coal = { Interval = 1.4, Value = 18, Side = "Left", DropZ = -11, Height = 8, SizeScale = 1.05,
		ItemColor = Color3.fromRGB(45, 45, 50), ItemMaterial = Enum.Material.Basalt, Light = true },
	Iron = { Interval = 1.2, Value = 30, Side = "Right", DropZ = -7, Height = 8, SizeScale = 1.1,
		ItemColor = Color3.fromRGB(210, 215, 225), ItemMaterial = Enum.Material.Metal },
	Silver = { Interval = 1.0, Value = 50, Side = "Left", DropZ = -3, Height = 9, SizeScale = 1.15,
		ItemColor = Color3.fromRGB(235, 242, 255), ItemMaterial = Enum.Material.Foil, Light = true },
	Gold = { Interval = 0.85, Value = 85, Side = "Right", DropZ = 1, Height = 9, SizeScale = 1.2,
		ItemColor = Color3.fromRGB(255, 210, 50), ItemMaterial = Enum.Material.Metal, Light = true, Trail = true },
	Diamond = { Interval = 0.7, Value = 140, Side = "Left", DropZ = 5, Height = 10, SizeScale = 1.25,
		ItemColor = Color3.fromRGB(100, 240, 255), ItemMaterial = Enum.Material.Neon, Light = true, Trail = true },
}

Config.Floor2Droppers = {
	Ruby = { Interval = 1.4, Value = 250, Side = "Left", DropZ = -14, Height = 6, SizeScale = 1.3,
		ItemColor = Color3.fromRGB(255, 50, 80), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Emerald = { Interval = 1.2, Value = 450, Side = "Right", DropZ = -9, Height = 6.5, SizeScale = 1.35,
		ItemColor = Color3.fromRGB(50, 255, 120), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Uranium = { Interval = 1.0, Value = 800, Side = "Left", DropZ = -4, Height = 7, SizeScale = 1.4,
		ItemColor = Color3.fromRGB(160, 255, 40), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Voidstone = { Interval = 0.8, Value = 1500, Side = "Right", DropZ = 1, Height = 7.5, SizeScale = 1.5,
		ItemColor = Color3.fromRGB(190, 80, 255), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Neutronium = { Interval = 0.7, Value = 4000, Side = "Left", DropZ = 5, Height = 8, SizeScale = 1.6,
		ItemColor = Color3.fromRGB(120, 230, 255), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Singularity = { Interval = 0.6, Value = 8000, Side = "Right", DropZ = 1, Height = 8.5, SizeScale = 1.7,
		ItemColor = Color3.fromRGB(60, 30, 90), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
	Galaxy = { Interval = 0.5, Value = 16000, Side = "Left", DropZ = -3, Height = 9, SizeScale = 1.8,
		ItemColor = Color3.fromRGB(255, 150, 240), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
}

Config.Floor3Droppers = {
	Quasar = { Interval = 0.45, Value = 40000, Side = "Right", DropZ = 1, Height = 9.5, SizeScale = 1.9,
		ItemColor = Color3.fromRGB(255, 240, 120), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
}

Config.Weapons = {
	Sword = { DisplayName = "Miner's Sword", Type = "Melee", Damage = 35, Range = 9, Cooldown = 0.8,
		BladeColor = Color3.fromRGB(200, 210, 230) },
	Blaster = { DisplayName = "Laser Blaster", Type = "Ray", Damage = 25, Range = 250, Cooldown = 0.45,
		BeamColor = Color3.fromRGB(90, 255, 130), BeamWidth = 0.15 },
	RailGun = { DisplayName = "Rail Gun", Type = "Ray", Damage = 100, Range = 500, Cooldown = 2.0,
		BeamColor = Color3.fromRGB(120, 190, 255), BeamWidth = 0.5 },
	PlasmaCannon = { DisplayName = "Plasma Cannon", Type = "Ray", Damage = 60, Range = 350, Cooldown = 0.7,
		BeamColor = Color3.fromRGB(255, 120, 220), BeamWidth = 0.35 },
	GravityHammer = { DisplayName = "Gravity Hammer", Type = "Melee", Damage = 120, Range = 11, Cooldown = 1.1,
		BladeColor = Color3.fromRGB(180, 140, 255) },
	MeteorStaff = { DisplayName = "Meteor Staff", Type = "Ray", Damage = 220, Range = 600, Cooldown = 3.0,
		BeamColor = Color3.fromRGB(255, 170, 60), BeamWidth = 0.7 },
}

Config.Buttons = {
	{ Id = "Stone", Name = "Stone Dropper", Cost = 100, Requires = nil, Kind = "Dropper", Target = "Stone", Slot = 1 },
	{ Id = "Coal", Name = "Coal Dropper", Cost = 450, Requires = "Stone", Kind = "Dropper", Target = "Coal", Slot = 2 },
	{ Id = "Iron", Name = "Iron Dropper", Cost = 1200, Requires = "Coal", Kind = "Dropper", Target = "Iron", Slot = 3 },
	{ Id = "Silver", Name = "Silver Dropper", Cost = 3000, Requires = "Iron", Kind = "Dropper", Target = "Silver", Slot = 4 },
	{ Id = "Gold", Name = "Gold Dropper", Cost = 7000, Requires = "Silver", Kind = "Dropper", Target = "Gold", Slot = 5 },
	{ Id = "Diamond", Name = "Diamond Dropper", Cost = 15000, Requires = "Gold", Kind = "Dropper", Target = "Diamond", Slot = 6 },
	{ Id = "Belt1", Name = "Faster Belt I", Cost = 250, Requires = nil, Kind = "BeltSpeed", Target = "2", Slot = 7 },
	{ Id = "Belt2", Name = "Faster Belt II", Cost = 2500, Requires = "Belt1", Kind = "BeltSpeed", Target = "3", Slot = 8 },
	{ Id = "Value1", Name = "Value x2", Cost = 2000, Requires = nil, Kind = "ValueTier", Target = "2", Slot = 9 },
	{ Id = "Value2", Name = "Value x4", Cost = 8000, Requires = "Value1", Kind = "ValueTier", Target = "3", Slot = 10 },
	{ Id = "WallBack", Name = "Back Wall", Cost = 1500, Requires = nil, Kind = "Wall", Target = "Back", Slot = 11 },
	{ Id = "WallLeft", Name = "Left Wall", Cost = 1500, Requires = nil, Kind = "Wall", Target = "Left", Slot = 12 },
	{ Id = "WallRight", Name = "Right Wall", Cost = 1500, Requires = nil, Kind = "Wall", Target = "Right", Slot = 13 },
	{ Id = "WallFront", Name = "Front Wall + Door", Cost = 1500, Requires = "WallBack", Kind = "Wall", Target = "Front", Slot = 14 },
	{ Id = "Stairs", Name = "Stairs + Floor 2", Cost = 8000, Requires = "Value1", Kind = "Stairs", Target = nil, Slot = 15 },
	{ Id = "Laser", Name = "Security Laser", Cost = 6000, Requires = "WallFront", Kind = "Laser", Target = nil, Slot = 16 },
	{ Id = "Complete1", Name = "TYCOON COMPLETE", Cost = 35000, Requires = "Diamond", Kind = "Complete", Target = "1", Slot = 17 },
	{ Id = "Manager", Name = "Hire Manager", Cost = 12000, Requires = "Stone", Kind = "Manager", Target = nil, Slot = 18 },

	{ Id = "Ruby", Name = "Ruby Rig", Cost = 25000, Requires = "Stairs", Kind = "Dropper", Target = "Ruby", Slot = 1, Floor2 = true },
	{ Id = "Emerald", Name = "Emerald Crusher", Cost = 45000, Requires = "Ruby", Kind = "Dropper", Target = "Emerald", Slot = 2, Floor2 = true },
	{ Id = "Uranium", Name = "Uranium Refinery", Cost = 80000, Requires = "Emerald", Kind = "Dropper", Target = "Uranium", Slot = 3, Floor2 = true },
	{ Id = "Voidstone", Name = "Voidstone Extractor", Cost = 140000, Requires = "Uranium", Kind = "Dropper", Target = "Voidstone", Slot = 4, Floor2 = true },
	{ Id = "Neutronium", Name = "Neutronium Forge", Cost = 350000, Requires = "Voidstone", Kind = "Dropper", Target = "Neutronium", Slot = 5, Floor2 = true },
	{ Id = "Singularity", Name = "Singularity Core", Cost = 800000, Requires = "Neutronium", Kind = "Dropper", Target = "Singularity", Slot = 6, Floor2 = true },
	{ Id = "Galaxy", Name = "Galaxy Reactor", Cost = 1800000, Requires = "Singularity", Kind = "Dropper", Target = "Galaxy", Slot = 7, Floor2 = true },
	{ Id = "Sword", Name = "Miner's Sword", Cost = 15000, Requires = "Stairs", Kind = "Weapon", Target = "Sword", Slot = 8, Floor2 = true },
	{ Id = "Blaster", Name = "Laser Blaster", Cost = 50000, Requires = "Sword", Kind = "Weapon", Target = "Blaster", Slot = 9, Floor2 = true },
	{ Id = "RailGun", Name = "Rail Gun", Cost = 120000, Requires = "Blaster", Kind = "Weapon", Target = "RailGun", Slot = 10, Floor2 = true },
	{ Id = "Value3", Name = "Value x8", Cost = 60000, Requires = "Value2", Kind = "ValueTier", Target = "4", Slot = 11, Floor2 = true },
	{ Id = "Belt3", Name = "Faster Belt III", Cost = 40000, Requires = "Belt2", Kind = "BeltSpeed", Target = "4", Slot = 12, Floor2 = true },
	{ Id = "Value4", Name = "Value x16", Cost = 250000, Requires = "Value3", Kind = "ValueTier", Target = "5", Slot = 13, Floor2 = true },
	{ Id = "Belt4", Name = "Faster Belt IV", Cost = 160000, Requires = "Belt3", Kind = "BeltSpeed", Target = "5", Slot = 14, Floor2 = true },
	{ Id = "Complete2", Name = "EMPIRE COMPLETE", Cost = 2500000, Requires = "Galaxy", Kind = "Complete", Target = "2", Slot = 15, Floor2 = true },
	{ Id = "Floor3", Name = "Build Floor 3", Cost = 3000000, Requires = "Complete2", Kind = "Floor3", Target = nil, Slot = 17, Floor2 = true },
	{ Id = "Garden", Name = "Buy Garden Decor", Cost = 8000, Requires = "Value2", Kind = "Decor", Target = "Garden", Slot = 18, Floor2 = true },
	{ Id = "Prestige", Name = "PRESTIGE!", Cost = 5000000, Requires = "Complete2", Kind = "Prestige", Target = nil, Slot = 16, Floor2 = true },

	{ Id = "Quasar", Name = "Quasar Reactor", Cost = 6000000, Requires = "Floor3", Kind = "Dropper", Target = "Quasar", Slot = 1, Floor3 = true },
	{ Id = "PlasmaCannon", Name = "Plasma Cannon", Cost = 800000, Requires = "Floor3", Kind = "Weapon", Target = "PlasmaCannon", Slot = 2, Floor3 = true },
	{ Id = "GravityHammer", Name = "Gravity Hammer", Cost = 1500000, Requires = "PlasmaCannon", Kind = "Weapon", Target = "GravityHammer", Slot = 3, Floor3 = true },
	{ Id = "MeteorStaff", Name = "Meteor Staff", Cost = 3000000, Requires = "GravityHammer", Kind = "Weapon", Target = "MeteorStaff", Slot = 4, Floor3 = true },
	{ Id = "Value5", Name = "Value x32", Cost = 400000, Requires = "Value4", Kind = "ValueTier", Target = "6", Slot = 5, Floor3 = true },
	{ Id = "Belt5", Name = "Faster Belt V", Cost = 300000, Requires = "Belt4", Kind = "BeltSpeed", Target = "6", Slot = 6, Floor3 = true },
	{ Id = "Statue", Name = "Buy Gold Statue", Cost = 200000, Requires = "Floor3", Kind = "Decor", Target = "Statue", Slot = 7, Floor3 = true },
	{ Id = "Complete3", Name = "GALAXY DOMINATED", Cost = 8000000, Requires = "MeteorStaff", Kind = "Complete", Target = "3", Slot = 8, Floor3 = true },
}

return Config
