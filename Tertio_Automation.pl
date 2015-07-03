#!/usr/bin/perl
# Tertio 7.7 Build Script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $binarylist="$Bin/file_list.txt";
$result=GetOptions("devproject=s"=>\$devprojectname,"delproject=s"=>\$delprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname, delprojectname \n";
	exit;
}
if(!$devprojectname)
{
	print "Projectname is mandatory \n";
	exit;
}
if(!$folder)
{
	print "No folder is mentioned to add the TASKS corresponding to the above CRs, proceeding with existing one's\n";
}
if(!$crs)
{
	print "No extra CRs are provided for this build, proceeding with already added one's \n";	
}
my @PatchFiles;
my @files;
my $patch_number;
my $problem_number;
my @crs;
my @tasks;
my $tasklist;
my $CRlist;
my $PatchReleaseVersion;
my $projectName;
my $platformlist;
my $hostname;
my @platforms;
my $workarea;
my @op;
my @file_list;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
my $mailto='kiran.daadhi@evolving.com';
my %hash;
my $readmeIssue;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
	fetch_tasks();
	#fetch_readme();
	#`zip -r /tmp/logs.zip /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`;
	#send_email('Tertio 7.7.0.1 Build','/tmp/logs.zip');
	reconfigure_dev_proj_and_compile();
	reconfigure_del_project();
	delivery();
	#send_email();
	#create_childcrs();
	#move_cr_status();
	ccm_stop();	
}
sub fetch_mrnumber($)
{
	my ($crnumber)=@_;
	$crnumber=~ s/^\s+|\s+$//g;
	print "CRnumber is: $crnumber \n";
	($mr_number)=`$CCM query "cvtype='problem' and problem_number='$crnumber'" -u -f "%MRnumber"`;
	$mr_number=~ s/^\s+|\s+$//g;		
	print "MRnumber for the patch is: $mr_number\n";
}
sub fetch_readme($)
{
	my ($crnumber)=@_;
	`$CCM query "cvtype=\'problem\' and problem_number=\'$crnumber\'"`;
    $patch_number=`$CCM query -u -f %patch_number`;
    $patch_readme=`$CCM query -u -f %patch_readme`;
    $patch_number=~ s/^\s+|\s+$//g;
    open OP,"+> $patch_number\_README.txt";
    print OP $patch_readme;
    close OP;
    `dos2unix $patch_number\_README.txt 2>&1 1>/dev/null`;		
}

sub fetch_tasks()
{
	foreach my $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);
		$tasklist=join(",",@tasks);
		fetch_mrnumber($cr);
		#fetch_readme($cr);
	}
	print "List of tasks to be included are: $tasklist\n";
}
sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	print "***************CCM WorkArea is: $workarea***************\n";
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>/dev/null`;	
	umask 002;
	$devprojectname=~ s/^\s+|\s+$//g;
	print "Dev project name is :$devprojectname\n";
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>/tmp/reconfigure_devproject_$devprojectname.log`;
	open OP, "< /tmp/reconfigure_devproject_$devprojectname.log";
	@op=<OP>;
	close OP;
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		chdir "$workarea/Provident_Dev";
	}
	`/usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$devprojectname.log`;
	open OP, "< /tmp/gmake_$devprojectname.log";
	@op=<OP>;
	close OP;		
}

sub reconfigure_del_project()
{
	print "*************** Delivery devprojectname is: $delprojectname  ***************\n";
	$ccmworkarea=`$CCM wa -show -recurse $delprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	print "***************CCM WorkArea of Delivery Project is: $workarea ***************\n";	
	`$CCM reconfigure -rs -r -p $delprojectname 2>&1 1>/tmp/reconfigure_$delprojectname.log`;
	open OP, "< /tmp/reconfigure_$delprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for delivery project is: @op \n";
	$delprojectname=~ s/^\s+|\s+$//g;
	if($delprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
	    chdir "$workarea/Provident_Delivery";
	}
	# Execute gmake clean delivery
	$ENV{'PATH'}="$workarea/Provident_Delivery/:./:$ENV{'PATH'}";
	`/usr/bin/gmake clean deliver 2>&1 1>/tmp/gmake_$delprojectname.log`;
	open OP, "< /tmp/gmake_$delprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for delivery project is: @op \n";
	`zip -r /tmp/logs.zip /tmp/reconfigure_$delprojectname.log /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`;
	send_email("Tertio 7.7.0.1 Build","/tmp/logs.zip");
}

sub delivery()
{
  open OP, "< $binarylist";
  @file_list=<OP>;
  print "Filelist is: @file_list \n";	
  print "Create tar bundle for the platform";
  if($delprojectname =~ /Java/)
  {
	$delroot="$dbbmloc/$delprojectname/Provident_Delivery";
  }
  else
  {
  	$delroot="$dbbmloc/$delprojectname/Provident_Delivery/build";
  }
  $destdir="/u/kkdaadhi/Tertio_Deliverable";
  foreach $file(@file_list)
  {
  	$file=~ s/^\s+|\s+$//g;
  	copy("$delroot/$file","$destdir") or die("Couldn't able to copy $file \n");
  #copy("$delroot/Version.txt","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy tertio.txt \n");
  #copy("$delroot/CoreZSLPackage_1-0-0.Z","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy CoreZSLPackage_1-0-0.Z \n");
  #copy("$delroot/gpsretrieve","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy gpsretrieve \n");
  #copy("$delroot/adk.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy adk.tar \n");
  #copy("$delroot/testbench.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy testbench.tar \n");
  #$adkdir="/u/kkdaadhi/tertio_adk/";
  #mkdir("$adkdir/7.7.0_build11",0755);
  #chdir("$adkdir/7.7.0_build11");
 #`tar -xf /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/adk.tar`;
 #`mv tertio-adk-7.7.0/* ../`;
 #`rm -rf tertio-adk-7.7.0`;
 #send_email("Tertio 7.7 build","/tmp/gmake_$delprojectname.log");
}
}

sub start_ccm()
{
	print "In Start CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm start -d $database -m -q -r build_mgr -h ccmuk1 -nogui |");
	$ENV{'CCM_ADDR'}=<ccm_addr>;
	close(ccm_addr);
}

sub ccm_stop()
{
	print "In Stop CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm stop |");
	close(ccm_addr);
}
sub send_email()
{
	($subject,$attachment)=@_;
	print "\$attachment value is: $attachment \n";
	system("/usr/bin/mutt -s '$subject' $mailto -a $attachment < /dev/null");
}
main();