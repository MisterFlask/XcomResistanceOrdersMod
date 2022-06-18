// This is an Unreal Script

class ILB_StrategicResCards extends X2StrategyElement;
	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards (strategic)");
		
		// Templates of the form "if condition X, grant soldier perk Y"
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_StealSparkCore'));
		return Techs;
	}

	static function X2DataTemplate CreateBlankResistanceOrder(name OrderName)
	{
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, OrderName);
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: "  $ OrderName);
		return Template; 
	}


