###########################################################
## ReportEntry Class
###########################################################

package ChangeSynergy::ReportEntry;

use strict;
use warnings;
use ChangeSynergy::util;

sub new
{
	shift; #take off the ReportEntry which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};
	
	# Initialize data for this object
	$self->{name} = undef;
	$self->{baseName} = undef;
	$self->{reportTemplate} = undef;
	$self->{exportFormat} = undef;
	$self->{maxQuery} = -1;
	$self->{maxString} = -1;
	$self->{description} = undef;
	$self->{incrementSize} = -1;
	$self->{incremental} = -1;
	$self->{style} = undef;
	$self->{customDisplayOrder} = -1;
	$self->{queryEntry} = undef;
	$self->{subreports} = ();
	
	$self->{_queryName} = undef;
	$self->{_subReportNames} = ();
	$self->{_subReportTypes} = ();
	$self->{_subReportRelations} = ();
	
	#Config entry tags
	$self->{CCM_REPORT} = "CCM_REPORT";
	$self->{PROBLEM_DEF} = "PROBLEM_DEF";
	$self->{TASK_DEF} = "TASK_DEF";
	$self->{OBJECT_DEF} = "OBJECT_DEF";
	$self->{QUERY} = "QUERY";
	$self->{CONTINUUS_CFG_DELIMITER} = "CONTINUUS_CFG_DELIMITER";
	
	$self->{NAME} = "NAME";
	$self->{BASE_NAME} = "BASE_NAME";
	$self->{RPT_TEMPLATE} = "RPT_TEMPLATE";
	$self->{RELATION} = "RELATION";
	$self->{EXPORT_FORMAT} = "EXPORT_FORMAT";
	$self->{MAX_QUERY} = "MAX_QUERY";
	$self->{MAX_STRING} = "MAX_STRING";
	$self->{DESCRIPTION} = "DESCRIPTION";
	$self->{INCREMENT_SIZE} = "INCREMENT_SIZE";
	$self->{INCREMENTAL} = "INCREMENTAL";
	$self->{STYLE} = "STYLE";
	$self->{CUSTOM_DISPLAY_ORDER} = "CUSTOM_DISPLAY_ORDER";
	$self->{IMAGE_PATH} = "IMAGE_PATH";
	
	# If a parameter was passed in then set it as the configData
	if(@_ > 0)
	{
		my $configData = shift;
		my $folderName = shift;
		$self->{configData} = ChangeSynergy::util::xmlDecode($configData);
		$self->{folderName} = ChangeSynergy::util::xmlDecode($folderName);
	}
	else
	{
		$self->{configData} = undef;
		$self->{folderName} = undef;
		
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
		die "Invalid configuration data: ReportEntry: \n" .$self->{configData} . "\n$@";
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
	my $value = shift;
	$self->{name} = $value;
}

sub getBaseName
{
	my $self = shift;
	return $self->{baseName};
}

sub setBaseName
{
	my $self = shift;
	my $value = shift;
	$self->{baseName} = $value;
}

sub getReportTemplate
{
	my $self = shift;
	return $self->{reportTemplate};
}

sub setReportTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{reportTemplate} = $value;
}

sub getQueryEntry
{
	my $self = shift;
	return $self->{queryEntry};
}

sub setQueryEntry
{
	my $self = shift;
	my $value = shift;
	$self->{queryEntry} = $value;
}

sub getSubReports
{
	my $self = shift;
	my @subReports = @{$self->{subReports}};
	return @subReports;
}

sub setSubReports
{
	my ($self, $refValue) = @_;
	#get the real array back from the reference.
	
	my @value = @$refValue;
	@{$self->{subReports}} = @value;
}

sub getExportFormat
{
	my $self = shift;
	return $self->{exportFormat};
}

sub setExportFormat
{
	my $self = shift;
	my $value = shift;
	$self->{exportFormat} = $value;
}

sub getMaxQuery
{
	my $self = shift;
	return $self->{maxQuery};
}

sub setMaxQuery
{
	my $self = shift;
	my $value = shift;
	$self->{maxQuery} = $value;
}

sub getMaxString
{
	my $self = shift;
	return $self->{maxString};
}

sub setMaxString
{
	my $self = shift;
	my $value = shift;
	$self->{maxString} = $value;
}

sub getIncremental
{
	my $self = shift;
	return $self->{incremental};
}

sub setIncremental
{
	my $self = shift;
	my $value = shift;
	$self->{incremental} = $value;
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

sub getStyle
{
	my $self = shift;
	return $self->{style};
}

sub setStyle
{
	my $self = shift;
	my $value = shift;
	$self->{style} = $value;
}

sub getCustomDisplayOrder
{
	my $self = shift;
	return $self->{customDisplayOrder};
}

sub setCustomDisplayOrder
{
	my $self = shift;
	my $value = shift;
	$self->{customDisplayOrder} = $value;
}

sub getImagePath
{
	my $self = shift;
	return $self->{imagePath};
}

sub setImagePath
{
	my $self = shift;
	my $value = shift;
	$self->{imagePath} = $value;
}

sub getFolderName
{
	my $self = shift;
	return $self->{folderName};
}

sub setFolderName
{
	my $self = shift;
	my $folderName = shift;
	$self->{folderName} = $folderName;
}

sub toXml
{
	my $self = shift;
	
	my $CSAPI_REPORT_ENTRY = "csapi_report_entry";
	my $CSAPI_FOLDER_NAME = "csapi_folder_name";
	my $CSAPI_CONFIG_FILE = "csapi_config_file";
	
	my $retData = "<$CSAPI_REPORT_ENTRY>\n";
	$retData .= "<$CSAPI_CONFIG_FILE>\n";
	$retData .= ChangeSynergy::util::xmlEncode(toConfigData($self)) . "\n";
	$retData .= "</$CSAPI_CONFIG_FILE>\n";
	$retData .= "<$CSAPI_FOLDER_NAME>\n";
	$retData .= ChangeSynergy::util::xmlEncode($self->{folderName}) . "\n";
	$retData .= "</$CSAPI_FOLDER_NAME>\n";
	$retData .= "</$CSAPI_REPORT_ENTRY>";
	
	return $retData;
}

sub toConfigData
{
	my $self = shift;
	my $retData = ChangeSynergy::util::createBeginConfigTag($self->{CCM_REPORT});
	
	if ((defined($self->{name})) && (length($self->{name}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{NAME}, $self->{name});
	}

	if ((defined($self->{baseName})) && (length($self->{baseName}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{BASE_NAME}, $self->{baseName});
	}
	
	if ((defined($self->{reportTemplate})) && (length($self->{reportTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{RPT_TEMPLATE}, $self->{reportTemplate});
	}
	
	$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{QUERY}, $self->{queryEntry}->getName());
	
	#figure out ordering and problem vs task vs object and relation name!
	my @subReports = @{$self->{subReports}};
	
	foreach my $subReport (@subReports)
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($subReport->getDefinitionType(), $subReport->getName());
		
		if ((defined($subReport->getRelation())) && (length($subReport->getRelation()) > 0))
		{
			$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{RELATION}, $subReport->getRelation());
		}
	}
	
	if ((defined($self->{exportFormat})) && (length($self->{exportFormat}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{EXPORT_FORMAT}, $self->{exportFormat});
	}
	
	if ((defined($self->{maxQuery})) && (length($self->{maxQuery}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{MAX_QUERY}, $self->{maxQuery});
	}
	
	if ((defined($self->{maxString})) && (length($self->{maxString}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{MAX_STRING}, $self->{maxString});
	}
	
	if ((defined($self->{incremental})) && (length($self->{incremental}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{INCREMENTAL}, $self->{incremental});
	}
	
	if ((defined($self->{incrementSize})) && (length($self->{incrementSize}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{INCREMENT_SIZE}, $self->{incrementSize});
	}
	
	if ((defined($self->{style})) && (length($self->{style}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{STYLE}, $self->{style});
	}
	
	if ((defined($self->{customDisplayOrder})) && (length($self->{customDisplayOrder}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{CUSTOM_DISPLAY_ORDER}, $self->{customDisplayOrder});
	}
	
	if ((defined($self->{imagePath})) && (length($self->{imagePath}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{IMAGE_PATH}, $self->{imagePath});
	}
	
	if ((defined($self->{description})) && (length($self->{description}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{DESCRIPTION}, $self->{description});
	}
	
	$retData .= ChangeSynergy::util::createEndConfigTag($self->{CCM_REPORT});
	
	#Query entry
	$retData .= ChangeSynergy::util::createBeginConfigTag($self->{CONTINUUS_CFG_DELIMITER});
	$retData .= $self->{queryEntry}->toConfigData();
	
	#sub report entries
	foreach my $subReport (@subReports)
	{
		$retData .= ChangeSynergy::util::createBeginConfigTag($self->{CONTINUUS_CFG_DELIMITER});
		$retData .= $subReport->toConfigData();
	}
	
	return $retData;
}

sub _getQueryName
{
	my $self = shift;
	return $self->{_queryName};
}

sub _getSubreportNames
{
	my $self = shift;
	my @subReportNames = @{$self->{_subReportNames}};
	return @subReportNames;
}

sub _getSubreportTypes
{
	my $self = shift;
	my @subReportTypes = @{$self->{_subReportTypes}};
	return @subReportTypes;
}

sub _getSubreportRelations
{
	my $self = shift;
	my @subReportRelations = @{$self->{_subReportRelations}};
	return @subReportRelations;
}

# [CCM_REPORT] 
#	[NAME][/NAME]
#	[BASE_NAME][/BASE_NAME]
#	[RPT_TEMPLATE][/RPT_TEMPLATE]
#	******* THESE TAGS MUST BE IN LINEAR ORDER ******* 
#	[QUERY][/QUERY] <<< Required: even if empty [PROBLEM_DEF][/PROBLEM_DEF] or
#	[TASK_DEF][/TASK_DEF] or [OBJECT_DEF][/OBJECT_DEF] [RELATION][/RELATION] [PROBLEM_DEF][/PROBLEM_DEF] or
#	 * [TASK_DEF][/TASK_DEF] or [OBJECT_DEF][/OBJECT_DEF] [RELATION][/RELATION] [PROBLEM_DEF][/PROBLEM_DEF] or
#	 * [TASK_DEF][/TASK_DEF] or [OBJECT_DEF][/OBJECT_DEF] ... ******* END LINEAR ORDER *******
#	[EXPORT_FORMAT][/EXPORT_FORMAT]
#	[MAX_QUERY][/MAX_QUERY]
#	[MAX_STRING][/MAX_STRING]
#	[INCREMENTAL][/INCREMENTAL]
#	[INCREMENT_SIZE][/INCREMENT_SIZE]
#	[DESCRIPTION][/DESCRIPTION]
#	[STYLE][/STYLE]
#	[CUSTOM_DISPLAY_ORDER][/CUSTOM_DISPLAY_ORDER]
#	[IMAGE_PATH][/IMAGE_PATH]
# [/CCM_REPORT]

sub parseConfigEntry
{
	my $self = shift;

	if(!defined($self->{configData}))
	{
		die "Cannot parse report entry data, undef";
	}

	if(length($self->{configData}) == 0)
	{
		die "Cannot parse report entry data, 0 length";
	}
	
	my $configData = $self->{configData};
	
	$self->{name} = ChangeSynergy::util::extractConfigValue($configData, $self->{NAME}, 1);
	$self->{baseName} = ChangeSynergy::util::extractConfigValue($configData, $self->{BASE_NAME}, 0);
	$self->{reportTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{RPT_TEMPLATE}, 0);
	$self->{_queryName} = ChangeSynergy::util::extractConfigValue($configData, $self->{QUERY}, 1);
	$self->{exportFormat} = ChangeSynergy::util::extractConfigValue($configData, $self->{EXPORT_FORMAT}, 0);
	$self->{maxQuery} = ChangeSynergy::util::extractConfigValue($configData, $self->{MAX_QUERY}, 0);
	$self->{maxString} = ChangeSynergy::util::extractConfigValue($configData, $self->{MAX_STRING}, 0);
	$self->{description} = ChangeSynergy::util::extractConfigValue($configData, $self->{DESCRIPTION}, 1);
	$self->{incrementSize} = ChangeSynergy::util::extractConfigValue($configData, $self->{INCREMENT_SIZE}, 0);
	$self->{incremental} = ChangeSynergy::util::extractConfigValue($configData, $self->{INCREMENTAL}, 0);
	$self->{style} = ChangeSynergy::util::extractConfigValue($configData, $self->{STYLE}, 0);
	$self->{customDisplayOrder} = ChangeSynergy::util::extractConfigValue($configData, $self->{CUSTOM_DISPLAY_ORDER}, 0);
	$self->{imagePath} = ChangeSynergy::util::extractConfigValue($configData, $self->{IMAGE_PATH}, 0);
	
	my $problemDef = ChangeSynergy::util::extractConfigValue($configData, $self->{PROBLEM_DEF}, 0);
	my $taskDef = ChangeSynergy::util::extractConfigValue($configData, $self->{TASK_DEF}, 0);
	my $objectDef = ChangeSynergy::util::extractConfigValue($configData, $self->{OBJECT_DEF}, 0);
	
	if ((defined($problemDef)) && (length($problemDef) > 0))
	{
		push @{$self->{_subReportNames}}, $problemDef;
		push @{$self->{_subReportTypes}}, $self->{PROBLEM_DEF};
	}
	
	if ((defined($taskDef)) && (length($taskDef) > 0))
	{
		push @{$self->{_subReportNames}}, $taskDef;
		push @{$self->{_subReportTypes}}, $self->{TASK_DEF};
	}
	
	if ((defined($objectDef)) && (length($objectDef) > 0))
	{
		push @{$self->{_subReportNames}}, $objectDef;
		push @{$self->{_subReportTypes}}, $self->{OBJECT_DEF};
	}
	
	my $modifiedConfigData = $configData;
	my $size = @{$self->{_subReportTypes}};
	
	for (my $i = 0; $i < $size; $i++)
	{
		push @{$self->{_subReportRelations}}, ChangeSynergy::util::extractConfigValue($modifiedConfigData, $self->{RELATION}, 0);
		my $tag = ChangeSynergy::util::createEndConfigTag($self->{RELATION});
		$modifiedConfigData = substr($modifiedConfigData, index($configData,$tag) + length($tag));
	}
}

1;

__END__

=head1 Name

ChangeSynergy::ReportEntry

=head1 Description

The ChangeSynergy::ReportEntry class is used as part of a set of classes when a report is imported or exported from the server.
All ReportEntry objects contain a L<QueryEntry> object and one or more L<SubReportEntry> objects. These set of objects make up
a standard Change report configuration entry. This class represents a CCM_REPORT entry as shown below for the 
'Column' report.

 [CCM_REPORT]
 	[NAME]Column[/NAME]
 	[QUERY]All CRs[/QUERY]
 	[PROBLEM_DEF]column_cr[/PROBLEM_DEF]
 	[EXPORT_FORMAT]HTML[/EXPORT_FORMAT]
 	[INCREMENTAL]true[/INCREMENTAL]
 	[INCREMENT_SIZE]20[/INCREMENT_SIZE]
 	[IMAGE_PATH]columnFormat.png[/IMAGE_PATH]
 	[CUSTOM_DISPLAY_ORDER]0[/CUSTOM_DISPLAY_ORDER]
 	[DESCRIPTION]
 		Custom report format that allows you to select a list 
 	 	of problem attributes. Problem number and status are linked to other forms.
 	 [/DESCRIPTION]
 [/CCM_REPORT]

While it may be possible to create all three of these classes by hand, it is best to just export a report, modify it and then import it, or export
it to a file and modify it and then import it. While all of the settings in these three classes can be changed many of them should not be changed
unless you are sure of what you are doing. Changing these items is just like changing the configuration file settings for the predefined system
reports.

Example:

 eval
 {
 	$csapi->setUpConnection("http", "machine", 8600);

	my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

	#Construct a new Globals object.
	my $globals = new ChangeSynergy::Globals();
		
	#Export a CR report named 'Column' from the sysetm configuration 
	my $reportEntry = $csapi->exportAReport($aUser, "Column",  $globals->{PROBLEM_TYPE}, $globals->{SYSTEM_CONFIG});
	
	print "\nreportEntry->getName          : " . $reportEntry->getName();
	print "\nreportEntry->getBaseName      : " . $reportEntry->getBaseName();
	print "\nreportEntry->getReportTemplate: " . $reportEntry->getReportTemplate();
	print "\nreportEntry->getExportFormat  : " . $reportEntry->getExportFormat();
	print "\nreportEntry->getMaxQuery      : " . $reportEntry->getMaxQuery();
	print "\nreportEntry->getMaxString     : " . $reportEntry->getMaxString();
	print "\nreportEntry->getDescription   : " . $reportEntry->getDescription();
	print "\nreportEntry->getIncrementSize : " . $reportEntry->getIncrementSize();
	print "\nreportEntry->getIncremental   : " . $reportEntry->getIncremental();
	print "\nreportEntry->getStyle         : " . $reportEntry->getStyle();
	print "\nreportEntry->getCustomDisOrder: " . $reportEntry->getCustomDisplayOrder();
	print "\nreportEntry->getImagePath     : " . $reportEntry->getImagePath();
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
			<code><a href="#getBaseName">getBaseName</a>()</code><br />
			Gets the name of the report that this report is based off of. If not based off of any report then it will return the same
			thing as getName does.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getCustomDisplayOrder">getCustomDisplayOrder</a>()</code><br />
			Gets the order that an adhoc report format should be displayed in the interface starting from 0.
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
			<code><a href="#getExportFormat">getExportFormat</a>()</code><br />
			Gets export format of the report, this defines the file extention for the report results.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getIncremental">getIncremental</a>()</code><br />
			Gets if this report uses pagination or not, value is true or false.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getIncrementSize">getIncrementSize</a>()</code><br />
			Gets the number of items per page in a pagination report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getMaxString">getMaxString</a>()</code><br />
			Gets the maximum number of characters to be retrieved for attributes with the TEXT data type.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getMaxQuery">getMaxQuery</a>()</code><br />
			Gets the maximum number of results from the database this report will allow to be returned.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getName">getName</a>()</code><br />
			Gets the name of the report, in the configuration example above this is the data in the NAME tag. This is the name
			users will see in the reporting interface.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getQueryEntry">getQueryEntry</a>()</code><br />
			Gets the L<QueryEntry> object that represents the CCM_QUERY configuration definition this report is linked to.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getReportTemplate">getReportTemplate</a>()</code><br />
			Gets the name of the template that is loaded when the report name is clicked from the reporting interface.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getStyle">getStyle</a>()</code><br />
			Gets the style type of the report, currently only used for charts and matrix reports.
		</td>
	</tr>
	<tr>
		<td width="10%">
			array
		</td>
		<td>
			<code><a href="#getSubReports">getSubReports</a>()</code><br />
			Gets the array of L<SubReportEntry> objects that define the PROBLEM_DEF, TASK_DEF and OBJECT_DEF entries for this report.
		</td>
	</tr>
	
	<!-- Setters -->
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setBaseName">setBaseName</a>(scalar baseName)</code><br />
			Sets the name of the report that this report is based off of. For importing and exporting reports this does not need to be
			set as exporting and importing a report exports all the configuration entries so no base report entries need to be looked up.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setCustomDisplayOrder">setCustomDisplayOrder</a>(scalar baseName)</code><br />
			Sets the order that an adhoc report format should be displayed in the interface starting from 0.
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
			<code><a href="#setExportFormat">setExportFormat</a>(scalar exportFormat)</code><br />
			Sets the export format of the report, this defines the file extention for the report results. For example, "HTML" or "TXT".
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setIncremental">setIncremental</a>(scalar incremental)</code><br />
			Sets if this report uses pagination or not, value is true or false.
		</td>
	</tr><tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setIncrementSize">setIncrementSize</a>(scalar incrementSize)</code><br />
			Sets the number of items per page in a pagination report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setMaxString">setMaxString</a>(scalar maxString)</code><br />
			Sets the maximum number of characters to be retrieved for attributes with the TEXT data type.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setMaxQuery">setMaxQuery</a>(scalar maxQuery)</code><br />
			Sets the maximum number of results this report will allow the query function to return.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setName">setName</a>(scalar reportName)</code><br />
			Sets the name of the report, in the configuration example above this is the data in the NAME tag. This is the name
			users will see in the reporting interface.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setQueryEntry">setQueryEntry</a>(scalar queryEntry)</code><br />
			Sets the L<QueryEntry> object that represents the CCM_QUERY configuration definition this report is linked to.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setReportTemplate">setReportTemplate</a>(scalar reportTemplate)</code><br />
			Sets the name of the template that is loaded when the report name is clicked from the reporting interface. An example
			of a report template is "TrendWithBreakdown".
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setStyle">setStyle</a>(scalar style)</code><br />
			Sets the style type of the report, currently only used for charts and matrix reports.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setSubReports">setSubReports</a>(array subreports)</code><br />
			Sets the array of L<SubReportEntry> objects that define the PROBLEM_DEF, TASK_DEF and OBJECT_DEF entries for this report.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#toXml">toXml</a>(scalar xmlData)</code><br />
			Converts the ReportEntry, QueryEntry and all SubReportEntries into an XML string that can be saved out to the file system
			and reloaded to reconstuct the ReportEntry object.
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
	<a href="getBaseName"></a>

=end html

=item B<getBaseName>

Gets the name of the report that this report is based off of. If not based off of any report then it will return the same
thing as getName does. 

 Returns: scalar
	The name of the base report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getCustomDisplayOrder"></a>

=end html

=item B<getCustomDisplayOrder>

Gets the order that an adhoc report format should be displayed in the interface starting from 0.

 Returns: scalar
	The order an ad hoc report should be diplayed in the interface starting from 0.

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
	<a href="getExportFormat"></a>

=end html

=item B<getExportFormat>

Gets export format of the report, this defines the file extention for the report results.

 Returns: scalar
	The export format, or file extension.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getIncremental"></a>

=end html

=item B<getIncremental>

Gets if this report uses pagination or not, value is true or false.

 Returns: scalar
	True if the report uses pagination, false otherwise.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getIncrementSize"></a>

=end html

=item B<getIncrementSize>

Gets the number of items per page in a pagination report.

 Returns: scalar
	The maximum number of items to display on a paginated report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getMaxString"></a>

=end html

=item B<getMaxString>

Gets the maximum number of characters to be retrieved for attributes with the TEXT data type. 

 Returns: scalar
	The maximum number of characters to return for an attribute.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getMaxQuery"></a>

=end html

=item B<getMaxQuery>

Gets the maximum number of results from the database this report will allow to be returned. 

 Returns: scalar
	The maximum number of results to return.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getName"></a>

=end html

=item B<getName>

Gets the name of the report, this is the name that users will see in the Change reporting interface. 

 Returns: scalar
	The name of the report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getQueryEntry"></a>

=end html

=item B<getQueryEntry>

Gets the L<QueryEntry> object that represents the CCM_QUERY configuration definition this report is linked to. 

 Returns: scalar
	The query entry for the report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getReportTemplate"></a>

=end html

=item B<getReportTemplate>

Gets the name of the template that is loaded when the report name is clicked from the reporting interface. A report template
usually asks the user to supply more information before the report can be run. An example of a report template is "TrendWithBreakdown".

 Returns: scalar
	The name of the report template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getStyle"></a>

=end html

=item B<getStyle>

Gets the style type of the report, currently only used for charts and matrix reports.

 Returns: scalar
	The style of the report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getSubReports"></a>

=end html

=item B<getSubReports>

Gets the array of L<SubReportEntry> objects that define the PROBLEM_DEF, TASK_DEF and OBJECT_DEF entries for this report.

 Returns: array
	The array of subreport entries.

=cut

##############################################################################

=begin html

	<hr>
	<a href="setBaseName"></a>

=end html

=item B<setBaseName>

Sets the name of the report that this report is based off of. For importing and exporting reports this does not need to be
set as exporting and importing a report exports all the configuration entries so no base report entries need to be looked up.

 Parameters:
	scalar: The name of the base report.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setBaseName("Column");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setCustomDisplayOrder"></a>

=end html

=item B<setCustomDisplayOrder>

Sets the order that an adhoc report format should be displayed in the interface starting from 0. This setting only has any
impact for report formats that are displayed when the "new" link is clicked in the interface.

 Parameters:
	scalar: What number the report should be displayed in.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setCustomDisplayOrder("12");

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
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setDescription("HTML");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setExportFormat"></a>

=end html

=item B<setExportFormat>

Sets the export format of the report, this defines the file extention for the report results. For example, "HTML" or "TXT".

 Parameters:
	scalar: The export format type.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setExportFormat("HTML");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setIncremental"></a>

=end html

=item B<setIncremental>

Sets if this report uses pagination or not, value is true or false.

 Parameters:
	scalar: True if the report uses pagination, false otherwise.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setIncremental("true");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setIncrementSize"></a>

=end html

=item B<setIncrementSize>

Sets the number of items per page in a pagination report.

 Parameters:
	scalar: The maximum number of results to display per page on a pagination report.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setIncrementSize("20");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setMaxString"></a>

=end html

=item B<setMaxString>

Sets the maximum number of characters an attribute with the data type of TEXT may return. If an attribute has more
characters than the maximum the characters over the maximum will be truncated. If this setting is omitted then the
 report will use the MAX_STRING defined in pt.cfg file.

 Parameters:
	scalar: The maximum number characters allowed for TEXT types.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setMaxString("32000");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setMaxQuery"></a>

=end html

=item B<setMaxQuery>

Sets the maximum number of results this report will allow the query function to return. If the query finds more
results than the maximum and error will be returned to the user telling them that too many results were found. If
this setting is omitted then the report will use the MAX_QUERY defined in pt.cfg file.

 Parameters:
	scalar: The maximum number of results to allow.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setMaxQuery("2000");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setName"></a>

=end html

=item B<setName>

Sets the name of the report, this is the name that users will see in the Change reporting interface. The
report name must be unique or the L<csapi>importAReport will fail.

 Parameters:
	scalar: The name the report will have when it is imported.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setName("Imported Report");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setQueryEntry"></a>

=end html

=item B<setQueryEntry>

Sets the L<QueryEntry> object that represents the CCM_QUERY configuration definition this report is linked to. A report must
have a query entry as the query entry contains the query string the report will use to be run. 

 Parameters:
	scalar: The query entry that contains the query information for this report.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $queryEntry = new ChangeSynergy::QueryEntry();
	$queryEntry->setName("query");
	$queryEntry->setQueryString("()cvtype='problem')");
	$reportEntry->setQueryEntry($queryEntry);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setReportTemplate"></a>

=end html

=item B<setReportTemplate>

Gets the name of the template that is loaded when the report name is clicked from the reporting interface. A report template
usually asks the user to supply more information before the report can be run. An example of a report template is "TrendWithBreakdown".

 Parameters:
	scalar: The name of the report template.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setReportTemplate("TrendWithBreakdown");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setStyle"></a>

=end html

=item B<setStyle>

Sets the style type of the report, currently only used for charts and matrix reports. Valid values are VBarChart, HBarChart,
LineChart, PieChart and Matrix.

 Parameters:
	scalar: The style of the report.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	$reportEntry->setStyle("VBarChart");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setSubReports"></a>

=end html

=item B<setSubReports>

Sets the array of L<SubReportEntry> objects that define the PROBLEM_DEF, TASK_DEF and OBJECT_DEF entries for this report. All 
reports must have at least one subreport entry.

 Parameters:
	array: The list of subreport entries.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subReports = ();
	push @subReports, new ChangeSynergy::SubReportEntry(CCM_PROBLEM, CCM_TASK or CCM_OBJECT entry);
	$reportEntry->setSubReports(\@subreports);

=cut

##############################################################################

=begin html

	<hr>
	<a href="toXml"></a>

=end html

=item B<toXml>

Converts the ReportEntry, QueryEntry and all SubReportEntries into an XML string that can be saved out to the file system
			and reloaded to reconstuct the ReportEntry object.

 Returns: array
	The XML data representing the object.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my $file = $reportEntry->getName() . ".xml";
		
	open(OUTPUT, ">$file");
	print(OUTPUT $reportEntry->toXml());
	close(OUTPUT);

=cut
	