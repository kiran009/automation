#!/usr/bin/perl

package ChangeSynergy::QueryLookupPlugin;

## This package is used for looking up the attribute value on a set of objects specified by
## a given query. For example it would be possible to lookup the value of a product manager
## base on a query like "object_type='Lead' and product='Product'"

use ChangeSynergy::csapi;

my $message='';
my $local_dict;

sub initPlugin
{
	$args = shift;
    $local_dict = $$args[0];
    
	return 1;
}

sub Methods
{
	my @methods = ('queryLookup', 'queryLookupString', 'queryLookupUserEmail', 'queryLookupUserEmailString');

	return @methods;
}

# This returns an array of values for the attribute given based on the query
# Not this currently only works for cvtype='problem' objects
# Inputs:
#	attr_name: The Name of the attribute to lookup
# 	no_match_val: The value to return if there is no matches
#	query: The query to execute
# Returns:
#	@values: An array of values. This will contain the no_match_value if no matching records found

sub queryLookup
{
	# Parse input parameters
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $query = shift;

	my @values = ( );

	my $attr_list = "problem_number|" . $attr_name;
    
    my ($csapi, $csuser) = &main::getConnection();

	print "QueryLookupPlugin --> Running queryLookup\n";
	print "QueryLookupPlugin --> query = $query\n";

	# Replace the $xxx attributes with their values
	$query =~ s/\$(\w+)/$local_dict->{$1}/eg;
	
	# Replace the [ with ( and ] with ). This is required because the 
	# BasicTemplate is mangling parameters
	$query =~ s/\[/\(/g;
	$query =~ s/\]/\)/g;

	print "QueryLookupPlugin --> updated query = $query\n";

	# Run the query
	my $data = $csapi->QueryData($csuser, "Basic Summary", $query, undef, undef, undef);
	my $size = $data->getDataSize(); 
	
    if ($size == 0)
	{
    	push @values, $no_match_val;
		print "QueryLookupPlugin --> No matches found\n";
    
		return @values;
    }
    
	for (my $i = 0; $i < $size; $i++)
	{
		# Load the object then get the value
		my $object = $data->getDataObject($i);
		my $problem_number = $object->getDataObjectByName("problem_number")->getValue();
		
		eval
		{
			$object = $csapi->GetCRData($csuser, $problem_number, $attr_list);	
		};

		if ($@)
		{
			next;
		}    
		
    	# get the value
    	eval
		{
	    	my $value = $object->getDataObjectByName($attr_name)->getValue();	
			$value =~ s/\s*$//;
	    	push @values, $value;
    	};

	}

	return @values;    
}

sub queryLookupString
{
	# Parse input parameters
	my $delimiter = shift;
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $query = shift;

	my @values = &queryLookup($attr_name, $no_match_val,$query);
	print "QueryLookupPlugin->queryLookupString: values: @values\n";
	my $results = join $delimiter, @values;	
	print "QueryLookupPlugin->queryLookupString: results: $results\n";
		
	return "$results";
}

sub queryLookupUserEmail
{
	#Parse input parameters
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $query = shift;

	my @values = &queryLookup($attr_name, $no_match_val, $query);
	print "QueryLookupPlugin->queryLookupUserEmail: values: @values\n";
	my @addresses = &main::getEmailAddresses(@values);
	print "QueryLookupPlugin->queryLookupUserEmail return: @addresses\n";
		
	return @addresses;
}

sub queryLookupUserEmailString
{
	# Parse input parameters
	my $delimiter = shift;
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $query = shift;

	my @values = &queryLookup($attr_name, $no_match_val,$query);
	print "QueryLookupPlugin->queryLookupUserEmailString: values: @values\n";
	my $addresses = &main::getEmailAddressesString($delimiter, @values);
	print "QueryLookupPlugin->queryLookupUserEmailString return: $addresses\n";
		
	return "$addresses";
}

1;

