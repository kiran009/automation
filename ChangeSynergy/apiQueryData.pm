###########################################################

## apiQueryData Class

###########################################################

package ChangeSynergy::apiQueryData;

#use strict;
use warnings;
use ChangeSynergy::Globals;
use ChangeSynergy::apiObjectVector;

#Takes one parameter, the xmldata passed in as a scalar.
sub new
{
	shift; #take off the apiQueryData which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{objDataSize} = -1;
	$self->{objDataType} = -1;
	$self->{vectorPos}   = undef;
	$self->{objData}	 = [];
	$self->{globals}     = new ChangeSynergy::Globals();
	$self->{offlineDatabases} = [];

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
		die "Invalid XML Data: apiQueryData: " . $self->{xmlData} . $@; 
	}

	return $self;
}

sub getOfflineDatabases()
{
	my $self = shift;
	return @{$self->{offlineDatabases}};
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getVectorPosition()
{
	my $self = shift;
	return $self->{vectorPos};
}

sub getDataSize()
{
	my $self = shift;
	return $self->{objDataSize};
}

sub getDataType()
{
	my $self = shift;
	return $self->{objDataType};
}

#This will return an apiObjectVector
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
#
#			<csapi_cobject_data_value>attribute value</csapi_cobject_data_value>
#			or (if csapi_object_data_value is CCM_E_SIGNATURE)
#			<csapi_cobject_data_value>
#				<e_signatures>
#					<e_signature>
#						<message>
#							<fullname>user's first and last name</fullname>
#							<username>operating system login name</username>
#							<date>the date when a signature was created</date>
#							<purpose>a definable enumerated list</purpose>
#							<comment>optional comment</comment>
#							<attribute>the signature attribute</attribute>
#							<cvid>CR's:cvid is required execpt on submit and copy operations</cvid>
#							<create_time>the time that the CR was created</create_time>
#						</message>
#						<digest>the encoded digital signature</digest>
#						<digest_algorithm>optionally specify the digest algorithm: [MD5|MD2|SHA]</digest_algorithm>
#					</e_signature>
#				<e_signatures>
#			</csapi_cobject_data_value>
#			or (if csapi_cobject_data_type is CCM_SUBSCRIPTION)
#				<csapi_cobject_data_value>
#					<subscription>
# 						<subscriber>
#						<username>a user name for a subscribed user</username>
#						<email>e-mail address of the subscribed user</email>
#						<realname>the real name for a subscribed user</realname>
#						</subscriber>
#					</subscription>
#				<csapi_cobject_data_value>
#
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

sub parseXml
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse query data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse query data, 0 length";
	}

	my $xmlData = $self->{xmlData};

    my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_CQUERY_DATA});
	my $iEnd   = -1;
	my $iTmp   = index($xmlData, $self->{globals}->{END_CSAPI_CQUERY_DATA});

	while ($iTmp >= 0) 
	{
		$iEnd = $iTmp;
		$iTmp = index($xmlData, $self->{globals}->{END_CSAPI_CQUERY_DATA}, $iTmp + 1);
	}

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse query data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_CQUERY_DATA});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse query data.";
	}

	&xmlSetObjectSize($self);
	&xmlSetObjectType($self);
	&xmlSetVectorPosition($self);
	&xmlSetObjectData($self);
	$self->xmlSetOfflineDatabases();
}

sub xmlSetObjectData()
{
	my $self = shift;

	if($self->{objDataSize} < 0)
	{
		return;
	}

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse query data, undef";
	}

	my $xmlData = $self->{xmlData};

	eval
	{
		my @objVectors = [];

		my $BTag = $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR} . $self->{vectorPos} . ">";
		my $ETag = $self->{globals}->{END_CSAPI_COBJECT_VECTOR} . $self->{vectorPos} . ">";

		my $iStart = 0;
		my $iEnd   = 0;
		my $i      = 0;

		for($i = 0; $i < $self->{objDataSize}; $i++)
		{
			$iStart = index($xmlData, $BTag, $iStart);
			$iEnd   = index($xmlData, $ETag, $iStart);

			if(($iStart < 0) || ($iEnd < 0))
			{
				die "Cannot parse object vector data";
			}

			$iEnd += length($ETag);

			if(($iStart == $iEnd) || ($iStart > $iEnd))
			{
				die "Cannot parse object vector data";
			}

			eval
			{
				push @{$self->{objData}}, new ChangeSynergy::apiObjectVector(substr($xmlData, $iStart, $iEnd - $iStart), $self->{vectorPos});
			};

			if($@)
			{
				die $@;
			}

			$iStart = $iEnd;
		}

	};

	if($@)
	{
		die "$@";
	}
}

sub xmlSetOfflineDatabases()
{
	my $self = shift;
	my $xml = $self->{xmlData};
	
	$self->{offlineDatabases} = [];

	while ($self->{xmlData} =~ /<csapi_offline_database>(.*?)<\/csapi_offline_database>/g)
	{
		push @{$self->{offlineDatabases}}, $1;
	}
}

sub xmlSetObjectSize()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse query data, undef";
	}

	my $xmlData = $self->{xmlData};

    my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_SIZE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_SIZE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse query data size";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_SIZE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse query data size";
	}
	
	$self->{objDataSize} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetVectorPosition()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse query data position, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_POSITION});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_POSITION});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse query data position";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_POSITION});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse query data position";
	}

	$self->{vectorPos} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetObjectType()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse query data type, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_TYPE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_VECTOR_TYPE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse query data type";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_VECTOR_TYPE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse query data type";
	}

	$self->{objDataType} = substr($xmlData, $iStart, $iEnd - $iStart);
}

1;

__END__

=head1 Name

ChangeSynergy::apiQueryData

=head1 Description

This is the top level class used in reporting apis. This is also the top 
level class that represents	a sub-report. The "number of objects" value states
how many objects are contained within. The "type of objects" is a integer 
value that specifies the object type. The "relational report level" value 
is used only by the XML	parsing routines. This value should not be altered, or
referenced.

 Object types are:(as defined in Globals.pm)

	PROBLEM_TYPE 17 // This is a Change Request
	TASK_TYPE    18 // This is a Task
	OBJECT_TYPE  19 // This is a Object

 <csapi_cquery_data>
	<csapi_cobject_vector_size>number of objects</csapi_cobject_vector_size>
	<csapi_cobject_vector_type>type of objects</csapi_cobject_vector_type>
	<csapi_cobject_vector_position>relational report level</csapi_cobject_vector_position>

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
	.
	.
	.

 </csapi_cquery_data>

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initializes a newly created ChangeSynergy::apiQueryData class so that it 
represents the xml data passed in.

 my $queryData = new ChangeSynergy::apiQueryData(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getDataObject>

Get one data object based upon a position in the object array.
The return result is an instance of the L<apiObjectVector> class.

my $xmlData = $queryData->getXmlData()

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: apiObjectVector
	one data object based upon a position in the object array.

 Throws:
	die - if the list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getDataSize>

The number of objects contained within this class instance.

my $xmlData = $queryData->getDataSize($iPos)

 Returns: scalar
	the number of objects contained within this class instance.

=cut

##############################################################################

=item B<getDataType>

The data type for this set of objects. Can be 17,18,19, one of the object types.

my $xmlData = $queryData->getDataType()

 Returns: scalar
	the data type for this set of objects.

=cut

##############################################################################

=item B<getXmlData>

Gets the XML data used to constuct this apiQueryData class. 

Note: This is intended for debugging only.

my $xmlData = $queryData->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<getOfflineDatabases>

In central server mode, reports that traverse from CRs to tasks, e.g. 
Data_Report_CR_Task, can return partial task results if any of the development
databases were offline at the time of the report. Overall, the report will
succeed, just with fewer tasks. In that case, a the list of databases
that were offline can be retrieved with this function.

In standalone mode, always returns an empty array.

my @dbs = $queryData->getOfflineDatabases()

 Returns: array
	array of database labels that were offline when the query or report ran.

=cut

##############################################################################