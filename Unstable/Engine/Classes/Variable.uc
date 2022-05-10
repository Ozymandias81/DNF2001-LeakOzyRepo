//=============================================================================
// Variable. (NJS)
//
// Retains a value.  When this value has a certain relationship with 
// 'ComparisonValue' the 'Event' trigger is fired.
//=============================================================================
class Variable expands Triggers;

#exec Texture Import File=Textures\Variable.pcx Name=S_Variable Mips=Off Flags=2

var () int Value;					// Current value of the variable
var () name ValueVariable;			// Variable to get value from when not ''
var () int ComparisonValue;			// Value to compare current value to.
var () name ComparisonValueVariable;// Variable to get comparison value from.
var () int OtherComparisonValue;	// Other value to compare to. (For types that take more than one parameter)
var () bool OnlyTestOnTrigger;		// Only compare on trigger, (ignore when variable is set)
var () bool PrintValue;				// Prints the value when it is modified. (For debugging)

var () enum EVariableTriggerType
{
	VT_None,			// Don't trigger based on comparison.
	VT_Equal,	 		// Trigger when value is equal to ComparisonValue.
	VT_Greater,  		// Trigger when value is greater than ComparisonValue.
	VT_GreaterOrEqual,	// Trigger when value is greater or equal to ComparisonValue.
	VT_Less,	 		// Trigger when value is less than ComparisonValue.
	VT_LessOrEqual,		// Trigger when value is less or equal to ComparisonValue.
	VT_NotEqual,		// Trigger when value is not equal to ComparisonValue.
	VT_Range			// Trigger when  ComparisonValue <= Value <= OtherComparisonValue
} VariableTriggerType;

function bool TestValue()
{
	local bool result;
	
	// Snag values from variables when needed:
	Value=GetVariableValue( ValueVariable, Value );
	ComparisonValue=GetVariableValue( ComparisonValueVariable, ComparisonValue );

	result=false;
	
	switch(VariableTriggerType)
	{
		case VT_None:			result=false;						break;
		case VT_Equal: 	 		result=(Value==ComparisonValue); 	break;
		case VT_Greater: 		result=(Value>ComparisonValue); 	break;
		case VT_GreaterOrEqual:	result=(Value>=ComparisonValue); 	break;
		case VT_Less:			result=(Value<ComparisonValue);	break;
		case VT_LessOrEqual:	result=(Value<=ComparisonValue); 	break;
		case VT_NotEqual:		result=(Value!=ComparisonValue);    break;
		case VT_Range:			result=((ComparisonValue<=Value)&&(Value<=OtherComparisonValue)); break;
	}
	
	// Did the condition pass?
	if(result)
		GlobalTrigger(Event,Instigator);	// Splorf the triggeer
		
	return result;	// For reference fun.
}

function SetValue( int newValue )
{
	Value=newValue;	// Set the new value.
	
	// Should I print my value when modified?
	if(PrintValue)
		BroadcastMessage( tag$" = "$Value, true);
	
	// Should I only test on trigger?
	if(!OnlyTestOnTrigger) 
		TestValue();
}

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator=EventInstigator;
	TestValue();	// See if I pass.
}

defaultproperties
{
}
