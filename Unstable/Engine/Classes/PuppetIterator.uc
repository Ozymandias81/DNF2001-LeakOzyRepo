//=============================================================================
// PuppetIterator.
// Base of puppets which serve multiple actors at a time, iterating based on
// a condition determined by the subclass.  Uses a proxy puppet property which
// does the actual work on an actor by actor basis.
//=============================================================================
class PuppetIterator expands Puppet
	abstract;

var transient puppet ProxyPuppet;
var(Puppet) name ProxyPuppetTag; // Tag used to initialize ProxyPuppet

defaultproperties
{
}
