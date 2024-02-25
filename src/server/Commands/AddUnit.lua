return {
	Name = "addunit";
	Aliases = {"adu"};
	Description = "Adds an unit to a players inventory";
	Group = "Admin";
	Args = {
		{
			Type = "player";
			Name = "to_add";
			Description = "The player to add the unit";
		},
		{
			Type = "string";
			Name = "unitname";
			Description = "The unit name"
		}
	};
}