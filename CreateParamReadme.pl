#!/usr/bin/perl
# Tertio 7.6 CreateReadme script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Sys::Hostname;

#/************ Setting Environment Variables *******************/
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
if($hostname !~ /pesthp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
my $result=GetOptions("folderset=s"=>\$folderset,"productname=s"=>\$productname,"readmename=s"=>\$readmename,"prereq=s"=>\$prereq,"supersed=s"=>\$supersed,"buildnumber=s"=>\$build_number,"affects=s"=>\$affects);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$folderset)
{
	print "Folderset needs to be provided\n";
	exit;
}
if(!$readmename)
{
	print "README name should be mentioned\n";
	exit;
}
if(!$prereq)
{
	print "Please mention prerequisite for the patch\n";
	exit;
}
if(!$supersed)
{
	print "Please mention superseding information for the patch\n";
	exit;
}
if(!$affects)
{
	print "Please mention affects section for the patch\n";
	exit;
}
if(!$productname)
{
	print "Productname is mandatory\n";
	exit;
}
my @PatchFiles;
my @files;
my $cr;
my $problem_number;
my @crs;
my @tasks;
my $tasklist;
my $CRlist;
my $PatchReleaseVersion;
my $projectName;
my $platformlist;
my @op;
my @file_list;
my $mrnumber;
my @location_explode;
my %hash;
my $readmeIssue;
@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my @taskinfo;
my @synopsis;
my @summary;
my @crresolv;
my @formattsks;
my @binarylist;
my $dtformat="$year$months[$mon]$mday$hour$min";
my 	@location;
# /* Global Environment Variables ******* /
$productname=~ s/^\s+|\s+$//g;
@folder_set=split(/;/,$folderset);
sub main()
{
		start_ccm();
		listfolderTasks();
		ccm_stop();
}
sub listfolderTasks()
{
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open BN,"+>$Bin/build_number.txt";
	print BN $build_number;
	close BN;
	open  FILE, "+> $Bin/$readmename";
	print FILE "Maintenance Release : $productname $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "PRE-REQUISITE : $prereq\nSUPERSEDED : $supersed\n";
	foreach $set(@folder_set)
	{
		($foldername,$folder)=split(/:/,$set);
		$foldername=~ s/^\s+|\s+$//g;
		my @fold=split(/,/,$folder);
		undef @tasks_folder;
		undef @crs_folder;
		undef $task;
		undef $crinfo;
		undef @tasks;
		undef @uniqfolder;
		#undef $foldername;
		foreach $fld(@fold)
		{
			@tasks_folder=`$CCM folder -show tasks '$fld' -u -f "%task_number"`;
			foreach $task(@tasks_folder)
			{
				$task=~ s/^\s+|\s+$//g;
				@crs=`$CCM task -show cr $task \-u \-f "%problem_number"`;
				print "CR corresponding to task $task is: @crs\n";
				push(@crs_folder,@crs);
			}
			@uniqfolder = do { my %seen; grep { !$seen{$_}++ } @crs_folder};
        }
		open SYNOP,"+>$Bin/$foldername\_synopsis.txt";
		open SUMM,"+>$Bin/$foldername\_summary_readme.txt";
		open CRRESOLV, "+>$Bin/$foldername\_crresolv.txt";
		open TASKINF,"+>$Bin/$foldername\_taskinfo.txt";
		open PATCHBIN, "+>$Bin/$foldername\_patchbinarylist.txt";
		open FORMATTASKS,"+>$Bin/$foldername\_formattsks.txt";
		getTasksnReadme(@uniqfolder);
		close SUMM;
		close SYNOP;
		close CRRESOLV;
		close TASKINF;
		close PATCHBIN;
		close FORMATTASKS;
		print "CreateREADME: createReadme($foldername)";
		createReadme($foldername);
	}
	print FILE "\nTO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\n";
	print FILE "ISSUES: None";
	close FILE;
}

sub getTasksnReadme()
{
	undef @patchbinarylist;
	undef @PatchFiles;
	undef @tasks;
	undef @formattsks;
	undef $tasklist;
	my @crs=@_;
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		undef @task_numbers;
		#undef @tasks;
		@task_numbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		push(@tasks,@task_numbers);
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;
		foreach $task_number(@task_numbers)
		{
			$task_number=~ s/^\s+|\s+$//g;
			($task_synopsis)=`$CCM task -show info $task_number \-u \-format "%task_synopsis"`;
			($task_resolver)=`$CCM task -show info $task_number \-u \-format "%resolver"`;
			$task_synopsis=~ s/^\s+|\s+$//g;
			$task_resolver=~ s/^\s+|\s+$//g;
			if($synopsis !~ m/^BM/)
	        {
				print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
			}
		}
		if($synopsis !~ m/^BM/)
        {
			print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		    print SYNOP "CR$cr $synopsis\n";
        }
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
  	    $patch_readme=`$CCM query -u -f %patch_readme`;
        if(($patch_readme =~ /N\/A/) || (not defined $patch_readme))
        {
    		print "The following CR: $cr doesn't have a README \n";
        }
        else
        {
	 			if(($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4596/) || ($cr =~ /4606/) || ($cr =~ /4609/) || ($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4388/) || ($cr =~ /4491/) )
    	    	{
    		    	open OP1,"+> $Bin/$cr\_README.txt";
        			print OP1 $patch_readme;
        			close OP1;
    	    		`dos2unix $Bin/$cr\_README.txt 2>&1 1>/dev/null`;
        			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr\_README.txt  | sed '\$ d' | sed '/^\$/d' | grep -v 'AFFECTS'`;
        			push(@patchbinarylist,@PatchFiles);
    	    		$sumreadme=`sed -n '/AFFECTED:/,/ISSUES/ p' $cr\_README.txt  | sed '\$ d' | grep -v 'AFFECTED' | grep -v 'ISSUES' | sed '/^\$/d'`;
                    if($synopsis !~ m/^BM/)
                    {
    			         print SUMM "CR$cr - $sumreadme\n";
                    }
    		    }
    		    else
    		    {
     				open OP1,"+> $Bin/$cr\_README.txt";
    				print OP1 $patch_readme;
    				close OP1;
    				`dos2unix $Bin/$cr\_README.txt 2>&1 1>/dev/null`;
    				@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr\_README.txt  | sed '\$ d' | sed '/^\$/d' | grep -v 'AFFECTS'| sed '/^\$/d'`;
	     		 	push(@patchbinarylist,@PatchFiles);
      			    $sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $cr\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
                    if($synopsis !~ m/^BM/)
                    {
          			     print SUMM "CR$cr - $sumreadme\n";
                    }
    			}
    	}
		}
		my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
		print PATCHBIN @uniqbinlist;
		$tasklist=join(",",@tasks);
		@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
		print FORMATTASKS @formattsks;
}
sub createReadme()
{
	undef @formattsks;
	undef @fformattsks;
	undef @synopsis;
	undef @summary;
	undef @crresolv;
	undef @taskinfo;
	undef @binarylist;
	undef @uniqbinlist;
	undef @uniqtasks;
	undef @uniqtsks;
	undef @formattedtsks;
	undef $formattedtsks;
	undef @formattsks;
	undef @fformattsks;


    my ($deliveryname)=@_;
	$deliveryname=~ s/^\s+|\s+$//g;
	open OP,"<$Bin/$deliveryname\_formattsks.txt";
	@formattsks=<OP>;
	my @uniqtasks= do { my %seen; grep { !$seen{$_}++ } @formattsks};
	my @uniqtsks=grep(s/\s*$//g,@uniqtasks);
	my @uniqtsks=grep /\S/,@uniqtsks;
	@fformattsks=map{"$_\n"} @uniqtsks;
	$formattedtsks=join(",",@fformattsks);
	$formattedtsks =~ s/[\n\r]//g;
	close OP;
	open OP,"<$Bin/$deliveryname\_synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_summary_readme.txt";
	@summary=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_crresolv.txt";
	@crresolv=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	open OP, "< $Bin/$deliveryname\_patchbinarylist.txt";
	@binarylist=<OP>;
	close OP;
	print "Patch binary list is: @binarylist\n";
	my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @binarylist};
	print "Uniq Binlist is: @uniqbinlist\n";
	print FILE "--";
	print FILE "\nRelease - $deliveryname\n";
	print FILE "\nTASKS:$formattedtsks\n\n";
	print FILE "FIXES:@synopsis\n\n";
	print FILE "AFFECTS: $affects\n";
	print FILE "@uniqbinlist\n\n";
	print FILE "SUMMARY OF CHANGES: $deliveryname\nThe following changes have been delivered in this Maintenance Release.\n@summary\n";
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
main();