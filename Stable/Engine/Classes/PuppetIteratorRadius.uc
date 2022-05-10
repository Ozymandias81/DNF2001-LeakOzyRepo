//=============================================================================
// PuppetIteratorRadius.
// PuppetIterator which returns true if the actor is within the collision radius
// and collision height range, defining a cylinder of effect.  If either the radius
// or height is zero, that check is ignored.  Note that collision should still
// be disabled against the iterator, even though the collision values are used here.
//=============================================================================
class PuppetIteratorRadius expands PuppetIterator;

defaultproperties
{
}
