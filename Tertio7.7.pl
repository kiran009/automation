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
my $javabinarylist="$Bin/javabinaries.fp";
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
my $mr_number;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
my $mailto='kiran.daadhi@evolving.com Srikanth.Bhaskar@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
	fetch_tasks();
	#fetch_readme();	
	reconfigure_dev_proj_and_compile();
	#reconfigure_del_project();
	delivery();
	send_email("Tertio $mr_number build is completed and available @ $destdir, logs are attached","/tmp/logs.zip");
	#move_cr_status();
	#ccm_stop();	
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
    print "Patch Number is: $patch_number \n";
    
    if($patch_readme =~ /N\/A/)
    {
    	print "The following CR doesn't have a README \n";
    }
    else
    {
    	open OP,"+> $patch_number\_README.txt";
    	print OP $patch_readme;
    	close OP;
    	`dos2unix $patch_number\_README.txt 2>&1 1>/dev/null`;
    	@PatchFiles=`sed -n '/AFFECTS/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTS' | sed '/^\$/d'`;
    	print "Binary file list is: @PatchFiles \n";
        chomp(@PatchFiles);
        print OP "@PatchFiles \n";            	
    }		
}

sub fetch_tasks()
{
	#open OP,">> $binarylist";
	foreach my $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);
		print "List of Tasks associated with CR $cr => $task_number \n";
		#@objectlist=`$CCM query "is_associated_object_of('$cr:task:probtrac')"`;
		#print "List of objects associated with CR $cr are: @objectlist \n";
		$tasklist=join(",",@tasks);
		fetch_mrnumber($cr);		
		fetch_readme($cr);
	}
	#close OP;
	#print "Consolidated tasklist for the patch is: $tasklist\n";
	open OP, "<$binarylist";
	@file_list=<OP>;
	print "Consolidate deliverable list for the patch is: @file_list \n";
	close OP;
}
sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	print "***************CCM WorkArea is: $workarea***************\n";
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>/tmp/task_addition_$devprojectname.log`;	
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
	#`/usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$devprojectname.log`;
	#open OP, "< /tmp/gmake_$devprojectname.log";
	#@op=<OP>;
	#close OP;		
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
	
}

sub delivery()
{
  print "Create tar bundle for the platform \n";
  if($devprojectname =~ /Java/)
  {
	$delroot="$dbbmloc/$devprojectname/Provident_Delivery";
  }
  else
  {  	
  	$delroot="$dbbmloc/$devprojectname/Provident_Dev/";
  	print "Delivery root is: $delroot \n";
  }
  
  mkdir("$destdir",0755);
  #open OP ,"< "
  foreach $file(@file_list)
  {
  	$file=~ s/\$PROVHOME//g;
  	$file=~ s/^\s+|\s+$//g;
  	@list=split(/\s+/,$file);
  	$src=@list[1];
  	$dest=@list[3];  	
  	$dirname=dirname($dest);
  	print "Source is: $src and Destination is: $dest \n";
  	mkdir("$destdir/$dirname",0755);
  	copy("$delroot/$src","$destdir/$dest") or die("Couldn't able to copy $file \n");
  	chdir($destdir);
  	`tar uzvf $mr_number\.tar\.gz $destdir/$dest`;
  }
  `zip -r /tmp/logs.zip /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`; 
  #copy("$mr_number\.tar\.gz", "/data/releases/tertio/7.7.0/patches/RHEL6/NotTested/") or die("Couldn't copy the tar file");
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