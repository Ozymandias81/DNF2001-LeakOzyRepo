//=============================================================================
// VariableModify. (NJS)
//
// When triggered, modifies the value of the variables indicated by 'Event'
//=============================================================================
class VariableModify expands Triggers;

#exec Texture Import File=Textures\VariableModify.pcx Name=S_VariableModify Mips=Off Flags=2

var () enum EVariableModifyType
{
	VM_Set,				// Sets the variable's value to Argument.
	VM_Add,				// Adds 'Argument' to the variables' current value
	VM_Subtract,		// Subtracts 'Argument' from the variables' current value
	VM_Multiply,		// Multiplies variables' value by argument.
	VM_Divide,			// Divides variables' value by argument.
	VM_Remainder,		// Takes the remainder of the variables' value divided by argument.
	VM_AND,				// Logical And
	VM_OR,				// Logical Or
	VM_NOT,				// Logical Not
	VM_BAND,			// Bitwise And
	VM_BOR,				// Bitwise Or
	VM_BXOR,			// Bitwise Xor 
	VM_BNOT,			// Bitwise Not
	VM_ShiftLeft,		// Shift left
	VM_ShiftRight,		// Shift right
	VM_Factorial,		// Value=Value! (Factorial, ex: 5! = (5*4*3*2*1) = 120
	VM_Random,			// Sets the variable to a random value between 0 and Argument
	VM_Keypad			// Multiply the variables' value by 10 then adds argument
} VariableModifyType;

var () name ArgumentVariable;	// If set then set argument from this.
var () int  Argument;			// Argument to the modification type

function Trigger( actor Other, pawn EventInstigator )
{
	local Variable v;
	local int i,j;
	
	// Do I have an argument variable to assign?
	Argument=GetVariableValue( ArgumentVariable, Argument );
	
	foreach allactors(class'Variable',v,Event)
	{
		switch(VariableModifyType)
		{
			case VM_Set:		v.SetValue(Argument);  							break;
			case VM_Add:		v.SetValue(v.Value+Argument); 					break;
			case VM_Subtract:	v.SetValue(v.Value-Argument); 					break;
			case VM_Multiply:	v.SetValue(v.Value*Argument);					break;
			case VM_Divide:		v.SetValue(v.Value/Argument);					break;
			case VM_Remainder:	v.SetValue(v.Value%Argument);					break;
			case VM_AND:		v.SetValue(int(bool(v.Value)&&bool(Argument)));	break;
			case VM_OR:			v.SetValue(int(bool(v.Value)||bool(Argument)));	break;
			case VM_NOT:		v.SetValue(int(!bool(v.Value)));				break;
			case VM_BAND:		v.SetValue(v.Value&Argument);					break;
			case VM_BOR:		v.SetValue(v.Value|Argument);					break;
			case VM_BXOR:		v.SetValue(v.Value^Argument);					break;
			case VM_BNOT:		v.SetValue(~v.Value);							break;
			case VM_ShiftLeft:	v.SetValue(v.Value<<Argument);				break;
			case VM_ShiftRight:	v.SetValue(v.Value>>Argument);				break;
			case VM_Factorial:	j=1;
								for(i=2;i<=v.Value;i++) j*=i;
								v.SetValue(j);
								break;
								
			case VM_Random:		v.SetValue(Rand(Argument));						break;
			case VM_Keypad:		v.SetValue((v.Value*10)+Argument); 				break;
		}
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_VariableModify'
}
