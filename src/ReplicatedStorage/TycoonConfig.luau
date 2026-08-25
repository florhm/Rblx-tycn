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
	Floor2ButtonRows = { -25, -17, -9, -1 },
}

Config.Belt = {
	SpeedTiers = { 8, 14, 20, 30 },
	Colors = {
		Color3.fromRGB(63, 65, 70),
		Color3.fromRGB(70, 130, 220),
		Color3.fromRGB(235, 170, 45),
		Color3.fromRGB(255, 70, 120),
	},
}

Config.ValueMultiplierTiers = { 1, 2, 4, 8 }

Config.Droppers = {
	Dirt = { Interval = 2.0, Value = 5, Side = "Left", DropZ = -19, Height = 7,
		ItemColor = Color3.fromRGB(124, 92, 70), ItemMaterial = Enum.Material.Ground },
	Stone = { Interval = 1.8, Value = 8, Side = "Right", DropZ = -15, Height = 7,
		ItemColor = Color3.fromRGB(130, 132, 138), ItemMaterial = Enum.Material.Slate },
	Coal = { Interval = 1.6, Value = 14, Side = "Left", DropZ = -11, Height = 8,
		ItemColor = Color3.fromRGB(38, 38, 42), ItemMaterial = Enum.Material.Basalt },
	Iron = { Interval = 1.4, Value = 22, Side = "Right", DropZ = -7, Height = 8,
		ItemColor = Color3.fromRGB(192, 196, 204), ItemMaterial = Enum.Material.Metal },
	Silver = { Interval = 1.2, Value = 35, Side = "Left", DropZ = -3, Height = 9,
		ItemColor = Color3.fromRGB(222, 228, 238), ItemMaterial = Enum.Material.Foil },
	Gold = { Interval = 1.0, Value = 55, Side = "Right", DropZ = 1, Height = 9,
		ItemColor = Color3.fromRGB(255, 200, 50), ItemMaterial = Enum.Material.Metal },
	Diamond = { Interval = 0.8, Value = 90, Side = "Left", DropZ = 5, Height = 10,
		ItemColor = Color3.fromRGB(110, 230, 255), ItemMaterial = Enum.Material.Neon },
}

Config.Floor2Droppers = {
	Ruby = { Interval = 1.6, Value = 150, Side = "Left", DropZ = -14, Height = 6,
		ItemColor = Color3.fromRGB(255, 60, 90), ItemMaterial = Enum.Material.Neon, Machine = true },
	Emerald = { Interval = 1.4, Value = 260, Side = "Right", DropZ = -9, Height = 6.5,
		ItemColor = Color3.fromRGB(60, 255, 130), ItemMaterial = Enum.Material.Neon, Machine = true },
	Uranium = { Interval = 1.2, Value = 450, Side = "Left", DropZ = -4, Height = 7,
		ItemColor = Color3.fromRGB(150, 255, 60), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true },
	Voidstone = { Interval = 1.0, Value = 800, Side = "Right", DropZ = 1, Height = 7.5,
		ItemColor = Color3.fromRGB(180, 90, 255), ItemMaterial = Enum.Material.Neon, Machine = true, Light = true, Trail = true },
}

Config.Weapons = {
	Sword = { DisplayName = "Miner's Sword", Type = "Melee", Damage = 35, Range = 9, Cooldown = 0.8,
		BladeColor = Color3.fromRGB(200, 210, 230) },
	Blaster = { DisplayName = "Laser Blaster", Type = "Ray", Damage = 25, Range = 250, Cooldown = 0.45,
		BeamColor = Color3.fromRGB(90, 255, 130), BeamWidth = 0.15 },
	RailGun = { DisplayName = "Rail Gun", Type = "Ray", Damage = 100, Range = 500, Cooldown = 2.0,
		BeamColor = Color3.fromRGB(120, 190, 255), BeamWidth = 0.5 },
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

	{ Id = "Ruby", Name = "Ruby Rig", Cost = 25000, Requires = "Stairs", Kind = "Dropper", Target = "Ruby", Slot = 1, Floor2 = true },
	{ Id = "Emerald", Name = "Emerald Crusher", Cost = 45000, Requires = "Ruby", Kind = "Dropper", Target = "Emerald", Slot = 2, Floor2 = true },
	{ Id = "Uranium", Name = "Uranium Refinery", Cost = 80000, Requires = "Emerald", Kind = "Dropper", Target = "Uranium", Slot = 3, Floor2 = true },
	{ Id = "Voidstone", Name = "Voidstone Extractor", Cost = 140000, Requires = "Uranium", Kind = "Dropper", Target = "Voidstone", Slot = 4, Floor2 = true },
	{ Id = "Sword", Name = "Miner's Sword", Cost = 15000, Requires = "Stairs", Kind = "Weapon", Target = "Sword", Slot = 5, Floor2 = true },
	{ Id = "Blaster", Name = "Laser Blaster", Cost = 50000, Requires = "Sword", Kind = "Weapon", Target = "Blaster", Slot = 6, Floor2 = true },
	{ Id = "RailGun", Name = "Rail Gun", Cost = 120000, Requires = "Blaster", Kind = "Weapon", Target = "RailGun", Slot = 7, Floor2 = true },
	{ Id = "Value3", Name = "Value x8", Cost = 60000, Requires = "Value2", Kind = "ValueTier", Target = "4", Slot = 8, Floor2 = true },
	{ Id = "Belt3", Name = "Faster Belt III", Cost = 40000, Requires = "Belt2", Kind = "BeltSpeed", Target = "4", Slot = 9, Floor2 = true },
	{ Id = "Complete2", Name = "EMPIRE COMPLETE", Cost = 250000, Requires = "Voidstone", Kind = "Complete", Target = "2", Slot = 10, Floor2 = true },
}

return Config
