#!/usr/bin/perl
# Tertio 7.7 Build Script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
#$ENV{'umask'}=002;
$database="/data/ccmdb/provident/";
$dbbmloc="/data/ccmbm/provident/";
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
#my @CRS;
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
my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
#my $mailto='kiran.daadhi@evolving.com';
my %hash;
my $readmeIssue;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
	fetch_tasks();
	#reconfigure_dev_proj_and_compile();
	#`zip -r /tmp/logs.zip /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`;
	#send_email('Tertio 7.6 Build','/tmp/logs.zip');
	#reconfigure_del_project();
	#delivery();
	#send_email();
	#create_childcrs();
	#move_cr_status();
	ccm_stop();	
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
	}
	print "List of tasks to be included are: $tasklist\n";
}
sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	print "***************CCM WorkArea is: $workarea***************\n";
	#`$CCM folder -modify -add_task @tasks 2>&1 1>/dev/null`;
	#`$CCM reconfigure -rs -r -p $devprojectname`;
	umask 002;
	print("The current umask is: ", umask(), "\n");
	$devprojectname=~ s/^\s+|\s+$//g;
	print "Dev project name is :$devprojectname\n";
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>/tmp/reconfigure_devproject_$devprojectname.log`;
	open OP, "< /tmp/reconfigure_devproject_$devprojectname.log";
	@op=<OP>;
	close OP;
	#print "Contents of gmake.log for development project is: @op \n";	
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		print "Perfect \n";
	    chdir "$workarea/Provident_Dev";
	}
	`/usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$devprojectname.log`;
	open OP, "< /tmp/gmake_$devprojectname.log";
	@op=<OP>;
	close OP;
	#print "Contents of gmake.log for development project is: @op \n";	
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
	#$ENV{'PATH'}="$workarea/Provident_Delivery/:./:$ENV{'PATH'}";
	#`/usr/bin/gmake clean deliver 2>&1 1>/tmp/gmake_$delprojectname.log`;
	#open OP, "< /tmp/gmake_$delprojectname.log";
	#@op=<OP>;
	#close OP;
	#print "Contents of gmake.log for delivery project is: @op \n";
	`zip -r /tmp/logs.zip /tmp/reconfigure_$delprojectname.log /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`;
	send_email('Tertio 7.6 Build','/tmp/logs.zip');
}

sub delivery()
{
  print "Delivering binaries for the platform";
  if($delprojectname =~ /Java/)
  {
	$delroot="$dbbmloc/$delprojectname/Provident_Delivery";
  }
  else
  {
  	$delroot="$dbbmloc/$delprojectname/Provident_Delivery/build";
  }
  copy("$delroot/tertio.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy tertio.tar \n");
  copy("$delroot/Version.txt","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy tertio.txt \n");
  copy("$delroot/CoreZSLPackage_1-0-0.Z","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy CoreZSLPackage_1-0-0.Z \n");
  copy("$delroot/gpsretrieve","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy gpsretrieve \n");
  copy("$delroot/adk.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy adk.tar \n");
  copy("$delroot/testbench.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy testbench.tar \n");
  $adkdir="/u/kkdaadhi/tertio_adk/";
  mkdir("$adkdir/7.7.0_build11",0755);
  chdir("$adkdir/7.7.0_build11");
 `tar -xf /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/adk.tar`;
 `mv tertio-adk-7.7.0/* ../`;
 `rm -rf tertio-adk-7.7.0`;
 send_email("Tertio 7.7 build","/tmp/gmake_$delprojectname.log");
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
