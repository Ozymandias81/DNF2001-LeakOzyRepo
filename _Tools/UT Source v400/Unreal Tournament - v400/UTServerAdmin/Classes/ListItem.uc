class ListItem expands Object;

var ListItem 	Next;
var ListItem	Prev;

var String	Tag;			// sorted element
var String	Data;			// saved data
var bool	bJustMoved; 	// if the map was just moved, keep it selected

function AddElement(ListItem NewElement)
{
	local ListItem TempItem;
	
	for (TempItem = self; TempItem.Next != None; TempItem = TempItem.Next);
	
	TempItem.Next = NewElement;
	NewElement.Prev = TempItem;
	NewElement.Next = None;
}

function AddSortedElement(out ListItem FirstElement, ListItem NewElement)
{
	local ListItem TempItem;
	
	// find item which new should be inserted after
	TempItem = FirstElement;
	while (TempItem != None)
	{
		// if current is less or equal than new, but is at the end
		if (Caps(TempItem.Tag) <= Caps(NewElement.Tag) && TempItem.Next == None)
		{
			TempItem.Next = NewElement;
			NewElement.Prev = TempItem;
			NewElement.Next = None;
			break;
		} // else if current is greater than new
		else if (Caps(TempItem.Tag) > Caps(NewElement.Tag))
		{	// if current.prev == none, then make it the new first element
			if (TempItem.Prev == None)
				FirstElement = NewElement;
			else
				TempItem.Prev.Next = NewElement;
		
			NewElement.Prev = TempItem.Prev;
			NewElement.Next = TempItem;
			TempItem.Prev = NewElement;
			break;
		}
		TempItem = TempItem.Next;
	}
}

function ListItem FindItem(String SearchData)
{
	local ListItem	TempItem;
	
	for (TempItem = self; TempItem != None; TempItem = TempItem.Next)
	{
		if (TempItem.Data ~= SearchData)
			return TempItem;
	}
	return None;
}


function ListItem DeleteElement(out ListItem First, optional String SearchData)
{
	local ListItem TempItem;
	for (TempItem = self; TempItem != None; TempItem = TempItem.Next)
	{
		if (TempItem.Data ~= SearchData || SearchData == "") {
			// if no prev, assume this is the first element
			if (TempItem == First || TempItem.Prev == None) {
				First = TempItem.Next;
				if (First != None)
					First.Prev = None;
			}
			else {		// close the links around TempItem
				if (TempItem.Prev != None)
					TempItem.Prev.Next = TempItem.Next;	
				if (TempItem.Next != None)
					TempItem.Next.Prev = TempItem.Prev;
			}
			
			TempItem.Prev = None;
			TempItem.Next = None;
			break;
		}
	}
	return TempItem;
}

function MoveElementUp(out ListItem First, ListItem MoveItem, out int Count)
{
	local ListItem TempItem;
	local int TempCount;

	if (MoveItem != None) {
		for (TempCount = Count; TempCount > 0 && MoveItem.Prev != None; TempCount--) {
			TempItem = MoveItem.Prev;
			MoveItem.Prev = TempItem.Prev;
			if (MoveItem.Prev != None)
				MoveItem.Prev.Next = MoveItem;
			TempItem.Next = MoveItem.Next;
			if (TempItem.Next != None)
				TempItem.Next.Prev = TempItem;
			MoveItem.Next = TempItem;
			TempItem.Prev = MoveItem;
			
			if (TempItem == First)
				First = MoveItem;
		}
		Count = Count - TempCount;
	}
}

function MoveElementDown(out ListItem First, ListItem MoveItem, out int Count)
{
	local ListItem TempItem;
	local int TempCount;

	if (MoveItem != None) {
		for (TempCount = Count; TempCount > 0 && MoveItem.Next != None; TempCount--) {
			TempItem = MoveItem.Next;
			MoveItem.Next = TempItem.Next;
			if (MoveItem.Next != None)
				MoveItem.Next.Prev = MoveItem;
			TempItem.Prev = MoveItem.Prev;
			if (TempItem.Prev != None)
				TempItem.Prev.Next = TempItem;
			MoveItem.Prev = TempItem;
			TempItem.Next = MoveItem;

			if (MoveItem == First)
				First = TempItem;
		}
		Count = Count - TempCount;
	}
}
		
		
function RunTest()
{
	local ListItem Test, TempItem;
	
	Log("Test: Init 'B'");
	Test = new(None) class'ListItem';
	Test.Tag = "B";
	Test.Data = "B";
	Log("  => Test="$Test);
	
	TempItem = new(None) class'ListItem';
	TempItem.Tag = "A";
	TempItem.Data = "A";
	Log("Test: AddSort 'A'");
	Test.AddSortedElement(Test, TempItem);
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);

	TempItem = new(None) class'ListItem';
	TempItem.Tag = "D";
	TempItem.Data = "D";
	Log("Test: AddSort 'D'");
	Test.AddSortedElement(Test, TempItem);
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);

	TempItem = new(None) class'ListItem';
	TempItem.Tag = "C";
	TempItem.Data = "C";
	Log("Test: AddSort 'C'");
	Test.AddSortedElement(Test, TempItem);
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);

	Log("");

	Log("Test: Delete 'C'");
	Test.DeleteElement(Test, "C");
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);
		
	Log("Test: Delete 'D'");
	Test.DeleteElement(Test, "D");
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);
		
	Log("Test: Delete 'A'");
	Test.DeleteElement(Test, "A");
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);

	Log("Test: Delete 'B'");
	Test.DeleteElement(Test, "B");
	Log("  => Test="$Test);
	for (TempItem = Test; TempItem != None; TempItem = TempItem.Next)
		Log("  => Tag="$TempItem.Tag$" Prev="$TempItem.Prev$" Next="$TempItem.Next);
}