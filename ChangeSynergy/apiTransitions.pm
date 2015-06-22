###########################################################
## apiTransitions Class
###########################################################

package ChangeSynergy::apiTransitions;

use strict;
use warnings;
use ChangeSynergy::Globals;

sub new
{
	shift; #take off the apiTransitions which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{mName}			= undef;
	$self->{mToState}		= undef;
	$self->{mFromState}		= undef;
	$self->{mTransition}	= undef;
	$self->{mRelation}		= undef;
	$self->{globals}		= new ChangeSynergy::Globals();

	# If a parameter was passed in then set it as the xmlData
	if(@_ > 0)
	{
		$self->{xmlData}     = shift;
	}
	else
	{
		$self->{xmlData}     = undef;

		bless $self;
		return $self;
	}

	bless $self;

	eval
	{
		&parseXml($self);
	};

	if ($@)
	{
		die "Invalid XML Data: apiTransitions: " . $self->{xmlData} . $@; 
	}

	return $self;
}

sub getXmlData
{
	my $self = shift;
	return $self->{xmlData};
}

sub getFromState
{
	my $self = shift;
	return $self->{mFromState};
}

sub getToState
{
	my $self = shift;
	return $self->{mToState};
}

sub getName
{
	my $self = shift;
	return $self->{mName};
}

sub getTransition
{
	my $self = shift;
	return $self->{mTransition};
}

sub getRelation
{
	my $self = shift;
	return $self->{mRelation};
}

sub setFromState
{
	my $self = shift;
	my $val  = shift;

	$self->{mFromState} = $val;
}

sub setToState
{
	my $self = shift;
	my $val  = shift;

	$self->{mToState} = $val;
}

sub setName
{
	my $self = shift;
	my $val  = shift;

	$self->{mName} = $val;
}

sub setTransition
{
	my $self = shift;
	my $val  = shift;

	$self->{mTransition} = $val;
}

sub setRelation
{
	my $self = shift;
	my $val  = shift;

	$self->{mRelation} = $val;
}

#Show:
#from_state2to_state:label|from_state2to_state:label|from_state2to_state:label|ADMIN_ROLE
#
#Transition:
#from_state2to_state:label
#
#Submit:
#START_HEREto_state:label
#
#Copy:
#COPY_relation_name2to_state:label
#

sub parseXml
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse transition data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse transition data, 0 length";
	}

	my $xmlData = $self->{xmlData};
	my $compare = $self->{xmlData} cmp "ADMIN_ROLE";

	if($compare == 0)
	{
		$self->{mName}			= $xmlData;
		$self->{mToState}		= "";
		$self->{mFromState}		= "";
		$self->{mTransition}	= "";
		$self->{mRelation}		= "";

		return;
	}

	my $iDel  = index($xmlData, ":");
	my $iDel2 = index($xmlData, "2");

	$self->{mFromState}		= ChangeSynergy::util::xmlDecode(substr($xmlData, 0, $iDel2));
	$self->{mTransition}	= ChangeSynergy::util::xmlDecode(substr($xmlData, 0, $iDel));
	$self->{mToState}		= ChangeSynergy::util::xmlDecode(substr($xmlData, $iDel2+1, ($iDel - ($iDel2+1))));
	$self->{mName}			= ChangeSynergy::util::xmlDecode(substr($xmlData, $iDel+1));
	
	my $tmp  = $self->{mFromState};
	my $iPos = index($tmp, "COPY_");

	if($iPos >= 0)
	{
		$self->{mRelation}	= ChangeSynergy::util::xmlDecode(substr($tmp, $iPos+5));
	}
}

1;

__END__

=head1 Name

ChangeSynergy::apiTransitions

=head1 Description

The apiTransitions class will contain transition information for the current user.

The available transitions will be obtained when using the following api functions:

 AttributeModifyCRData()
 ModifyCRData()
 GetCRData().

 Show data format:
  from_state2to_state:label|from_state2to_state:label|ADMIN_ROLE...

 Transition data format:
  from_state2to_state:label

 The submit form data, i.e. " Submit to state," is available when
  using the following api functions: SubmitCRData().

 Submit data format:
  START_HERE2to_state:label

 The copy form data, i.e. " Submit to state" and " Submit relation name," 
 is available when using the following api functions: CopyCRData().
 
  Copy data format:
  COPY_relation_name2to_state:label

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initializes a newly created ChangeSynergy::apiTransitions class so that it 
represents the xml data passed in.

 my $transitions = new ChangeSynergy::apiTransitions(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getFromState>

Gets the "from state" for this transition. Use this value to see the 
current "crstatus" attribute value.

my $fromState = $transitions->getFromState()

 Returns: scalar
	the current "crstatus" attribute value

=cut

##############################################################################

=item B<getName>

Gets the "descriptive label" for this transition.

my $name = $transitions->getName()

 Returns: scalar
	the name for this transition.

=cut

##############################################################################

=item B<getRelation>

Gets the "copy relation name" to be used for copy operations.

my $transition = $transitions->getTransition()

 Returns: scalar
	the copy relation name.

=cut

##############################################################################

=item B<getToState>

Gets the "to state" for this transition. Use this value to set the 
"crstatus" attribute before calling the TransitionCR() function.

my $toState = $transitions->getToState()

 Returns: scalar
	the to state for this transition

=cut

##############################################################################

=item B<getTransition>

Gets the "transition template name" for this transition.

my $transition = $transitions->getTransition()

 Returns: scalar
	the transition template name.

=cut

##############################################################################

=item B<getXmlData>

Gets the XML data used to constuct this apiQueryData class. 

Note: This is intended for debugging only.

my $xmlData = $transitions->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<setFromState>

Sets the "from state" property for the class instance.

$transitions->setFromState($value)

 Parameters:
	value - the new value for the from state property

=cut

##############################################################################

=item B<setName>

Sets the "name" property for the class instance.

$transitions->setName($value)

 Parameters:
	value - the new value for the name property

=cut

##############################################################################

=item B<setRelation>

Sets the "copy relation name" property for the class instance.

$transitions->setRelation($value)

 Parameters:
	value - the new value for the transition copy relation name

=cut

##############################################################################

=item B<setToState>

Sets the "from state" property for the class instance.

$transitions->setToState($value)

 Parameters:
	value - the new value for the to state property

=cut

##############################################################################

=item B<setTransition>

Sets the "template name" property for the class instance.

$transitions->setTransition($value)

 Parameters:
	value - the new value for the transition template name

=cut

##############################################################################
