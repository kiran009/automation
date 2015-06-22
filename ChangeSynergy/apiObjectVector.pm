###########################################################
## apiObjectVector Class
###########################################################

package ChangeSynergy::apiObjectVector;

use strict;
use warnings;
use ChangeSynergy::apiQueryData;
use ChangeSynergy::apiObjectData;
use ChangeSynergy::apiTransitions;
use ChangeSynergy::Globals;

#Takes one or two parameters, (xmlData) or (xmlData, parent)
sub new
{
	shift; #take off the apiObjectVector which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{childData}			= undef;
	$self->{objDataSize}		= -1;
	$self->{objData}			= [];
	$self->{mTransitions}		= undef;
	$self->{myTransitions}		= [];
	$self->{TransitionLinkSize} = -1;
	$self->{globals}			= new ChangeSynergy::Globals();

	bless $self;

	if(@_ == 0)
	{
		$self->{xmlData}     = undef;
		$self->{vectorPosition}    = undef;
	}
	elsif(@_ == 1)
	{
		$self->{xmlData}     = shift;
		$self->{vectorPosition}	 = undef;;

		eval
		{
			&parseShowXml($self);
		};

		if($@)
		{
			die "Invalid XML Data: apiObjectVector: " . $self->{xmlData} . $@;
		}
	}
	else	
	{
		$self->{xmlData}        = shift;
		$self->{vectorPosition} = shift;

		eval
		{
			&parseXml($self);
		};

		if($@)
		{
			die "Invalid XML Data: apiObjectVector: " . $self->{xmlData} . $@;
		}
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub toXml()
{
	my $self	= shift;
	my $xmlData = "";
	my $tmp		= undef;

	if(defined($self->{objData}))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR};

		for(my $i = 0; $i < $self->{objDataSize}; $i++)
		{
			if(!defined(&getDataObject($self,$i)))
			{
				die "apiObjectVector::getDataObject(position): Undefined data element.";
			}

			if(&getDataObject($self,$i)->getIsModified())
			{
				$tmp = &getDataObject($self, $i)->toXml();
				$xmlData .= $tmp;
			}
		}

		$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_VECTOR};
	}

	return $xmlData;
}

sub toShowXml()
{
	my $self	= shift;
	my $xmlData = "";
	my $tmp		= undef;

	if(defined($self->{objData}))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_SHOW_COBJECT_VECTOR};

		for(my $i = 0; $i < $self->{objDataSize}; $i++)
		{
			if(!defined(&getDataObject($self,$i)))
			{
				die "apiObjectVector::getDataObject(position): Undefined data element.";
			}

			if(&getDataObject($self,$i)->getIsShowModified())
			{
				$tmp = &getDataObject($self, $i)->toXml();
				$xmlData .= $tmp;
			}
		}

		$xmlData .= $self->{globals}->{END_CSAPI_SHOW_COBJECT_VECTOR};
	}

	return $xmlData;
}

sub toObjectXml()
{
	my $self	= shift;
	my $iType   = shift;
	my $xmlData = "";
	my $tmp		= undef;

	if(defined($self->{objData}))
	{
		for(my $i = 0; $i < $self->{objDataSize}; $i++)
		{
			if(!defined(&getDataObject($self,$i)))
			{
				die "apiObjectVector::getDataObject(position): Undefined data element.";
			}

			$tmp = &getDataObject($self, $i)->toObjectXml($iType);
			$xmlData .= $tmp;
		}
	}

	return $xmlData;
}

sub toAttributeXml()
{
	my $self	= shift;
	my $xmlData = "";
	my $tmp		= undef;

	if(defined($self->{objData}))
	{
		for(my $i = 0; $i < $self->{objDataSize}; $i++)
		{
			if(!defined(&getDataObject($self,$i)))
			{
				die "apiObjectVector::getDataObject(position): Undefined data element.";
			}

			$tmp = &getDataObject($self, $i)->toAttributeXml();
			$xmlData .= $tmp;
		}
	}

	return $xmlData;
}

sub toSubmitXml()
{
	my $self	= shift;
	my $xmlData = "";
	my $tmp		= undef;

	if(defined($self->{objData}))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_SHOW_COBJECT_VECTOR};

		for(my $i = 0; $i < $self->{objDataSize}; $i++)
		{
			if(!defined(&getDataObject($self,$i)))
			{
				die "apiObjectVector::getDataObject(position): Undefined data element.";
			}

			if(&getDataObject($self,$i)->getIsSubmitModified())
			{
				$tmp = &getDataObject($self, $i)->toXml();
				$xmlData .= $tmp;
			}
		}

		$xmlData .= $self->{globals}->{END_CSAPI_SHOW_COBJECT_VECTOR};
	}

	return $xmlData;
}

sub getTransitions()
{
	my $self = shift;
	return $self->{mTransitions};
}

sub setTransitions
{
	my $self = shift;
	my $val  = shift;

	$self->{mTransitions} = $val;
	&xmlSetTransitionLinks($self);
}

#Returns an apiObjectData
sub getDataObject
{
	my $self = shift;

	# Get the passed in parameter
	my $iPos = shift; 

	if($self->{objDataSize} <= 0)
	{
		die "List is empty";
	}

	if(($iPos < 0) || ($iPos >= $self->{objDataSize}))
	{
		die "Invalid index";
	}

	return $self->{objData}[$iPos];
}

sub getTransitionLink
{
	my $self = shift;

	# Get the passed in parameter
	my $iPos = shift;

	if($self->{TransitionLinkSize} <= 0)
	{
		die "List is empty";
	}

	if(($iPos < 0) || ($iPos >= $self->{TransitionLinkSize}))
	{
		die "Invalid index";
	}

	return ($self->{myTransitions}[$iPos]);
}

sub getDataObjectByName
{
	my $self	 = shift;
	my $attrName = shift;
	
	for(my $i = 0; $i < &getDataSize($self); $i++)
	{
		my $value = $self->{objData}[$i]->getName() cmp $attrName;

		if($value == 0)
		{
			return $self->{objData}[$i];
		}
	}

	die "Could not find specified value '" . $attrName ."'";
}

sub getChildData()
{
	my $self	 = shift;
	return $self->{childData};
}

sub getDataSize()
{
	my $self	 = shift;
	return $self->{objDataSize};
}

sub getTransitionLinkSize()
{
	my $self	 = shift;
	return $self->{TransitionLinkSize};
}

sub addDataObject()
{
	my $self        = shift;
	my $objectData  = shift;
	my $objDataSize = &getDataSize($self);

	if($objDataSize == -1)
	{
		$objDataSize = 0;
	}

	$self->{objDataSize} = $objDataSize + 1;
	push @{$self->{objData}}, $objectData;
}

#
#
#<csapi_cquery_data>
#	<csapi_cobject_vector_size>number of objects</csapi_cobject_vector_size>
#	<csapi_cobject_vector_type>type of objects</csapi_cobject_vector_type>
#	<csapi_cobject_vector_position>relational report level</csapi_cobject_vector_position>
#
#	<csapi_cobject_vector>
#		<csapi_cobject_data_size>number of objects</csapi_cobject_data_size>
#		<csapi_cobject_vector_transitions>transition link data</csapi_cobject_vector_transitions>
#
#		<csapi_cobject_vector_assoc>
#			<csapi_cquery_data>
#			.
#			.
#			.
#			</csapi_cquery_data>
#		</csapi_cobject_vector_assoc>
#
#		<csapi_cobject_data>
#			<csapi_cobject_data_name>attribute name</csapi_cobject_data_name>
#			<csapi_cobject_data_value>attribute value</csapi_cobject_data_value>
#			<csapi_cobject_data_type>web type</csapi_cobject_data_type>
#			<csapi_cobject_data_readonly>true|false</csapi_cobject_data_readonly>
#			<csapi_cobject_data_required>true|false</csapi_cobject_data_required>
#			<csapi_cobject_data_inherited>true|false</csapi_cobject_data_inherited>
#			<csapi_cobject_data_default>default value for this attribute</csapi_cobject_data_default>
#			<csapi_cobject_data_date>formatted date</csapi_cobject_data_date>
#		</csapi_cobject_data>
#		.
#		.
#		.
#
#	</csapi_cobject_vector>
#	.
#	.
#	.
#
#</csapi_cquery_data>
#

sub parseXml()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse object vector data, 0 length";
	}

	my $xmlData = $self->{xmlData};

	my $BTag = $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR} . $self->{vectorPosition} . ">";
	my $ETag = $self->{globals}->{END_CSAPI_COBJECT_VECTOR} . $self->{vectorPosition} . ">";

	my $iStart = index($xmlData, $BTag);
	my $iEnd   = rindex($xmlData, $ETag);

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object vector data.";
	}

	$iStart += length($BTag);

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse object vector data.";
	}

	eval
	{
		&xmlSetObjectSize($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetObjectSize() : " . $@;
	}

	eval
	{
		&xmlSetObjectData($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetObjectData() : " . $@;
	}

	eval
	{
		&xmlSetAssocData($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetAssocData() : " . $@;
	}
}

sub parseShowXml()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse object vector data, 0 length";
	}

	my $xmlData = $self->{xmlData};

	my $BTag = $self->{globals}->{BGN_CSAPI_SHOW_COBJECT_VECTOR};
	my $ETag = $self->{globals}->{END_CSAPI_SHOW_COBJECT_VECTOR};

	my $iStart = index($xmlData, $BTag);
	my $iEnd   = -1;
	my $iTmp   = index($xmlData, $ETag);

	while ($iTmp >= 0)
	{
		$iEnd = $iTmp;
		$iTmp = index($xmlData, $iTmp + 1);
	}

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object vector data.";
	}

	$iStart += length($BTag);

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse object vector data.";
	}

	eval
	{
		&xmlSetObjectSize($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetObjectSize(): " . $@
	}

	eval
	{
		&xmlSetTransitions($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetTransitions(): " . $@
	}

	eval
	{
		&xmlSetTransitionLinks($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetTransitionLinks(): " . $@
	}

	eval
	{
		&xmlSetObjectData($self);
	};

	if($@)
	{
		die "Cannot parse data: xmlSetObjectData(): " . $@
	}
}

sub xmlSetTransitions
{
	my $self = shift;	

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_TRANSITIONS});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_TRANSITIONS});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object transitions";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_TRANSITIONS});

	if($iStart > $iEnd)
	{
		die "Cannot parse object transitions";
	}

	$self->{mTransitions} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetTransitionLinks
{
	my $self = shift;
	
	if(!defined($self->{mTransitions}))
	{
		return;
	}

	if(length($self->{mTransitions}) == 0)
	{
		return;
	}

	eval
	{
		my $tmp = $self->{mTransitions};

		my $iCount = 1;
		my $iStart = 0;
		my $iEnd   = index($tmp, '|', $iStart);

		while($iEnd >= 0)
		{
			$iCount++;

			$iStart = $iEnd + 1;
			$iEnd   = index($tmp, '|', $iStart);
		}

		$self->{TransitionLinkSize} = $iCount;
		$iStart						= 0;
		$iEnd						= index($tmp, '|', $iStart);
		$iCount						= 0;

		while ($iEnd >= 0)
		{
			eval
			{
				push @{$self->{myTransitions}}, new ChangeSynergy::apiTransitions(substr($tmp, $iStart, $iEnd-$iStart));
			};

			if($@)
			{
				die $@;
			}

			$iCount++;

			$iStart = $iEnd + 1;
			$iEnd	= index($tmp, '|', $iStart);
		}

		eval
		{
			push @{$self->{myTransitions}}, new ChangeSynergy::apiTransitions(substr($tmp, $iStart));
		};

		if($@)
		{
			die $@;
		}
	};

	if ($@)
	{
		die "Invalid XML Data: apiObjectVector: xmlSetTransitionLinks(): " . $self->{mTransitions} . ":" . $@;
	}
}

sub xmlSetAssocData
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_ASSOC});
	my $iEnd   = -1;
	my $iTmp   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_ASSOC});

	while ($iTmp >=0)
	{
		$iEnd = $iTmp;
		$iTmp = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_ASSOC}, $iTmp + 1);
	}

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object vector associated data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_ASSOC});

	if($iStart == $iEnd)
	{
		return;
	}

	if($iStart > $iEnd)
	{
		die "Cannot parse object vector associated data";
	}

	eval
	{
		$self->{childData} = new ChangeSynergy::apiQueryData(substr($xmlData, $iStart, $iEnd - $iStart));	
	};

	if($@)
	{
		die $@;
	}
}

sub xmlSetObjectData
{
	my $self = shift;

	if($self->{objDataSize} < 0)
	{
		return;
	}

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = 0;
	my $iEnd   = -1;
	my $i;

	for($i = 0; $i < $self->{objDataSize}; $i++)
	{
		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA}, $iStart);
		$iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA}, $iStart);

		if(($iStart < 0) || ($iEnd < 0))
		{
			die "Cannot parse object vector data";
		}

		$iEnd += length($self->{globals}->{END_CSAPI_COBJECT_DATA});

		if(($iStart == $iEnd) || ($iStart > $iEnd))
		{
			die "Cannot parse object vector data";
		}

		eval
		{
			push @{$self->{objData}}, new ChangeSynergy::apiObjectData(substr($xmlData, $iStart, $iEnd - $iStart), $self);
		};

		if($@)
		{
			die $@;
		}

		$iStart = $iEnd;
	}
}

sub xmlSetObjectSize
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object vector size data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_SIZE});
	my $iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_SIZE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object vector size data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_SIZE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse object vector size data";
	}

	$self->{objDataSize} = substr($xmlData, $iStart, $iEnd - $iStart);
}

1;

__END__

=head1 Name

ChangeSynergy::apiObjectVector

=head1 Description

The ChangeSynergy::apiObjectVector holds all of the attributes for a single object.
The class also holds sub-report data, which is a complete apiQueryData
class, this is only true if the class is the result of a reporting api
function call. The "number of objects" is the quantity of attributes
held by this apiObjectVector instance. The "transition link data" can
have a variety of forms, but the data is used to create apiTransitions
class instances.

 <csapi_cobject_vector_position>
 or
 <csapi_cobject_vector>
	<csapi_cobject_data_size>number of objects</csapi_cobject_data_size>
	<csapi_cobject_vector_transitions>transition link data</csapi_cobject_vector_transitions>

	<csapi_cobject_vector_assoc>
		<csapi_cquery_data>
		.
		.
		.
		</csapi_cquery_data>
	</csapi_cobject_vector_assoc>

	<csapi_cobject_data>
		<csapi_cobject_data_name>attribute name</csapi_cobject_data_name>
		<csapi_cobject_data_value>attribute value</csapi_cobject_data_value>
		<csapi_cobject_data_type>web type</csapi_cobject_data_type>
		<csapi_cobject_data_readonly>true|false</csapi_cobject_data_readonly>
		<csapi_cobject_data_required>true|false</csapi_cobject_data_required>
		<csapi_cobject_data_inherited>true|false</csapi_cobject_data_inherited>
		<csapi_cobject_data_default>default value for this attribute</csapi_cobject_data_default>
		<csapi_cobject_data_date>formatted date</csapi_cobject_data_date>
	</csapi_cobject_data>
	.
	.
	.

 </csapi_cobject_vector>
 or
 </csapi_cobject_vector_position>

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)
 sub new(xmlData, parent);

Initializes a newly created ChangeSynergy::apiObjectVector class so that it 
represents the xml data passed in.

 Used for showing object data.
 my $objectVector = new ChangeSynergy::apiObjectVector(xmlData);

 Used only by report apis
 my $objectVector = new ChangeSynergy::apiObjectVector(xmlData, parent);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.
	parent   - the parent to this apiObjectVector

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<addDataObject>

Adds a new L<apiObjectData> class to the current list of data objects held by this
apiObjectVector.  This method is used to add more attributes (apiObjectData) elements
so that they can be used to create a custom submit form.  This custom submit form 
can then be used to import change requests to any state.

$objectVector->addDataObject($objectData)

 Parameters:
	apiObjectData - the new apiObjectData to add to the apiObjectVector's list.

=cut

##############################################################################

=item B<getChildData>

Get the sub-report data.  The return result is an instance of the 
L<apiQueryData> class.

my $childData = $objectVector->getChildData()

 Returns: apiQueryData
	the sub-report data or undef if there is no child data

=cut

##############################################################################

=item B<getDataObject>

Get one attribute data object based upon a position in the object array.
The return result is an instance of the L<apiObjectData> class.

my $dataObject = $objectVector->getDataObject($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: apiObjectData
	one attribute data object based upon a position in the object array.

 Throws:
	die - if the list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getDataObjectByName>

Get one attribute data object based upon a attribute name from the object array. 
The return result is an instance of the L<apiObjectData> class.

my $dataobject = $objectVector->getDataObjectByName($name)

 Parameters:
	name - the attribute name for the dataObject to retrieve.

 Returns: apiObjectData
	one attribute data object based upon a attribute name from the object array. 

 Throws:
	die - If the specified value could not be found.

=cut

##############################################################################

=item B<getDataSize>

Gets the number of attributes held by this class instance.

my $dataSize = $objectVector->getDataSize()

 Returns: scalar
	the number of attributes held by this class instance, (-1) if not set

=cut

##############################################################################

=item B<getTransitions>

Gets the string data used to create the apiTransitions classes.

my $transitions = $objectVector->getTransitions()

 Returns: scalar
	the string data used to create the apiTransitions classes.

=cut

##############################################################################

=item B<getTransitionLink>

Get one transition data object based upon a position in the object array.
The return result is an instance of the L<apiTransitions> class.

my $transLink = $objectVector->getTransitionLink($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: apiTransitions
	one transition data object based upon a position in the object array.

  Throws:
	die - if the list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getTransitionLinkSize>

Get the number of transition links held by this class instance.

my $transitionLinkSize = $objectVector->getTransitionLinkSize()

 Returns: scalar
	the number of transition links held by this class instance, (-1) if not set

=cut

##############################################################################

=item B<getXmlData>

Gets the XML data used to constuct this apiObjectVector class. 

Note: This is intended for debugging only.

my $xmlData = $objectVector->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<setTransitions>

Sets the "transition string data" property for the class instance. It will also 
delete and recreate the apiTransitions based upon the new data. The format of 
the string data should conform to one of the four types stated in the 
L<apiTransitions> class description.

$objectVector->setTransitions($transitions)

 Parameters:
	transitions - the new set of transitions conforming to one of the four types.

=cut

##############################################################################

=item B<toAttributeXml>

Gets XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $objectVector->toAttributeXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################

=item B<toObjectXml>

Gets XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $objectVector->toObjectXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################

=item B<toShowXml>

Gets XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $objectVector->toShowXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################

=item B<toSubmitXml>

Gets XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $objectVector->toSubmitXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################

=item B<toXml>

Gets XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $objectVector->toXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################
