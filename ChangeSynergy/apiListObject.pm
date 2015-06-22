###########################################################
## apiListObject Class
###########################################################

package ChangeSynergy::apiListObject;

use strict;
use warnings;
use ChangeSynergy::Globals;

sub new
{
	shift; #take off the apiListObject which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{mDataCount}		= -1;
	$self->{mDataSection}	= -1;
	$self->{mValues}		= [];
	$self->{mLabels}		= [];
	$self->{mName}			= undef;
	$self->{mQueryString}	= undef;
	$self->{mDateLastRun}	= undef;
	$self->{mQueryName}		= undef;
	$self->{mExportForm}	= undef;
	$self->{mSubreports}	= [];
	$self->{globals}		= new ChangeSynergy::Globals();

	# If a parameter was passed in then set it as the xmlData
	if(@_ > 0)
	{
		$self->{xmlData}     = shift;
		$self->{mDataType}	 = shift;
	}
	else
	{
		$self->{xmlData}     = undef;
		$self->{mDataType}	 = undef;
		
		bless $self;

		return $self;
	}

	bless $self;

	eval
	{
		&parseXml($self);
	};

	if($@)
	{
		die "Invalid XML data: apiListObject: \n" .$self->{xmlData} . "\n$@";
	}

	return $self;
}

sub getXmlData
{
	my $self = shift;
	return $self->{xmlData};
}

sub getListSection
{
	my $self = shift;
	return $self->{mDataSection};
}

sub getValueListboxSize
{
	my $self = shift;
	return $self->{mDataCount};
}

sub getSubreportSize
{
	my $self = shift;
	return $self->{mDataCount};
}

sub getListboxSize
{
	my $self = shift;
	return $self->{mDataCount};
}

sub getListSize
{
	my $self = shift;
	return $self->{mDataCount};
}

sub getQueryName
{
	my $self = shift;
	return $self->{mQueryName};
}

sub getExportForm
{
	my $self = shift;
	return $self->{mExportForm};
}

sub getName
{
	my $self = shift;
	return $self->{mName};
}

sub getQueryString
{
	my $self = shift;
	return $self->{mQueryString};
}

sub getDateLastRun
{
	my $self = shift;
	return $self->{mDateLastRun};
}

sub getSubreportName
{
	my $self = shift;
	my $iPos = shift;

	if($self->{mDataCount} <= 0)
	{
		die "Report item is empty"
	}

	if(($iPos <0) || ($iPos >= $self->{mDataCount}))
	{
		die "Invalid index";
	}

	my @subreports = $self->{mSubreports}[$iPos][0];

	return($subreports[0]);
}

sub getSubreportRelation
{
	my $self = shift;
	my $iPos = shift;

	if($self->{mDataCount} <= 0)
	{
		die "Report item is empty"
	}

	if(($iPos <0) || ($iPos >= $self->{mDataCount}))
	{
		die "Invalid index";
	}

	my @subreports = $self->{mSubreports}[$iPos][1];

	return($subreports[0]);
}

sub getSubreportType
{
	my $self = shift;
	my $iPos = shift;

	if($self->{mDataCount} <= 0)
	{
		die "Report item is empty"
	}

	if(($iPos <0) || ($iPos >= $self->{mDataCount}))
	{
		die "Invalid index";
	}

	my @subreports = $self->{mSubreports}[$iPos][2];

	return($subreports[0]);
}

sub getValue
{
	my $self = shift;
	my $iPos = shift;

	if($self->{mDataCount} <= 0)
	{
		die "List is empty";
	}

	if(($iPos <0) || ($iPos >= $self->{mDataCount}))
	{
		die "Invalid index";
	}

	return($self->{mValues}[$iPos]);
}

sub getLabel
{
	my $self = shift;
	my $iPos = shift;

	if($self->{mDataCount} <= 0)
	{
		die "List is empty";
	}

	if(($iPos <0) || ($iPos >= $self->{mDataCount}))
	{
		die "Invalid index";
	}
	
	return($self->{mLabels}[$iPos]);
}

sub parseXml()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse list object data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse list object data, 0 length";
	}
	
	my $xmlData = $self->{xmlData};
	my $foundItem = 0;

	if(($self->{mDataType} eq $self->{globals}->{DATALISTBOX_TYPE}) ||
		($self->{mDataType} eq $self->{globals}->{LIST_TYPE}))
	{
		$foundItem = 1;

		my $iStart = 0;
		my $iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_SECTION});
		
		if($iStart >= 0)
		{
			$iStart += length($self->{globals}->{BGN_CSAPI_SECTION});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_SECTION}, $iStart);

			if($iEnd >=0)
			{
  				my $sec = substr($xmlData, $iStart, $iEnd);

				if ($sec eq "CCM_QUERY")
				{
					$self->{mDataSection} = $self->{globals}->{QUERY_SECTION};
				}
				elsif ($sec eq "CCM_REPORT")
				{
					$self->{mDataSection} = $self->{globals}->{REPORT_SECTION};
				}
				elsif ($sec eq "CCM_LISTBOX")
				{
					$self->{mDataSection} = $self->{globals}->{LISTBOX_SECTION};
				}
				elsif ($sec eq "CCM_LIST")
				{
					$self->{mDataSection} = $self->{globals}->{LIST_SECTION};
				}
				elsif ($sec eq "CCM_VALUELISTBOX")
				{
					$self->{mDataSection} = $self->{globals}->{VALUELISTBOX_SECTION};
				}
				else
				{
					$self->{mDataSection} = -1;
				}
			}
		}
	}
	
	if(($self->{mDataType} eq $self->{globals}->{LISTBOX_TYPE}) ||
		($self->{mDataType} eq $self->{globals}->{VALUELISTBOX_TYPE}) ||
		($self->{mDataType} eq $self->{globals}->{DATALISTBOX_TYPE}) ||
		($self->{mDataType} eq $self->{globals}->{LIST_TYPE}))
	{
		$foundItem = 1;

		my $iStart = 0;
		my $iCount = 0;
		my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_VALUE}, $iStart);

		while($iEnd >= 0)
		{
			$iCount++;
			$iStart = $iEnd + 1;
			$iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_VALUE}, $iStart);
		}

		$self->{mDataCount} = $iCount;

		if($self->{mDataCount} == 0)
		{
			return;
		}

		$iStart  = 0;
		$iStart  = index($xmlData, $self->{globals}->{BGN_CSAPI_LISTBOX_VALUE}, $iStart);
		$iStart += length($self->{globals}->{BGN_CSAPI_LISTBOX_VALUE});
		$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_VALUE}, $iStart);

		while($iStart >= 0)
		{
			push @{$self->{mValues}}, ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));

			$iStart  = index($xmlData, $self->{globals}->{BGN_CSAPI_LISTBOX_VALUE}, $iStart);

			if($iStart < 0)
			{
				last;
			}

			$iStart += length($self->{globals}->{BGN_CSAPI_LISTBOX_VALUE});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_VALUE}, $iStart);
		}

		$iStart  = 0;
		$iStart  = index($xmlData, $self->{globals}->{BGN_CSAPI_LISTBOX_LABEL}, $iStart);
		$iStart += length($self->{globals}->{BGN_CSAPI_LISTBOX_LABEL});
		$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_LABEL}, $iStart);

		while($iStart >= 0)
		{
			push @{$self->{mLabels}}, ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));

			$iStart  = index($xmlData, $self->{globals}->{BGN_CSAPI_LISTBOX_LABEL}, $iStart);

			if($iStart < 0)
			{
				last;
			}

			$iStart += length($self->{globals}->{BGN_CSAPI_LISTBOX_LABEL});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_LISTBOX_LABEL}, $iStart);

		}
	}
	
	if($self->{mDataType} eq $self->{globals}->{REPORT_TYPE})
	{
		$foundItem = 1;

		my $iStart = 0;
		my $iCount = 0;
		my $iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_QRY_NAME}, $iStart);

		if($iStart >= 0)
		{
			$iStart  = $iStart + length($self->{globals}->{BGN_CSAPI_QRY_NAME});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_QRY_NAME}, $iStart);

			if($iEnd >= 0)
			{
				$self->{mQueryName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
			}
		}

		$iStart = 0;		
		$iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_EXPORT_FORM}, $iStart);
		
		if($iStart >= 0)
		{
			$iStart += length($self->{globals}->{BGN_CSAPI_EXPORT_FORM});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_EXPORT_FORM}, $iStart);

			if($iEnd >= 0)
			{
				$self->{mExportForm} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
			}
		}

		$iStart = 0;
		$iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_SUBREPORT}, $iStart);

		while($iEnd >= 0)
		{
			$iCount++;
			$iStart = $iEnd + 1;
			$iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_SUBREPORT}, $iStart);
		}

		$self->{mDataCount} = $iCount;
		
		if($self->{mDataCount} != 0)
		{
			my $iStart2 = 0;
			my $iEnd2   = 0;

			$iStart = 0;

			$iStart  = index($xmlData, $self->{globals}->{BGN_CSAPI_SUBREPORT}, $iStart);
			$iStart += length($self->{globals}->{BGN_CSAPI_SUBREPORT});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_SUBREPORT}, $iStart);

			while($iStart >= 0)
			{
				my @subRecord;

				$iStart2 = $iStart;
				$iEnd2   = 0;

				$iStart2 = index($xmlData, $self->{globals}->{BGN_CSAPI_SUBREPORT_NAME}, $iStart2);

				if($iStart2 >= 0)
				{
					$iStart2 += length($self->{globals}->{BGN_CSAPI_SUBREPORT_NAME});
					$iEnd2    = index($xmlData, $self->{globals}->{END_CSAPI_SUBREPORT_NAME}, $iStart2);

					if($iEnd2 >= 0)
					{
						push @subRecord, ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart2, $iEnd2 - $iStart2));
					}
				}

				$iStart2 = $iStart;
				$iEnd2   = 0;

				$iStart2 = index($xmlData, $self->{globals}->{BGN_CSAPI_RELATION_NAME}, $iStart2);

				if($iStart2 >= 0)
				{
					$iStart2 += length($self->{globals}->{BGN_CSAPI_RELATION_NAME});
					$iEnd2    = index($xmlData, $self->{globals}->{END_CSAPI_RELATION_NAME}, $iStart2);

					if($iEnd2 >= 0)
					{
						push @subRecord, ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart2, $iEnd2 - $iStart2));
					}
				}

				$iStart2 = $iStart;
				$iEnd2   = 0;

				$iStart2 = index($xmlData, $self->{globals}->{BGN_CSAPI_RELATION_TYPE}, $iStart2);

				if($iStart2 >= 0)
				{
					$iStart2 += length($self->{globals}->{BGN_CSAPI_RELATION_TYPE});
					$iEnd2    = index($xmlData, $self->{globals}->{END_CSAPI_RELATION_TYPE}, $iStart2);

					if($iEnd2 >= 0)
					{
						push @subRecord, substr($xmlData, $iStart2, $iEnd2 - $iStart2);
					}
				}

				push @{$self->{mSubreports}}, \@subRecord;

				$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_SUBREPORT}, $iStart);

				if($iStart < 0)
				{
					last;
				}

				$iStart  += length($self->{globals}->{BGN_CSAPI_SUBREPORT});
				$iEnd     = index($xmlData, $self->{globals}->{END_CSAPI_SUBREPORT}, $iStart);
			}
		}
	}

	if(($self->{mDataType} eq $self->{globals}->{QUERY_TYPE}) ||
	   ($self->{mDataType} eq $self->{globals}->{REPORT_TYPE}))
	{
		$foundItem = 1;

		my $iStart = 0;
		my $iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_NAME}, $iStart);

		if($iStart >= 0)
		{
			$iStart += length($self->{globals}->{BGN_CSAPI_NAME});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_NAME}, $iStart);

			if($iEnd >= 0)
			{
				$self->{mName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
			}
		}

		$iStart = 0;
		$iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_QRY_STRING}, $iStart);

		if($iStart >= 0)
		{
			$iStart += length($self->{globals}->{BGN_CSAPI_QRY_STRING});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_QRY_STRING}, $iStart);

			if($iEnd >= 0)
			{
				$self->{mQueryString} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
			}
		}

		$iStart = 0;
		$iEnd   = 0;

		$iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_DATE_LAST_RUN}, $iStart);

		if($iStart >= 0)
		{
			$iStart += length($self->{globals}->{BGN_CSAPI_DATE_LAST_RUN});
			$iEnd    = index($xmlData, $self->{globals}->{END_CSAPI_DATE_LAST_RUN}, $iStart);

			if($iEnd >= 0)
			{
				$self->{mDateLastRun} = substr($xmlData, $iStart, $iEnd - $iStart);
			}
		}
	}

	if($foundItem == 0)
	{
		die "Invalid Response Data";
	}
}

1;

__END__

=head1 Name

ChangeSynergy::apiListObject

=head1 Description

ChangeSynergy::apiListObject and its associated api calls are used to obtain list 
type data from IBM Rational Change configuration data. The data that can be obtained
are: Valuelistboxes, Listboxes, Lists, Datalistboxes, Reports, and Queries.

 *************************************
 *  XML Format for the Data Types    *
 *************************************

 GetDatabases api call:

	<csapi_listbox_value>
		Database name.
	</csapi_listbox_value>
	<csapi_listbox_label>
		Database alias.
	</csapi_listbox_label>
	.
	.
	.

 GetHosts api call:

	<csapi_listbox_value>
		Host name.
	</csapi_listbox_value>
	<csapi_listbox_label>
		Host type. [UNIX|NT]
	</csapi_listbox_label>
	.
	.
	.

 Valuelistbox:

	<csapi_listbox_value>
		Valuelistbox value.
	</csapi_listbox_value>
	<csapi_listbox_label>
		Valuelistbox label.
	</csapi_listbox_label>
	.
	.
	.

 Listbox:

	<csapi_listbox_value>
		Listbox position.
	</csapi_listbox_value>
	<csapi_listbox_label>
		Listbox value.
	</csapi_listbox_label>
	.
	.
	.

 List:

	<csapi_section>
		List item type.
		[CCM_QUERY|CCM_REPORT|CCM_LISTBOX|CCM_LIST|CCM_VALUELISTBOX]
	</csapi_section>
	<csapi_listbox_value>
		List item position.
	</csapi_listbox_value>
	<csapi_listbox_label>
		List item name.
	</csapi_listbox_label>
	.
	.
	.

 Datalistbox:

	Returns a role based List reference, or the default List
	if a role list is not specified.

	<csapi_section>
		List item type.
		[CCM_QUERY|CCM_REPORT|CCM_LISTBOX|CCM_LIST|CCM_VALUELISTBOX]
	</csapi_section>
	<csapi_listbox_value>
		List item position.
	</csapi_listbox_value>
	<csapi_listbox_label>
		List item name.
	</csapi_listbox_label>
	.
	.
	.

 Report:

	<csapi_name>
		Report name.
	</csapi_name>
	<csapi_export_form>
		Report export format.
	</csapi_export_form>
	<csapi_qry_name>
		Report query name.
	</csapi_qry_name>
	<csapi_qry_string>
		Report query string.
	</csapi_qry_string>
	<csapi_date_last_run>
		Report date query was last run.
	</csapi_date_last_run>
	<csapi_subreports>
		<csapi_subreport>
			<csapi_subreport_name>
				Subreport name or top report
				name, if it is the top report.
			</csapi_subreport_name>
			<csapi_relation_name>
				Report Relation name, or
				blank if it is the top report.
			</csapi_relation_name>
			<csapi_relation_type>
				Report type.
				[PROBLEM_TYPE|TASK_TYPE|OBJECT_TYPE]
			</csapi_relation_type>
		</csapi_subreport>
		.
		.
		.
	</csapi_subreports>

 Query:

	<csapi_name>
		Query name.
	</csapi_name>
	<csapi_qry_string>
		Query string.
	</csapi_qry_string>
	<csapi_date_last_run>
		Date query was last run.
	</csapi_date_last_run>

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData, dataType)

Initializes a newly created ChangeSynergy::apiListObject class so that it 
represents the xml data passed in.

 my $listobject = new ChangeSynergy::apiListObject(xmlData, dataType);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.
	dataType - the type of XML data that is going to be parsed

	Available dataTypes are defined in the globals.pm file and are:
	  VALUELISTBOX_TYPE
	  LISTBOX_TYPE
	  LIST_TYPE
	  DATALISTBOX_TYPE
	  REPORT_TYPE
	  QUERY_TYPE

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getDateLastRun>

Get date of the last time the Report or Query was last run.

my $dateLastRun = $listobject->getDateLastRun()

 Returns: scalar
	the Report/Query date last run for the report in this list.

=cut

##############################################################################

=item B<getExportForm>

Get the reports export format.

my $exportForm = $listobject->getExportForm()

 Returns: scalar
	the report export format for the report in this list.

=cut

##############################################################################

=item B<getLabel>

Gets the list Label at specified position.

my $label = $listobject->getLabel($iPos)

 Parameters: 
	iPos - the index position to retrieve the data.

 Returns: scalar
	the list Label at specified position

 Throws:
	die - if the list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getListboxSize>

Gets the size of the Listbox.

my $listboxSize = $listobject->getListboxSize()

 Returns: scalar
	the size of the listbox that was requested

=cut

##############################################################################

=item B<getListSection>

Gets the section id for the List.

my $listSelection = $listobject->getListSection()

 Returns: scalar
	the section id for the List, possible values are defined in the globals.pm file:

	QUERY_SECTION
	REPORT_SECTION
	LISTBOX_SECTION
	LIST_SECTION
	VALUELISTBOX_SECTION

=cut

##############################################################################

=item B<getListSize>

Gets the size of the List.

my $listSize = $listobject->getListSize()

 Returns: scalar
	the size of the List that was requested

=cut

##############################################################################

=item B<getName>

Gets the name of the Report or Query.

my $name = $listobject->getName()

 Returns: scalar
	the Report/Query name for the report in this list.

=cut

##############################################################################

=item B<getQueryName>

Gets the query name of the Report or Query.

my $queryName = $listobject->getQueryName()

 Returns: scalar
	the Report/Query query name for the report in this list.

=cut

##############################################################################

=item B<getQueryString>

Gets the query string used by the Report or Query.

my $queryString = $listobject->getQueryString()

 Returns: scalar
	the Report/Query query string for the report in this list.

=cut

##############################################################################

=item B<getSubreportName>

Gets the list Subreport Name at specified position.

my $subreportName = $listobject->getSubreportName($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: scalar
	the list Subreport Name at specified position.

 Throws:
	die - if the report item list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getSubreportRelation>

Gets the list Subreport Relation at specified position.

my $subreportRelation = $listobject->getSubreportRelation($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: scalar
	the list Subreport Relation at specified position.

 Throws:
	die - if the report item list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getSubreportSize>

Gets the size of the Report structure.

my $subReportSize = $listobject->getSubreportSize()

 Returns: scalar
	the size of the Report structure

=cut

##############################################################################

=item B<getSubreportType>

Gets the list Subreport Type at specified position.

my $subreportType = $listobject->getSubreportType($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: scalar
	the list Subreport Type at specified position, possible values are 
	defined in the globals.pm file:

	PROBLEM_REPORT
	TASK_REPORT
	OBJECT_REPORT

=cut

##############################################################################

=item B<getValue>

Gets the list Value at specified position.

my $value = $listobject->getValue($iPos)

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: scalar
	the list Value at specified position

 Throws:
	die - if the list is empty
	die - if the index position specified is invalid.

=cut

##############################################################################

=item B<getValueListboxSize>

Gets the size of the Valuelistbox.

my $valueListSize = $listobject->getValueListboxSize()

 Returns: scalar
	the size of the Valuelistbox that was requested

=cut

##############################################################################

=item B<getXmlData>

Returns the XML data used to constuct this object. 

Note: This is intended for debugging only.

my $xmlData = $listobject->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

