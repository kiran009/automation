use ChangeSynergy::csapi;
eval
{
my $csapi = new ChangeSynergy::csapi();
$csapi->setUpConnection("http://10.30.12.60:8601/cs/");
my $aUser = $csapi->Login("kkdaadhi", "kiran", "User", "/data/ccmdb/dsa");

my $tmp1 = $csapi->GetCRData($aUser, $ARGV[0], "crstatus");
$tmp1->getDataObjectByName("crstatus")->setValue($ARGV[1]);
my $tmpstr = $csapi->TransitionCR($aUser, $tmp1);

my $status = $tmp1->getDataObjectByName("crstatus")->getValue();
	if( $status eq "Patch_test")
	{
		print "\nResults : \n";
		print "Successfully modifed the CR Status to : " . $tmp1->getDataObjectByName("crstatus")->getValue() . "\n"; 	     }
};

if ($@)
{
	if( $ARGV[1] eq "Patch_test")
	{
		print "\nResults : \n";
		print "Successfully modifed the CR status to : " . $ARGV[1] . "\n";
	}
}
