package ChangeSynergy::relationshipPlugin;


sub initPlugin
{
	print "Initializing the relationshipPlugin ...\n";

	return 1;
}

sub Methods
{
	my @methods = ('getAttributeOnRelatedCR','getAttributeOnRelatedCRs');

	return @methods;
}

sub getAttributeOnRelatedCR
{
	my $crid = shift;
    my $fourPartName = &main::buildFourPartName($crid);
    my $relationshipName = shift;
    my $attributeName = shift;
    
    my ($csapi, $csuser) = &main::getConnection();

    #Create a query string and then call the api to get a data report.
    my $queryString = $relationshipName . "('" . $fourPartName . "')";
    my $data = $csapi->QueryData($csuser, "Basic Summary", $queryString, undef, undef, undef);
	my $size = $data->getDataSize(); 
        
    unless ($size > 0) 
    {
        return "";
    }

    my $relatedCR = $data->getDataObject(0);
    my $relCRid = $relatedCR->getDataObjectByName("problem_number")->getValue();
    $relatedCR = &loadCRAttribute($csapi, $csuser, $relCRid, "problem_number|name|". $attributeName);
    
    return &getCRAttribute($relatedCR, $attributeName);
}


sub getAttributeOnRelatedCRs
{
	my $crid = shift;
    my $fourPartName = &main::buildFourPartName($crid);
    my $relationshipName = shift;
    my $attributeName = shift;
    
    my ($csapi, $csuser) = &main::getConnection();

    #Create a query string and then call the api to get a data report.
    my $queryString = $relationshipName . "('" . $fourPartName . "')";
    
    my $data = $csapi->QueryData($csuser, "Basic Summary", $queryString, undef, undef, undef);
    print "$queryString\n";
    
    my $size = $data->getDataSize(); 
        
    unless ($size > 0) 
    {
        return "";
    }

    my $return = "";
	
	eval 
	{
		#For each top level csapi_cobject_vector_postion.
		for(my $i = 0; $i < $data->getDataSize(); $i++)
		{
			#Get the object vector
			my $relatedCR = $data->getDataObject($i);
			my $relCRid = $relatedCR->getDataObjectByName("problem_number")->getValue();
			$relatedCR = &loadCRAttribute($csapi, $csuser, $relCRid, "problem_number|name|". $attributeName);
    		my $value = &getCRAttribute($relatedCR, $attributeName);
    		print "Found $value\n";
    		
    		$return = $return . $value . " ";
    	}
	};

	if ($@)
	{
		return undef;
	}
	
    return $return;
}


sub getCRAttribute
{
	my $cr = shift;
	my $attribute = shift;
	my $value = '';
    
    eval
	{
	    $value = $cr->getDataObjectByName($attribute)->getValue();	
    };
    
	return $value;
}

sub loadCRAttribute
{
	my $csapi = shift;
	my $user = shift;
	my $problem_number = shift;
	my $field_list = shift;
	my $problem;
	
	eval
	{
		$problem = $csapi->GetCRData($user, $problem_number, $field_list);	
	};

	if ($@)
	{
		return undef;
	}
	
	return $problem;
}

