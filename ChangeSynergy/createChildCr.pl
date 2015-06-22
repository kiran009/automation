use ChangeSynergy::csapi;
use cs_lib;
eval
{
#Create a new TriggerParser object
#my $trigger = new ChangeSynergy::TriggerParser($triggerFile);

#Create new csapi object
#my $parentCR   = $trigger->get_object_id();
my $csapi = new ChangeSynergy::csapi();
#setup the connection
$csapi->setUpConnection("http://10.30.12.60:8603/cs/");

#create a user objectpi = new ChangeSynergy::csapi();

#my $user = new ChangeSynergy::apiUser($trigger->get_user(), "password", $trigger->get_role(),
#					$trigger->get_token(), $trigger->get_database()_);
my $aUser = $csapi->Login("prathish", "Welcome07!", "ccm_admin", "\\\\ccmuk1\\ccmdb\\peg_support");

#Do a copy
my $submitForm = $csapi->CopyCRData($aUser, "35", "COPY_child_cr2new_child");

#For each objectData on the submit form.
for(my $i = 0; $i < $submitForm->getDataSize; $i++)
{
	#Is the object required?
	if($submitForm->getDataObject($i)->getRequired())
	{
		#see if the object is already set with a value.
		if(length($submitForm->getDataObject($i)->getValue()) == 0)
		{
			$submitForm->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
		}	
	}
	
	#If the value is inherited make sure that its modify value is set
	#to true so that it will get submitted. 
	if($submitForm->getDataObject($i)->getInherited())
	{
		$submitForm->getDataObject($i)->setIsModified("true");
	}
}

		$submitForm->getDataObjectByName("problem_synopsis")->setValue("I submitted this through the csapi");
		$submitForm->getDataObjectByName("problem_description")->setValue("Yes, isn't this great!!!!");
		$submitForm->getDataObjectByName("severity")->setValue("Minor");
		$submitForm->getDataObjectByName("submitter")->setValue("prathish");
		$submitForm->getDataObjectByName("request_type")->setValue("Merge Forward");


#set the crstatus to the correct state.
$submitForm->getDataObjectByName("crstatus")->setValue($submitForm->getTransitionLink(0)->getToState());	

#Do the submit of the CR and associate it to its parent CR
my $tmpStr = $csapi->SubmitCRAssocCR($aUser, $submitForm, $submitForm->getTransitionLink(0)->getRelation(), "35");
};

if ($@)
{
print $@;
}
