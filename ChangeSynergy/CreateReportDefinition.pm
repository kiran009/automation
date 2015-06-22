###########################################################
## CreateReportDefinition Class
###########################################################

package ChangeSynergy::CreateReportDefinition;

use strict;
use warnings;
use ChangeSynergy::util;

sub new
{
	shift; #take off the CreateReportDefinition which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};
	
	$self->{name} = undef;
	$self->{baseReport} = undef;
	$self->{description} = undef;
	$self->{queryString} = undef;
	$self->{attributesArray} = ();
	$self->{sortOrderArray} = ();
	$self->{incrementSize} = -1;
	$self->{folderName} = undef;
	$self->{promptingQueryXml} = undef;
	
	bless $self;

	return $self;
}

sub getName
{
	my $self = shift;
	return $self->{name};
}

sub setName
{
	my $self = shift;
	my $value = shift;
	$self->{name} = $value;
}

sub getBaseReport
{
	my $self = shift;
	return $self->{baseReport};
}

sub setBaseReport
{
	my $self = shift;
	my $value = shift;
	$self->{baseReport} = $value;
}

sub getDescription
{
	my $self = shift;
	return $self->{description};
}

sub setDescription
{
	my $self = shift;
	my $value = shift;
	$self->{description} = $value;
}

sub getQueryString
{
	my $self = shift;
	return $self->{queryString};
}

sub setQueryString
{
	my $self = shift;
	my $value = shift;
	$self->{queryString} = $value;
}

sub getAttributes
{
	my $self = shift;
	my @attributes = @{$self->{attributesArray}};
	return @attributes;
}

sub setAttributes
{
	my ($self, $refValue) = @_;
	#get the real array back from the reference.
	
	my @value = @$refValue;
	@{$self->{attributesArray}} = @value;
}

sub getSortOrder
{
	my $self = shift;
	my @sortOrder = @{$self->{sortOrderArray}};
	return @sortOrder;
}

sub setSortOrder
{
	my ($self, $refValue) = @_;
	#get the real array back from the reference.
	
	my @value = @$refValue;
	@{$self->{sortOrderArray}} = @value;
}

sub getIncrementSize
{
	my $self = shift;
	return $self->{incrementSize};
}

sub setIncrementSize
{
	my $self = shift;
	my $value = shift;
	$self->{incrementSize} = $value;
}

sub getFolderName
{
	my $self = shift;
	return $self->{folderName};
}

sub setFolderName
{
	my $self = shift;
	my $value = shift;
	$self->{folderName} = $value;
}

sub getPromptingQueryXml
{
	my $self = shift;
	return $self->{promptingQueryXml};
}

sub setPromptingQueryXml
{
	my $self = shift;
	my $value = shift;
	$self->{promptingQueryXml} = $value;
}

sub toXml
{
	my $self = shift;
	
	my $globals = new ChangeSynergy::Globals();
	my $xmlData = "";
	 
	$xmlData .= "<csapi_name>" . ChangeSynergy::util::xmlEncode($self->{name}) . "</csapi_name>";
	$xmlData .= "<csapi_description>" . ChangeSynergy::util::xmlEncode($self->{description}) . "</csapi_description>";
	$xmlData .= "<csapi_chosen_report>" . ChangeSynergy::util::xmlEncode($self->{baseReport}) . "</csapi_chosen_report>";
	$xmlData .= "<csapi_qry_string>" . ChangeSynergy::util::xmlEncode($self->{queryString}) . "</csapi_qry_string>";
	$xmlData .= "<csapi_prmt_qry_string>" . ChangeSynergy::util::xmlEncode($self->{promptingQueryXml}) . "</csapi_prmt_qry_string>";
	$xmlData .= "<csapi_increment_size>" . ChangeSynergy::util::xmlEncode($self->{incrementSize}) . "</csapi_increment_size>";
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($self->{folderName}) . "</csapi_folder_name>";
	
	if (defined($self->{attributesArray}))
	{
		my @attributes = @{$self->{attributesArray}};
		my $i = 0;
		
		foreach my $attributeList (@attributes)
		{
			$xmlData .= "<csapi_attributes$i>" . ChangeSynergy::util::xmlEncode($attributeList) .  "</csapi_attributes$i>";
			$i++;	
		}
	}
	
	if (defined($self->{sortOrderArray}))
	{
		my @sortOrderList = @{$self->{sortOrderArray}};
		my $i = 0;
		
		foreach my $sortOrder (@sortOrderList)
		{
			$xmlData .= "<csapi_sort_order$i>" . ChangeSynergy::util::xmlEncode($sortOrder).  "</csapi_sort_order$i>";
			$i++;	
		}
	}
	
	return $xmlData;
}

1;

__END__

=head1 Name

ChangeSynergy::CreateReportDefinition

=head1 Description

The ChangeSynergy::CreateReportDefinition class is used with the L<csapi> createReport API to create
new Change reports based off of an already existing report.

An example of using this API:

my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http", "machine", 8600);

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");
		
		#Create an instance of the CreateReportDefinition class.
		my $reportDef = new ChangeSynergy::CreateReportDefinition();
	
		#Set the required attributes.
		$reportDef->setName("API Created Report");
		$reportDef->setBaseReport("Column");
		$reportDef->setQueryString("(cvtype='problem') and (crstatus='entered')");
		
		#Set optional attributes
		$reportDef->setDescription("This report was created via the Perl API");
		$reportDef->setIncrementSize(7); #Only see 7 items per page.
		$reportDef->setFolderName("API Folder"); #Place the report into a folder named 'API Folder'
		
		#Change the list of attributes from a column report. Initial attributes are problem_number, crstatus and problem_synopsis.
		#Changing to just be problem_number and enterer.
		my @attributeLists = ();
		push @attributeLists, "problem_number:0:false|enterer:1:false";
		$reportDef->setAttributes(\@attributeLists);
		
		#Sort first by enterer as a string and secondarily sort the problem number.
		my @sortOrderList = ();
		push @sortOrderList, "enterer:string:A|problem_number:intb:A";
		$reportDef->setSortOrder(\@sortOrderList);
		
		#Create an instance of the Globals calls.
		my $globals = new ChangeSynergy::Globals();
		
		#Call the 'createReport' API and add the new report to the Shared CR queries.
		$csapi->createReport($aUser, $reportDef, $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	};
	
	if ($@)
	{
		print $@;
	}

=head1 Method Summary

=begin html

<table border="1" cellpadding="2" cellspacing="0" width="100%">
	
	<!-- Getters -->
	<tr>
		<td width="10%">
			array
		</td>
		<td>
			<code><a href="#getAttributes">getAttributes</a>()</code><br />
			Gets an array of attribute configuration strings, each index into the array is for a subreport. Example string
			"problem_number:0:false|enterer:1:false".
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getBaseRepor)">getBaseReport</a>()</code><br />
			Gets the name of the base report, the report that the newly created report will be based on.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getDescription">getDescription</a>()</code><br />
			Gets the description for the report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getFolderName">getFolderName</a>()</code><br />
			Gets the name of the folder that the report will be created in.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getIncrementSize">getIncrementSize</a>()</code><br />
			Gets the number of items that will be displayed on a paged report, or -1 if the report is not paged.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getName">getName</a>()></code><br />
			Gets the name of the report to create.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getPromptingQueryXml">getPromptingQueryXml</a>()></code><br />
			Gets the XML data that defines how a prompting query should function.
		</td>
	</tr>
	<tr>
		<td width="10%">
			array
		</td>
		<td>
			<code><a href="#getSortOrder">getSortOrder</a>()</code><br />
			Gets an array of sort order configuration strings, each index into the array is for a subreport. Example string
			"problem_number:intb:A".
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getQueryString">getQueryString</a>()</code><br />
			Gets the query string for the report.
		</td>
	</tr>
	
	<!-- Setters -->
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setAttributes">setAttributes</a>(array @attributes)</code><br />
			Sets the list of attributes that will be retrieved when the report is run. Each index into the array
			is an attribute configuration string, "problem_number:0:false|crstatus:1:false|problem_synopsis:2:false".
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setBaseReport">setBaseReport</a>(scalar baseReportName)</code><br />
			Sets the name of the base report, the report that the newly created report will be based on, 
			for example "Column" or "Block". A base report name is required when creating a new report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setDescription">setDescription</a>(scalar description)</code><br />
			Sets the description for this report, this is the text end users shall see in the reporting 
			interface when they select the report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setFolderName">setFolderName</a>(scalar folderName)</code><br />
			Sets the name of the folder that the report will be created in. If a folder name is not supplied
			the report will be created at the root level.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setIncrementSize">setIncrementSize</a>(scalar incrementSize)</code><br />
			Sets the number of items per page that should be displayed on the report. Use -1 if the report
			should not be a paged report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setName">setName</a>(scalar reportName)</code><br />
			Sets the name of the report that will be created on the Change server. This is the name that
			will appear in the reporting interface. A name is required when creating a new report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setPromptingQueryXml">setPromptingQueryXml</a>(scalar reportName)</code><br />
			Sets the prompting query XML for the report. This defines how a prompting query should function.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setSortOrder">setSortOrder</a>(array @sortOrder)</code><br />
			Sets the list of sorting attributes that will be used when the report is run. Each index into the array
			is a sort order configuration string, "problem_number:intb:A".
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setQueryString">setQueryString</a>(scalar queryString)</code><br />
			Sets the query string that will be used when the report is run. For example, (cvtype='problem') and
			(crstatus='assigned'). A query string is required when creating a new report.
		</td>
	</tr>
</table>

=end html

=head1 Methods

=over 4

=cut

##############################################################################

=item B<new>

Initializes a newly created ChangeSynergy::CreateReportDefinition class that
can be used to create a new report.

 my $reportDef = new ChangeSynergy::CreateReportDefinition();

=cut

##############################################################################

=begin html

	<hr>
	<a href="getAttributes"></a>

=end html

=item B<getAttributes>

Gets an array of attribute configuration strings. Each index into the array represents a sub report. An example of an attribute
configuration string is "problem_number:0:false|crstatus:1:false|problem_synopsis:2:false", this is the same kind of string as
you would see in a standard configuration entry for a CCM_PROBLEM, CCM_TASK or CCM_OBJECT definition.

 Returns: array of scalars
	An array of attribute configuration strings.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getBaseReport"></a>

=end html

=item B<getBaseReport>

Gets the name of the base report. A base report is the report that this report shall be based off, for example "Column" or "Block".

 Returns: scalar
	The name of the base report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getDescription"></a>

=end html

=item B<getDescription>

Gets the description for the report. The description is visible in the Change reporting interface when the user clicks on the
report.

 Returns: scalar
	The description of the report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getFolderName"></a>

=end html

=item B<getFolderName>

Gets the name of the folder where the new report should be placed. If empty then it will not be placed into a folder.

 Returns: scalar
	The name of folder where the report will be created.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getIncrementSize"></a>

=end html

=item B<getIncrementSize>

Gets the number of items that will be displayed on a paged report. If the return value is -1 that means the report is not a paged report.

 Returns: scalar
	The number of results to show on a page or -1 if not a paged report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getName"></a>

=end html

=item B<getName>

Gets the name of the report, this is the name that users shall see in the Change reporting interface.

 Returns: scalar
	The name the report will have on the change server.

=cut

##############################################################################

=begin html

	<hr >
	<a href="getPromptingQueryXml"></a>

=end html

=item B<getPromptingQueryXml>

Gets the prompting query XML data.

 Returns: scalar
	The prompting query data in XML format.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getSortOrder"></a>

=end html

=item B<getSortOrder>

Gets an array of sort order configuration strings. Each index into the array represents a sub report. An example of a sort order
configuration string is "problem_number:intb:A", this is the same kind of string as
you would see in a standard configuration entry for a CCM_PROBLEM, CCM_TASK or CCM_OBJECT definition.

 Returns: array of scalars
	An array of sort order configuration strings.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getQueryString"></a>

=end html

=item B<getQueryString>

Gets the query string for the report.

 Returns: scalar
	A query string.

=cut

##############################################################################

=begin html

	<hr>
	<a href="setAttributes"></a>

=end html

=item B<setAttributes>

Sets the list of attributes for each subreport that will be retrived when the report is run. Each index into the array
represents an attribute configuration string for each subreport. The string that must be set is attribute name:order:span.
For example, "problem_number:0:false|crstatus:1:false|problem_synopsis:2:false".

The passed in parameter must be an array reference, \@array.

This setting should only be used for ad hoc report types and not system or report builder reports as their format is 
hard coded and cannot change dynamically.

 Parameters:
	array reference attributes: A reference to an array of attribute configuration strings.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	
	my @attributeLists = ();
	push @attributeLists, "problem_number:0:false|enterer:1:false";
	$reportDef->setAttributes(\@attributeLists);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setBaseReport"></a>

=end html

=item B<setBaseReport>

Sets the name of the base report, the report that this newly created report shall be based on. The base report
must already exist on the Change server. Examples of possible base reports are "Column" and "Block".

This parameter must be set in order for the csapi->createReport function to work.

 Parameters:
	scalar: The name of the base report.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setBaseReport("Column");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setDescription"></a>

=end html

=item B<setDescription>

Sets the description for the report, the text end users will see in the Change reporting interface.

 Parameters:
	scalar: The description for the report.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setDescription("All entered CRs");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setFolderName"></a>

=end html

=item B<setFolderName>

Sets the name of the folder the report will be created in. If the folder does not exist
an attempt will be made to create the folder. If no folder name is specified the report
will be created in the root folder.

 Parameters:
	scalar: The name of the folder to place the report in or empty for no folder.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setFolderName("API Folder");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setIncrementSize"></a>

=end html

=item B<setIncrementSize>

Sets the number of items per page that should be displayed in the report results. Specify -1 to indicate that this report will not use paging.

 Parameters:
	scalar: The number of items to see per page or -1 for no paging.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setIncrementSize(20);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setName"></a>

=end html

=item B<setName>

Sets the name of the report, this is the name end users shall see and interact with in the Change reporting interface. If the report name
already exists the name shall become "report name (x)" where x is the first free number. This is the same naming scheme that is used
in the web interface.

This parameter must be set in order for the csapi->createReport function to work.

 Parameters:
	scalar: The name this report shall have upon creation.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setName("API report");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setPromptingQueryXml"></a>

=end html

=item B<setPromptingQueryXml>

Sets the prompting query XML data for the report. It is best to create prompting reports via the interface or by exporting and 
importing an existing report. Only set this setting if you know the XML format.

 Parameters:
	scalar: The XML data that defines a promting query.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setPromptingQueryXml(XML DATA);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setSortOrder"></a>

=end html

=item B<setSortOrder>

Sets the list of sorting attributes for each subreport that will be used to sort the report when it is run. Each index into the array
represents a sort order configuration string for each subreport. The string that must be set is attribute name:sort type:A or D. Where 
A or D stands for ascending or descending. An example string is "problem_number:intb:A".

The passed in parameter must be an array reference, \@array.

 Parameters:
	array reference attributes: A reference to an array of sorder order configuration strings.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	
	my @sortOrderList = ();
	push @sortOrderList, "enterer:string:A|problem_number:intb:A";
	$reportDef->setSortOrder(\@sortOrderList);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setQueryString"></a>

=end html

=item B<setQueryString>

Sets the query string that will be used when the report is run.

This parameter must be set in order for the csapi->createReport function to work.

 Parameters:
	scalar: The query string.

 Example:
	
	my $reportDef = new ChangeSynergy::CreateReportDefinition();
	$reportDef->setQueryString("(cvtype='problem') and (crstatus='entered')");

=cut