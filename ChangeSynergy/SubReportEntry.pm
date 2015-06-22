###########################################################
## SubReportEntry Class
###########################################################

package ChangeSynergy::SubReportEntry;

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
	$self->{mainTemplate} = undef;
	$self->{headerTemplate} = undef;
	$self->{attributeTemplate} = undef;
	$self->{imageTemplate} = undef;
	$self->{groupTemplate} = undef;
	$self->{autoAttributeTemplate} = undef;
	$self->{footerTemplate} = undef;
	$self->{groupBy} = undef;
	$self->{customWslet} = undef;
	$self->{xmlContent} = undef;
	$self->{spanAttributeTemplate} = undef;
	$self->{labelTemplate} = undef;
	$self->{autoLabelTemplate} = undef;
	$self->{attributes} = undef;
	$self->{sortOrder} = undef;
	
	$self->{defintionTagName} = undef;
	$self->{definitionType} = undef;
	$self->{relation} = undef;

	#Config entry tags
	$self->{CCM_PROBLEM} = "CCM_PROBLEM";
	$self->{CCM_TASK} = "CCM_TASK";
	$self->{CCM_OBJECT} = "CCM_OBJECT";
	$self->{NAME} = "NAME";
	$self->{MAIN_TEMPLATE} = "MAIN_TEMPLATE";
	$self->{HDR_TEMPLATE} = "HDR_TEMPLATE";
	$self->{ATTR_TEMPLATE} = "ATTR_TEMPLATE";
	$self->{LABEL_TEMPLATE} = "LABEL_TEMPLATE";
	$self->{IMG_TEMPLATE} = "IMG_TEMPLATE";
	$self->{GROUP_TEMPLATE} = "GROUP_TEMPLATE";
	$self->{AUTO_LABEL_TEMPLATE} = "AUTO_LABEL_TEMPLATE";
	$self->{AUTO_ATTR_TEMPLATE} = "AUTO_ATTR_TEMPLATE";
	$self->{SPAN_ATTR_TEMPLATE} = "SPAN_ATTR_TEMPLATE";
	$self->{FTR_TEMPLATE} = "FTR_TEMPLATE";
	$self->{ATTRS} = "ATTRS";
	$self->{GROUP_BY} = "GROUP_BY";
	$self->{SORT_ORDER} = "SORT_ORDER";
	$self->{CUSTOM_WSLET} = "CUSTOM_WSLET";
	$self->{XML_CONTENT} = "XML_CONTENT";
	
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
		die "Invalid configuration data: SubReportEntry: \n" .$self->{configData} . "\n$@";
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

sub getMainTemplate
{
	my $self = shift;
	return $self->{mainTemplate};
}

sub setMainTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{mainTemplate} = $value;
}

sub getHeaderTemplate
{
	my $self = shift;
	return $self->{headerTemplate};
}

sub setHeaderTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{headerTemplate} = $value;
}

sub getAttributeTemplate
{
	my $self = shift;
	return $self->{attributeTemplate};
}

sub setAttributeTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{attributeTemplate} = $value;
}

sub getImageTemplate
{
	my $self = shift;
	return $self->{imageTemplate};
}

sub setImageTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{imageTemplate} = $value;
}

sub getGroupTemplate
{
	my $self = shift;
	return $self->{groupTemplate};
}

sub setGroupTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{groupTemplate} = $value;
}

sub getAutoAttributeTemplate
{
	my $self = shift;
	return $self->{autoAttributeTemplate};
}

sub setAutoAttributeTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{autoAttributeTemplate} = $value;
}

sub getFooterTemplate
{
	my $self = shift;
	return $self->{footerTemplate};
}

sub setFooterTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{footerTemplate} = $value;
}

sub getGroupBy
{
	my $self = shift;
	return $self->{groupBy};
}

sub setGroupBy
{
	my $self = shift;
	my $value = shift;
	$self->{groupBy} = $value;
}

sub getCustomWslet
{
	my $self = shift;
	return $self->{customWslet};
}

sub setCustomWslet
{
	my $self = shift;
	my $value = shift;
	$self->{customWslet} = $value;
}

sub getXmlContent
{
	my $self = shift;
	return $self->{xmlContent};
}

sub setXmlContent
{
	my $self = shift;
	my $value = shift;
	$self->{xmlContent} = $value;
}

sub getSpanAttributeTemplate
{
	my $self = shift;
	return $self->{spanAttributeTemplate};
}

sub setSpanAttributeTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{spanAttributeTemplate} = $value;
}

sub getLabelTemplate
{
	my $self = shift;
	return $self->{labelTemplate};
}

sub setLabelTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{labelTemplate} = $value;
}

sub getAutoLabelTemplate
{
	my $self = shift;
	return $self->{autoLabelTemplate};
}

sub setAutoLabelTemplate
{
	my $self = shift;
	my $value = shift;
	$self->{autoLabelTemplate} = $value;
}

sub getAttributes
{
	my $self = shift;
	return $self->{attributes};
}

sub setAttributes
{
	my $self = shift;
	my $value = shift;
	$self->{attributes} = $value;
}

sub getSortOrder
{
	my $self = shift;
	return $self->{sortOrder};
}

sub setSortOrder
{
	my $self = shift;
	my $value = shift;
	$self->{sortOrder} = $value;
}

sub getRelation
{
	my $self = shift;
	return $self->{relation};
}

sub setRelation
{
	my $self = shift;
	my $value = shift;
	$self->{relation} = $value;
}

sub getDefinitionType
{
	my $self = shift;
	return $self->{definitionType};
}

sub setDefinitionType
{
	my $self = shift;
	my $value = shift;
	$self->{definitionType} = $value;
}

sub toConfigData
{
	my $self = shift;
	my $retData = ChangeSynergy::util::createBeginConfigTag($self->{defintionTagName});
	
	if ((defined($self->{name})) && (length($self->{name}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{NAME}, $self->{name});
	}

	if ((defined($self->{mainTemplate})) && (length($self->{mainTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{MAIN_TEMPLATE}, $self->{mainTemplate});
	}
	
	if ((defined($self->{headerTemplate})) && (length($self->{headerTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{HDR_TEMPLATE}, $self->{headerTemplate});
	}
	
	if ((defined($self->{attributeTemplate})) && (length($self->{attributeTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{ATTR_TEMPLATE}, $self->{attributeTemplate});
	}
	
	if ((defined($self->{labelTemplate})) && (length($self->{labelTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{LABEL_TEMPLATE}, $self->{labelTemplate});
	}
	
	if ((defined($self->{imageTemplate})) && (length($self->{imageTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{IMG_TEMPLATE}, $self->{imageTemplate});
	}
	
	if ((defined($self->{groupTemplate})) && (length($self->{groupTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{GROUP_TEMPLATE}, $self->{groupTemplate});
	}
	
	if ((defined($self->{autoAttributeTemplate})) && (length($self->{autoAttributeTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{AUTO_ATTR_TEMPLATE}, $self->{autoAttributeTemplate});
	}
	
	if ((defined($self->{footerTemplate})) && (length($self->{footerTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{FTR_TEMPLATE}, $self->{footerTemplate});
	}
	
	if ((defined($self->{groupBy})) && (length($self->{groupBy}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{GROUP_BY}, $self->{groupBy});
	}
	
	if ((defined($self->{customWslet})) && (length($self->{customWslet}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{CUSTOM_WSLET}, $self->{customWslet});
	}
	
	if ((defined($self->{xmlContent})) && (length($self->{xmlContent}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{XML_CONTENT}, $self->{xmlContent});
	}
	
	if ((defined($self->{spanAttributeTemplate})) && (length($self->{spanAttributeTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{SPAN_ATTR_TEMPLATE}, $self->{spanAttributeTemplate});
	}
	
	if ((defined($self->{autoLabelTemplate})) && (length($self->{autoLabelTemplate}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{AUTO_LABEL_TEMPLATE}, $self->{autoLabelTemplate});
	}
	
	if ((defined($self->{attributes})) && (length($self->{attributes}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{ATTRS}, $self->{attributes});
	}
	
	if ((defined($self->{sortOrder})) && (length($self->{sortOrder}) > 0))
	{
		$retData .= ChangeSynergy::util::createCompleteConfigTag($self->{SORT_ORDER}, $self->{sortOrder});
	}
	
	$retData .= ChangeSynergy::util::createEndConfigTag($self->{defintionTagName});
	
	return $retData;
}

# [CCM_PROBLEM] or [CCM_TASK] or [CCM_OBJECT]
#	[NAME][/NAME]
#	[MAIN_TEMPLATE][/MAIN_TEMPLATE]
#	[HDR_TEMPLATE][/HDR_TEMPLATE]
#	[ATTR_TEMPLATE][/ATTR_TEMPLATE]
#	[LABEL_TEMPLATE][/LABEL_TEMPLATE]
#	[IMG_TEMPLATE][/IMG_TEMPLATE]
#	[GROUP_TEMPLATE][/GROUP_TEMPLATE]
#	[AUTO_LABEL_TEMPLATE][/AUTO_LABEL_TEMPLATE]
#	[AUTO_ATTR_TEMPLATE][/AUTO_ATTR_TEMPLATE]
#	[SPAN_ATTR_TEMPLATE][/SPAN_ATTR_TEMPLATE]
#	[FTR_TEMPLATE][/FTR_TEMPLATE]
#	[ATTRS][/ATTRS]
#	[GROUP_BY][/GROUP_BY]
#	[SORT_ORDER][/SORT_ORDER]
#	[CUSTOM_WSLET][/CUSTOM_WSLET]
#	[XML_CONTENT][/XML_CONTENT]
# [/CCM_PROBLEM] or [/CCM_TASK] or [/CCM_OBJECT]

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
	$self->{mainTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{MAIN_TEMPLATE}, 0);
	$self->{headerTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{HDR_TEMPLATE}, 0);
	$self->{attributeTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{ATTR_TEMPLATE}, 0);
	$self->{imageTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{IMG_TEMPLATE}, 0);
	$self->{groupTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{GROUP_TEMPLATE}, 0);
	$self->{autoAttributeTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{AUTO_ATTR_TEMPLATE}, 0);
	$self->{footerTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{FTR_TEMPLATE}, 0);
	$self->{groupBy} = ChangeSynergy::util::extractConfigValue($configData, $self->{GROUP_BY}, 0);
	$self->{customWslet} = ChangeSynergy::util::extractConfigValue($configData, $self->{CUSTOM_WSLET}, 0);
	$self->{xmlContent} = ChangeSynergy::util::extractConfigValue($configData, $self->{XML_CONTENT}, 0);
	$self->{spanAttributeTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{SPAN_ATTR_TEMPLATE}, 0);
	$self->{labelTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{LABEL_TEMPLATE}, 0);
	$self->{autoLabelTemplate} = ChangeSynergy::util::extractConfigValue($configData, $self->{AUTO_LABEL_TEMPLATE}, 0);
	$self->{attributes} = ChangeSynergy::util::extractConfigValue($configData, $self->{ATTRS}, 1);
	$self->{sortOrder} = ChangeSynergy::util::extractConfigValue($configData, $self->{SORT_ORDER}, 0);
	
	my $definition = ChangeSynergy::util::extractConfigValue($configData, $self->{CCM_PROBLEM}, 0);
	
	if ((defined($definition)) && (length($definition) > 0))
	{
		$self->{defintionTagName} = $self->{CCM_PROBLEM};
	}
	
	$definition = ChangeSynergy::util::extractConfigValue($configData, $self->{CCM_TASK}, 0);
	
	if ((defined($definition)) && (length($definition) > 0))
	{
		$self->{defintionTagName} = $self->{CCM_TASK};
	}
	
	$definition = ChangeSynergy::util::extractConfigValue($configData, $self->{CCM_OBJECT}, 0);
	
	if ((defined($definition)) && (length($definition) > 0))
	{
		$self->{defintionTagName} = $self->{CCM_OBJECT};
	}
}

1;

__END__

=head1 Name

ChangeSynergy::SubReportEntry

=head1 Description

The ChangeSynergy::SubReportEntry class is used as part of a set of classes when a report is imported or exported from the server.
All L<ReportEntry> objects contain a L<QueryEntry> object and one or more SubReportEntry objects. These set of objects make up
a standard Change report configuration entry. This class represents a CCM_PROBLEM, CCM_TASK or CCM_OBJECT entry as shown
below for the 'Column' reports CCM_PROBLEM definition.

 [CCM_PROBLEM]
 	[NAME]column_cr[/NAME]
 	[MAIN_TEMPLATE]user_framework/column_rpt.html[/MAIN_TEMPLATE]
 	[HDR_TEMPLATE]user_framework/common_bulk_hdr.html[/HDR_TEMPLATE]
 	[ATTR_TEMPLATE]user_framework/column_attr.html[/ATTR_TEMPLATE]
 	[LABEL_TEMPLATE]user_framework/custom_label.html[/LABEL_TEMPLATE]
 	[AUTO_LABEL_TEMPLATE]user_framework/custom_auto_label.html[/AUTO_LABEL_TEMPLATE]
 	[SPAN_ATTR_TEMPLATE]user_framework/custom_span_attr.html[/SPAN_ATTR_TEMPLATE]
 	[AUTO_ATTR_TEMPLATE]user_framework/column_auto_attr.html[/AUTO_ATTR_TEMPLATE]
 	[FTR_TEMPLATE]user_framework/common_bulk_ftr.html[/FTR_TEMPLATE]
 	[ATTRS]problem_number:0:false|crstatus:1:false|problem_synopsis:2:false[/ATTRS]
 	[SORT_ORDER]problem_number:intb:A[/SORT_ORDER]
 [/CCM_PROBLEM]

Example:

 eval
 {
 	$csapi->setUpConnection("http", "machine", 8600);

	my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

	#Construct a new Globals object.
	my $globals = new ChangeSynergy::Globals();
		
	#Export a CR report named 'My Report' from the shared preferences 
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	
	my @subreports = $reportEntry->getSubReports();
	
	for my $subReportEntry (@subreports)
	{
		print "--------------- Sub Report Entry ---------------------\n";
		print "getName:                  " . $subReportEntry->getName() . "\n";
		print "getMainTemplate:          " . $subReportEntry->getMainTemplate() . "\n";
		print "getHeaderTemplate:        " . $subReportEntry->getHeaderTemplate() . "\n";
		print "getAttributeTemplate:     " . $subReportEntry->getAttributeTemplate() . "\n";
		print "getImageTemplate:         " . $subReportEntry->getImageTemplate() . "\n";
		print "getGroupTemplate:         " . $subReportEntry->getGroupTemplate() . "\n";
		print "getAutoAttributeTemplate: " . $subReportEntry->getAutoAttributeTemplate() . "\n";
		print "getFooterTemplate:        " . $subReportEntry->getFooterTemplate() . "\n";
		print "getGroupBy:               " . $subReportEntry->getGroupBy() . "\n";
		print "getCustomWslet:           " . $subReportEntry->getCustomWslet() . "\n";
		print "getXmlContent:            " . $subReportEntry->getXmlContent() . "\n";
		print "getSpanAttributeTemplate: " . $subReportEntry->getSpanAttributeTemplate() . "\n";
		print "getLabelTemplate:         " . $subReportEntry->getLabelTemplate() . "\n";
		print "getAutoLabelTemplate:     " . $subReportEntry->getAutoLabelTemplate() . "\n";
		print "getAttributes:            " . $subReportEntry->getAttributes() . "\n";
		print "getSortOrder:             " . $subReportEntry->getSortOrder() . "\n";
		print "getRelation:              " . $subReportEntry->getRelation() . "\n";
		print "getDefinitionType:        " . $subReportEntry->getDefinitionType() . "\n\n";
	}
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
			<code><a href="#getAttributes">getAttributes</a>()</code><br />
			Gets the attribute string that determines which attributes will be looked up for the subreport an example
			attribute string is problem_number:0:false|crstatus:1:false|problem_synopsis:2:false.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getAttributeTemplate">getAttributeTemplate</a>()</code><br />
			Gets the name of the attribute template to load to format the report results, e.g., user_framework/column_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getAutoAttributeTemplate">getAutoAttributeTemplate</a>()</code><br />
			Gets the name of the auto attribute template to load to format the report results, e.g., user_framework/custom_auto_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getAutoLabelTemplate">getAutoLabelTemplate</a>()</code><br />
			Gets the name of the auto label template to load to format the report results, e.g., user_framework/custom_auto_label.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getCustomWslet">getCustomWslet</a>()</code><br />
			Gets the name of the custom WSLET to run for this subreport.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getDefinitionType">getDefinitionType</a>()</code><br />
			Gets the definition type for this sub report, either PROBLEM_DEF, TASK_DEF or OBJECT_DEF. 
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getFooterTemplate">getFooterTemplate</a>()</code><br />
			Gets the name of the footer template to load, e.g., user_framework/common_bulk_ftr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getGroupBy">getGroupBy</a>()</code><br />
			Gets the groups that have the same attribute name as follows: [GROUP_BY]attribute_name|sort_type:sort_direction[/GROUP_BY].
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getGroupTemplate">getGroupTemplate</a>()</code><br />
			Gets the name of the group template.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getHeaderTemplate">getHeaderTemplate</a>()</code><br />
			Gets the name of the header template to load to format the report results, e.g., user_framework/common_bulk_hdr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getImageTemplate">getImageTemplate</a>()</code><br />
			Gets the name of the image template to load to format the report results, e.g., user_framework/cs_chart_common_img.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getLabelTemplate">getLabelTemplate</a>()</code><br />
			Gets the name of the label template to load to format column baed report results, e.g., user_framework/custom_label.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getMainTemplate">getMainTemplate</a>()</code><br />
			Gets the name of the main template to load to format the report results, e.g., user_framework/column_rpt.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getName">getName</a>()</code><br />
			Gets the name of the sub report, in the configuration example above this is the data in the NAME tag.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getRelation">getRelation</a>()</code><br />
			Gets the name of the relation this sub report is following.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getSortOrder">getSortOrder</a>()</code><br />
			Gets the sort order string that determines how the subreport items will be sorted an example
			sort order string is problem_number:intb:A.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getSpanAttributeTemplate">getSpanAttributeTemplate</a>()</code><br />
			Gets the name of the span attribute template to load, e.g., user_framework/custom_span_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getXmlContent">getXmlContent</a>()</code><br />
			Gets the XML data to pass to a custom WSLET.
		</td>
	</tr>
	
	
	
	<!-- Setters -->
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setAttributes">setAttributes</a>(scalar attributes)</code><br />
			Sets the attribute string that determines which attributes will be looked up for the subreport an example
			attribute string is problem_number:0:false|crstatus:1:false|problem_synopsis:2:false.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setAttributeTemplate">setAttributeTemplate</a>(scalar attributeTemplate)</code><br />
			Sets the name of the attribute template to load to format the report results, e.g., user_framework/column_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setAutoAttributeTemplate">setAutoAttributeTemplate</a>(scalar autoAttributeTemplate)</code><br />
			Sets the name of the auto attribute template to load to format the report results for auto-generated reports,
			e.g., user_framework/custom_auto_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setAutoLabelTemplate">setAutoLabelTemplate</a>(scalar autoLabelTemplate)</code><br />
			Sets the name of the auto label template to load to format the report results for auto-generated reports,
			e.g., user_framework/custom_auto_label.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setCustomWslet">setCustomWslet</a>(scalar customTemplate)</code><br />
			Sets the name of the custom WSLET to run for this subreport an example is CSChartMultipleDateTrend.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setDefinitionType">setDefinitionType</a>(scalar definitionType)</code><br />
			Sets the definition type for this sub report, either PROBLEM_DEF, TASK_DEF or OBJECT_DEF.
		</td>
	</tr>	
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setFooterTemplate">setFooterTemplate</a>(scalar footerTemplate)</code><br />
			Sets the name of the footer template to load, e.g., user_framework/common_bulk_ftr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setGroupBy">setGroupBy</a>(scalar groupBy)</code><br />
			Sets the groups that have the same attribute name as follows: [GROUP_BY]attribute_name|sort_type:sort_direction[/GROUP_BY].
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setGroupTemplate">setGroupTemplate</a>(scalar groupTemplate)</code><br />
			Sets the name of the group template to load.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setHeaderTemplate">setHeaderTemplate</a>(scalar headerTemplate)</code><br />
			Sets the name of the header template to load to format the report results, e.g., user_framework/common_bulk_hdr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setImageTemplate">setImageTemplate</a>(scalar imageTemplate)</code><br />
			Sets the name of the image template to load to format the report results, e.g., user_framework/cs_chart_common_img.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setLabelTemplate">setLabelTemplate</a>(scalar labelTemplate)</code><br />
			Sets the name of the label template to load to format column baed report results, e.g., user_framework/custom_label.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setMainTemplate">setMainTemplate</a>(scalar mainTemplate)</code><br />
			Sets the name of the main template to load to format the report results, e.g., user_framework/column_rpt.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setName">setName</a>(scalar subReportName)</code><br />
			Sets the name of the sub report, the name is required as it links the report definition to the sub report definition.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setRelation">setRelation</a>(scalar relationName)</code><br />
			Sets the name of the relation the sub report is following, for example associated_task.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setSortOrder">setSortOrder</a>(scalar sortOrder)</code><br />
			Gets the sort order string that determines how the subreport items will be sorted an example
			sort order string is problem_number:intb:A.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setSpanAttributeTemplate">setSpanAttributeTemplate</a>(scalar spanAttributeTemplate)</code><br />
			Sets the name of the span attribute template to load when an attribute should span an entire row, e.g., user_framework/custom_span_attr.html.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setXmlContent">setXmlContent</a>(scalar xmContent)</code><br />
			Sets the XML data to send to a custom WSLET.
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
	<a href="getAttributes"></a>

=end html

=item B<getAttributes>

Gets the delimited list of attributes to include in the report. The general syntax is 
attribute_name:sort_position:span_option where sort_postion and span_option are optional.

 Returns: scalar
	The list of attributes as a string.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getAttributeTemplate"></a>

=end html

=item B<getAttributeTemplate>

Gets the name of the attribute template to load to format the report results, e.g., user_framework/column_attr.html. 
An attribute template is repeated for each item that is found in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the attribute template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getAutoAttributeTemplate"></a>

=end html

=item B<getAutoAttributeTemplate>

Gets the name of the auto attribute template to load to format auto-generated report results, e.g., user_framework/custom_auto_attr.html. 
An auto attribute template is repeated for each item that is found in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the auto attribute template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getAutoLabelTemplate"></a>

=end html

=item B<getAutoLabelTemplate>

Gets the name of the auto label template to load to format auto-generated report results, e.g., user_framework/custom_auto_label.html. 
An auto label template enables you to label a column that contains multiple values instead of formatting the report with
label and value pairs. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the auto attribute template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getCustomWslet"></a>

=end html

=item B<getCustomWslet>

Gets the name of the custom WSLET to run for this subreport.

 Returns: scalar
	The name of the custom WSLET to execute.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getDefinitionType"></a>

=end html

=item B<getDefinitionType>

Gets the definition type for this sub report, either PROBLEM_DEF, TASK_DEF or OBJECT_DEF.

 Returns: scalar
	The definition type for the report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getFooterTemplate"></a>

=end html

=item B<getFooterTemplate>

Gets the name of the footer template to load, e.g., user_framework/common_bulk_ftr.html. 
A footer template is added one time at the bottom of the report. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the footer template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getGroupBy"></a>

=end html

=item B<getGroupBy>

Gets the groups that have the same attribute name as follows: attribute_name|sort_type:sort_direction, or just
an attribute name.

 Returns: scalar
	The attribute grouping string.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getGroupTemplate"></a>

=end html

=item B<getGroupTemplate>

Gets the name of the group template to load. The grouping template allows for charting based on the grouped items. 
The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the group template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getHeaderTemplate"></a>

=end html

=item B<getHeaderTemplate>

Gets the name of the header template to load to format the report results, e.g., user_framework/common_bulk_hdr.html. 
A header template normally contains all the information that is displayed at the very top of a report. The template
path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the header template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getImageTemplate"></a>

=end html

=item B<getImageTemplate>

Gets the name of the image template to include on the report results, e.g., user_framework/cs_chart_common_img.html. 
An image template normally contains an image or a chart and is only included once in the report output. The template
path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the image template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getLabelTemplate"></a>

=end html

=item B<getLabelTemplate>

Gets the name of the label template for column-formatted reports. This tempalte enables you to label
a column that contains muitliple values instead of formatting the report with label and value pairs,
e.g., user_framework/custom_label.html. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the main template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getMainTemplate"></a>

=end html

=item B<getMainTemplate>

Gets the name of the main template to load to format the report results, e.g., user_framework/column_rpt.html. The template
path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the main template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getName"></a>

=end html

=item B<getName>

Gets the name of the sub report, this name will never be displayed in the interface but it links the CCM_REPORT definition
to the CCM_PROBLEM, CCM_TASK or CCM_OBJECT definition and thus is required.

 Returns: scalar
	The name of the sub report.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getRelation"></a>

=end html

=item B<getRelation>

Gets the name of the relationship that the sub report is following, for example associated_task to find the associated tasks
of a change request.

 Returns: scalar
	The name of the relation.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getSortOrder"></a>

=end html

=item B<getSortOrder>

Gets the sort order string that determines how the subreport items will be sorted an example 
sort order string is problem_number:intb:A.

 Returns: scalar
	The list sort order attributes as a string.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getSpanAttributeTemplate"></a>

=end html

=item B<getSpanAttributeTemplate>

Gets the name of the span attribute template to load to format the report results, e.g., user_framework/custom_span_attr.html. 
A span attribute template is repeated for each item that is found that spans a row in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Returns: scalar
	The name of the span attribute template.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getXmlContent"></a>

=end html

=item B<getXmlContent>

Gets the XML data to pass to a custom WSLET.

 Returns: scalar
	The XML data for a custom WSLET.

=cut

##############################################################################

=begin html

	<hr>
	<a href="setAttributes"></a>

=end html

=item B<setAttributes>

Sets the delimited list of attributes to include in the report. The general syntax is 
attribute_name:sort_position:span_option where sort_postion and span_option are optional.

 Parameters:
	scalar: The delimited list of attributes to set.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setAttributes("problem_number:0:false|crstatus:1:false|problem_synopsis:2:false");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setAttributeTemplate"></a>

=end html

=item B<setAttributeTemplate>

Sets the name of the attribute template to load to format the report results, e.g., user_framework/column_attr.html. 
An attribute template is repeated for each item that is found in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the attribute template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setAttributeTemplate("user_framework/column_attr.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setAutoAttributeTemplate"></a>

=end html

=item B<setAutoAttributeTemplate>

Sets the name of the auto label template to load to format auto-generated report results, e.g., user_framework/custom_auto_label.html. 
An auto label template enables you to label a column that contains multiple values instead of formatting the report with
label and value pairs. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the auto attribute template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setAutoAttributeTemplate("user_framework/custom_auto_label.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setAutoLabelTemplate"></a>

=end html

=item B<setAutoLabelTemplate>

Sets the name of the auto attribute template to load to format auto-generated report results, e.g., user_framework/custom_auto_attr.html. 
An auto attribute template is repeated for each item that is found in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the auto label template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setAutoLabelTemplate("user_framework/custom_auto_attr.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setCustomWslet"></a>

=end html

=item B<setCustomWslet>

Sets the name of the custom WSLET to run for this subreport an example is CSChartMultipleDateTrend.

 Parameters:
	scalar: The name of the custom WSLET to run for this subreport.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setCustomWslet("CSChartMultipleDateTrend");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setDefinitionType"></a>

=end html

=item B<setDefinitionType>

Gets the definition type for this sub report, either PROBLEM_DEF, TASK_DEF or OBJECT_DEF.

 Parameters:
	scalar: The definition type for the report.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setDefinitionType("PROBLEM_DEF");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setFooterTemplate"></a>

=end html

=item B<setFooterTemplate>

Sets the name of the footer template to load, e.g., user_framework/common_bulk_ftr.html. 
A footer template is added one time at the bottom of the report. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the footer template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setFooterTemplate("user_framework/common_bulk_ftr.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setGroupBy"></a>

=end html

=item B<setGroupBy>

Sets the groups that have the same attribute name as follows: attribute_name|sort_type:sort_direction, or just
an attribute name.

 Parameters:
	scalar: The group by attribute string.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setGroupBy("assigner");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setGroupTemplate"></a>

=end html

=item B<setGroupTemplate>

Sets the name of the group template to load. The grouping template allows for charting based on the grouped items. 
The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the group template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setGroupTemplate("user_framework/groupTemplate.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setHeaderTemplate"></a>

=end html

=item B<setHeaderTemplate>

Sets the name of the header template to load to format the report results, e.g., user_framework/common_bulk_hdr.html. 
A header template normally contains all the information that is displayed at the very top of a report. The template
path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the header template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setHeaderTemplate("user_framework/common_bulk_hdr.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setImageTemplate"></a>

=end html

=item B<setImageTemplate>

Sets the name of the image template to include on the report results, e.g., user_framework/cs_chart_common_img.html. 
An image template normally contains an image or a chart and is only included once in the report output. The template
path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the image template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setImageTemplate("user_framework/cs_chart_common_img.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setLabelTemplate"></a>

=end html

=item B<setLabelTemplate>

Sets the name of the label template for column-formatted reports. This tempalte enables you to label
a column that contains muitliple values instead of formatting the report with label and value pairs,
e.g., user_framework/custom_label.html. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the label template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setLabelTemplate("wsconfig/templates/pt/reports");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setMainTemplate"></a>

=end html

=item B<setMainTemplate>

Sets the name of the main template to load to format the report results, e.g., user_framework/column_rpt.html. The template
path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the main template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setMainTemplate("user_framework/column_rpt.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setName"></a>

=end html

=item B<setName>

Sets the name of the sub report, this name will never be displayed in the interface but it links the CCM_REPORT definition
to the CCM_PROBLEM, CCM_TASK or CCM_OBJECT definition.

 Parameters:
	scalar: The name this sub report shall have upon creation.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setName("my sub report");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setRelation"></a>

=end html

=item B<setRelation>

Sets the name of the relation the sub report is following, for example associated_task. 

 Parameters:
	scalar: The name of the relationship that this subreport should look up..

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setRelation("associated_task");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setSortOrder"></a>

=end html

=item B<setSortOrder>

Gets the sort order string that determines how the subreport items will be sorted an example
sort order string is problem_number:intb:A.

 Parameters:
	scalar: The delimited list of sort order attributes to set.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setSortOrder("problem_number:intb:A");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setSpanAttributeTemplate"></a>

=end html

=item B<setSpanAttributeTemplate>

Sets the name of the span attribute template to load to format the report results, e.g., user_framework/custom_span_attr.html. 
A span attribute template is repeated for each item that is found that spans a row in the report and prints information about the attributes
for an item. The template path begins with "wsconfig/templates/pt/reports".

 Parameters:
	scalar: The name of the attribute template to load.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setSpanAttributeTemplate("user_framework/custom_span_attr.html");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setXmlContent"></a>

=end html

=item B<setXmlContent>

Sets the XML data to send to a custom WSLET.

 Parameters:
	scalar: The XML content for a CUSTOM WSLET.

 Example:
	
	my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	my @subreports = $reportEntry->getSubReports();
	my $firstSubReport = $subreports[0];
	$firstSubReport->setCustomWslet(XML DATA);

=cut

##############################################################################
