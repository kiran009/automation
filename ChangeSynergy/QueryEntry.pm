###########################################################
## QueryEntry Class
###########################################################

package ChangeSynergy::QueryEntry;

use strict;
use warnings;
use ChangeSynergy::util;

sub new
{
	shift; #take off the apiListObject which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};
	
	# Initialize data for this object
	$self->{name} = undef;
	$self->{queryString} = undef;
	$self->{promptingQueryXml} = undef;
	$self->{template} = undef;
	$self->{description} = undef;
	
	#Config entry tags
	$self->{CCM_QUERY} = "CCM_QUERY";
	$self->{NAME} = "NAME";
	$self->{QRY_STRING} = "QRY_STRING";
	$self->{PROMPTING_QUERY_XML} = "PROMPTING_QUERY_XML";
	$self->{QRY_TEMPLATE} = "QRY_TEMPLATE";
	$self->{DESCRIPTION} = "DESCRIPTION";
	
	# If a parameter was passed in then set it as the configData
	if(@_ > 0)
	{
		$self->{configData} = shift;
	}
	else
	{
		$self->{configData} = undef;
		
		bless $self;

		return $self;
	}
	
	bless $self;
	
	eval
	{
		&parseConfigEntry($self);
	};

	if($@)
	{
		die "Invalid configuration data: QueryEntry: \n" .$self->{configData} . "\n$@";
	}

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
	my $name = shift;
	$self->{name} = $name;
}

sub getQueryString
{
	my $self = shift;
	return $self->{queryString};
}

sub setQueryString
{
	my $self = shift;
	my $queryString = shift;
	$self->{queryString} = $queryString;
}

sub getPromptingQueryXml
{
	my $self = shift;
	return $self->{promptingQueryXml};
}

sub setPromptingQueryXml
{
	my $self = shift;
	my $promptingQueryXml = shift;
	$self->{promptingQueryXml} = $promptingQueryXml;
}

sub getTemplate
{
	my $self = shift;
	return $self->{template};
}

sub setTemplate
{
	my $self = shift;
	my $template = shift;
	$self->{template} = $template;
}

sub getDescription
{
	my $self = shift;
	return $self->{description};
}

sub setDescription
{
	my $self = shift;
	my $description = shift;
	$self->{description} = $description;
}

sub toConfigData
{
	my $self = shift;
	my $retData = ChangeSynergy::util::createBeginConfigTag($self->{CCM_QUERY});
	
	if ((defined($self->{name})) && (length($self->{name}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{NAME}, $self->{name});
	}

	if ((defined($self->{queryString})) && (length($self->{queryString}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{QRY_STRING}, $self->{queryString});
	}
	
	if ((defined($self->{promptingQueryXml})) && (length($self->{promptingQueryXml}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{PROMPTING_QUERY_XML}, $self->{promptingQueryXml});
	}
	
	if ((defined($self->{template})) && (length($self->{template}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{QRY_TEMPLATE}, $self->{template});
	}
	
	if ((defined($self->{description})) && (length($self->{description}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{DESCRIPTION}, $self->{description});
	}
	
	$retData .= ChangeSynergy::util::createEndConfigTag($self->{CCM_QUERY});
	
	return $retData;
}

# [CCM_QUERY]
#	[NAME][/NAME]
#	[QRY_STRING][/QRY_STRING]
#	[QRY_TEMPLATE][/QRY_TEMPLATE]
#	[DESCRIPTION][/DESCRIPTION]
# [/CCM_QUERY]

sub parseConfigEntry
{
	my $self = shift;

	if(!defined($self->{configData}))
	{
		die "Cannot parse query entry data, undef";
	}

	if(length($self->{configData}) == 0)
	{
		die "Cannot parse query entry data, 0 length";
	}
	
	my $configData = $self->{configData};
	
	$self->{name} = ChangeSynergy::util::extractConfigValue($configData, $self->{NAME}, 1);
	$self->{queryString} = ChangeSynergy::util::extractConfigValue($configData, $self->{QRY_STRING}, 1);
	$self->{promptingQueryXml} = ChangeSynergy::util::extractConfigValue($configData, $self->{PROMPTING_QUERY_XML}, 0);
	$self->{template} = ChangeSynergy::util::extractConfigValue($configData, $self->{QRY_TEMPLATE}, 0);
	$self->{description} = ChangeSynergy::util::extractConfigValue($configData, $self->{DESCRIPTION}, 0);
}

1;

__END__

=head1 Name

ChangeSynergy::QueryEntry

=head1 Description

The ChangeSynergy::QueryEntry class is used as part of a set of classes when a report is imported or exported from the server.
All L<ReportEntry> objects contain a QueryEntry object and one or more L<SubReportEntry> objects. These set of objects make up
a standard Change report configuration entry. This class represents a CCM_QUERY entry as shown below for the 'Basic Summary' query.

 [CCM_QUERY]
	[NAME]All CRs[/NAME]
	[QRY_STRING]cvtype='problem'[/QRY_STRING]
	[DESCRIPTION]All CRs in the database. (CAUTION: This could be a large list)[/DESCRIPTION]
 [/CCM_QUERY]

Example:

 eval
 {
 	$csapi->setUpConnection("http", "machine", 8600);

	my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

	#Construct a new Globals object.
	my $globals = new ChangeSynergy::Globals();
		
	#Export a CR report named 'My Report' from the shared preferences 
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();

	print "Name: " . $queryEntry->getName() . "\n";
	print "Query String: " . $queryEntry->getQueryString() . "\n";
	print "Desc: " . $queryEntry->getDescription() . "\n";
	print "Prompting: " . $queryEntry->getPromptingQueryXml() . "\n";
	print "Template: " . $queryEntry->getTemplate() . "\n";
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
			scalar
		</td>
		<td>
			<code><a href="#getDescription">getDescription</a>()</code><br />
			Gets the description for the query.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getName">getName</a>()</code><br />
			Gets the name of the query, in the configuration example above this is the data in the NAME tag.
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
			scalar
		</td>
		<td>
			<code><a href="#getQueryString">getQueryString</a>()</code><br />
			Gets the query string.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getTemplate">getTemplate</a>()</code><br />
			Gets the template file that will be loaded to prompt the user for query information.
		</td>
	</tr>
	
	<!-- Setters -->
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setDescription">setDescription</a>(scalar description)</code><br />
			Sets the description for this query, most likely this description will never been seen in the interface
			as the reports description will be shown to end users. 
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setName">setName</a>()</code><br />
			Sets the name of the query, in the configuration example above this is the data in the NAME tag. In most cases the name of the
			query will not need to be modified as Change server will take care of uniquely naming the query as it is embedded in a report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setPromptingQueryXml">setPromptingQueryXml</a>(scalar queryName)</code><br />
			Sets the prompting query XML for the query. This defines how a prompting query should function.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setQueryString">setQueryString</a>(scalar queryString)</code><br />
			Sets the query string that will be used when the report is run. For example, (cvtype='problem') and
			(crstatus='assigned'). The query string is the one piece of data in a QueryEntry that you are most likely to Change
			while importing a report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setTemplate">setTemplate</a>()</code><br />
			Sets the template file that will be loaded to prompt the user for query information when in the querying interface.
		</td>
	</tr>
	
</table>

=end html

=head1 Methods

=over 4

=cut

##############################################################################

=begin html

	<hr>
	<a href="getDescription"></a>

=end html

=item B<getDescription>

Gets the description for the query. As a report has it's own description this description most likely will not be visible to any
end users.

 Returns: scalar
	The description of the query.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getName"></a>

=end html

=item B<getName>

Gets the name of the query, since these queries are under a report the name of the query will never be displayed but a name must
still exist.

 Returns: scalar
	The name of the query.

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
	<a href="getQueryString"></a>

=end html

=item B<getQueryString>

Gets the query string for the query.

 Returns: scalar
	A query string.

=cut

#############################################################################

=begin html

	<hr>
	<a href="getTemplate"></a>

=end html

=item B<getTemplate>

Gets the template file that will be loaded to prompt the user for query information. This only works for normal queries
and not queries that are part of reports.

 Returns: scalar
	The name of the template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="setDescription"></a>

=end html

=item B<setDescription>

Sets the description for the query, As a report has it's own description this description most likely will not be visible to any
end users.

 Parameters:
	scalar: The description for the query.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();
	$queryEntry->setDescription("All entered CRs");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setName"></a>

=end html

=item B<setName>

Sets the name of the query, since these queries are under a report the name of the query will never be displayed but a name must
still exist. The Change server will ensure that the name is unique.

 Parameters:
	scalar: The name this query shall have upon creation.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();
	$queryEntry->setName("All entered CRs");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setPromptingQueryXml"></a>

=end html

=item B<setPromptingQueryXml>

Sets the prompting query XML data for the query. It is best to create prompting reports via the interface or by exporting and 
importing an existing report. Only set this setting if you know the XML format.

 Parameters:
	scalar: The XML data that defines a promting query.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();
	$queryEntry->setPromptingQueryXml(XML DATA);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setQueryString"></a>

=end html

=item B<setQueryString>

Sets the query string that will be used when the report is run.

 Parameters:
	scalar: The query string.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();
	$queryEntry->setQueryString("(cvtype='problem') and (crstatus='entered')");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setTemplate"></a>

=end html

=item B<setTemplate>

Sets the template name that will be loaded to ask the user for query input. This only works for standard querise and not
queries that are part of a report.

 Parameters:
	scalar: The template name.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = $reportEntry->getQueryEntry();
	$queryEntry->setTemplate("NotEditableQuery");

=cut