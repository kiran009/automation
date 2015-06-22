###########################################################
## ReportEntryFactory Class
###########################################################
package ChangeSynergy::ReportEntryFactory;

use strict;

use ChangeSynergy::ReportEntry;
use ChangeSynergy::QueryEntry;
use ChangeSynergy::SubReportEntry;

sub new
{
	# Initialize data as an empty hash
	my $self = {};
	
	#XML Tags
	$self->{CSAPI_REPORT_ENTRY} = "csapi_report_entry";
	$self->{CSAPI_FOLDER_NAME} = "csapi_folder_name";
	$self->{CSAPI_CONFIG_FILE} = "csapi_config_file";
		
	bless $self;

	return $self;
}

sub createReportEntryFromXml
{
	my $self = shift;
	my $xmlData = shift;
	
	my $reportXml = ChangeSynergy::util::extractXmlValue($xmlData, $self->{CSAPI_REPORT_ENTRY}, 1);
	my $configData = ChangeSynergy::util::extractXmlValue($xmlData, $self->{CSAPI_CONFIG_FILE}, 1);
	my $folderName = ChangeSynergy::util::extractXmlValue($reportXml, $self->{CSAPI_FOLDER_NAME}, 1);
	
	my $reportEntry = undef;
	my $queryEntry = undef;
	my @subReportsUnsorted = ();
	my @entries = split(/\[CONTINUUS_CFG_DELIMITER\]/, $configData);
	
	foreach my $entry (@entries) 
	{
		my $reportIndex = index($entry, "[CCM_REPORT]");
		my $queryIndex = index($entry, "[CCM_QUERY]");
			
		if ($reportIndex >= 0)
		{
			$reportEntry = new ChangeSynergy::ReportEntry($entry, $folderName);
			next;
		}
		elsif ($queryIndex >= 0)
		{
			$queryEntry = new ChangeSynergy::QueryEntry($entry);
			next;
		}
		else
		{
			push @subReportsUnsorted, new ChangeSynergy::SubReportEntry($entry);	
		}
	}
	
	if (!defined($reportEntry))
	{
		die "Returned configuration data did not contain a CCM_REPORT entry.";
	}
	
	if (!defined($queryEntry))
	{
		die "Returned configuration data did not contain a CCM_QUERY entry.";
	}
	else
	{
		$reportEntry->setQueryEntry($queryEntry);
	}

	my @subReportNames = $reportEntry->_getSubreportNames();
	my @subReportTypes = $reportEntry->_getSubreportTypes();
	my @subReportRelations = $reportEntry->_getSubreportRelations();
	my @subReportsSorted = ();
	
	my $size = @subReportNames;
	
	for (my $i = 0; $i < $size; $i++)
	{
		my $subReportName = $subReportNames[$i];
		
		for my $subReport (@subReportsUnsorted)
		{
			if ($subReportName eq $subReport->getName())
			{
				$subReport->setRelation($subReportRelations[$i]);
				$subReport->setDefinitionType($subReportTypes[$i]);
				
				push @subReportsSorted, $subReport;
				last;
			}
		}
	}
		
	$reportEntry->setSubReports(\@subReportsSorted);
	
	return $reportEntry;
}

sub createReportEntriesFromXml
{
	my $self = shift;
	my $xmlData = shift;
	
	my @reportEntries = ();
	
	my $noResults = index($xmlData, "<csapi_no_results />");
	
	if ($noResults >= 0)
	{
		return @reportEntries;
	}
	
	my @entries = ChangeSynergy::util::extractRepeatedXmlValues($xmlData, $self->{CSAPI_REPORT_ENTRY}, 1);
	
	foreach my $entry (@entries)
	{
		#need to add the XML tags back.
		my $newXml = "<$self->{CSAPI_REPORT_ENTRY}>" . $entry . "</$self->{CSAPI_REPORT_ENTRY}>";
		push @reportEntries, &createReportEntryFromXml($self, $newXml);
		
	}
	
	return @reportEntries;
}

1;

__END__
