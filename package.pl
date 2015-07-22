#!/usr/bin/perl
# Tertio 7.6 Build Script
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
my $binarylist="$Bin/fileplacement.fp";
my $javabinarylist="$Bin/javabinaries.fp";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
my $result=GetOptions("coreproject=s"=>\$coreproject,"javaproject=s"=>\$javaprojectname,"buildnumber=s"=>\$build_number);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core project name \n";
	exit;
}
push(@projectlist,$coreproject);
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
my @op;
my @file_list;
my $mrnumber;
my @location_explode;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
#my $mailto='kiran.daadhi@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
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
my $tertiodest="/u/kkdaadhi/Tertio_Dest";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
my $f_762a='1409';
my $f_762c='1413';
my $f_763a='1431';
sub main()
{
		#createReadme();
		start_ccm();
		listfolderTasks();
		ccm_stop();
		pkg();
		#createMail();
}
sub listfolderTasks()
{
	@tasks_762a=`$CCM folder -show tasks '$f_762a' -u -f "%task_number"`;
	@tasks_762c=`$CCM folder -show tasks '$f_762c' -u -f "%task_number"`;
	@tasks_763a=`$CCM folder -show tasks '$f_763a' -u -f "%task_number"`;

	print "Tasks in 7.6.2.a are => @tasks_762a \n\n";
	print "Tasks in 7.6.2.c are => @tasks_762c \n\n";
	print "Tasks in 7.6.3.a are => @tasks_763a \n\n";
	foreach $task(@tasks_762a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762a,$crinfo);
	}
	@uniq762a = do { my %seen; grep { !$seen{$_}++ } @crs_762a};
	foreach $task(@tasks_762c)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762c,$crinfo);
	}
	@uniq762c = do { my %seen; grep { !$seen{$_}++ } @crs_762c};
	foreach $task(@tasks_763a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_763a,$crinfo);
	}
	@uniq763a = do { my %seen; grep { !$seen{$_}++ } @crs_763a};

	print "Uniq CRs in 7.6.2.a are: @uniq762a \nUniq CRs in 7.6.2.c are: @uniq762c \nUniq CRs in 7.6.3.a are: @uniq763a\n";
	open  FILE, "+> $Bin/tertio_7.6_TESTREADME.txt";
	print FILE "Created: $dt\n\n";
	getTasksnReadme(@uniq763a);
	createReadme('7.6.3a');
	getTasksnReadme(@uniq762c);
	createReadme('7.6.2c');
	getTasksnReadme(@uniq762a);
	createReadme('7.6.2a');
	print FILE "\nTO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n";
	print FILE "ISSUES: None";
	close FILE;
}

sub createReadme()
{
	#open OP,"<$Bin/mrnumber.txt";
	#$mrnumber=<OP>;
	#close OP;
	my ($folderinfo)=@_;
	undef @formattsks;
	undef @synopsis;
	undef @summary;
	undef @crresolv;
	undef @taskinfo;
	undef @binarylist;

	open OP,"<$Bin/formattsks.txt";
	@formattsks=<OP>;
	@fformattsks=map{"$_\n"} @formattsks;
	$formattedtsks=join(",",@fformattsks);
	$formattedtsks =~ s/[\n\r]//g;
	close OP;
	open OP,"<$Bin/synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/summary_readme.txt";
	@summary=<OP>;
	close OP;
	open OP,"<$Bin/crresolv.txt";
	@crresolv=<OP>;
	close OP;
	open OP,"<$Bin/taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	open OP, "< $Bin/patchbinarylist.txt";
	@binarylist=<OP>;
	close OP;

	#$mrnumber=~ s/^\s+|\s+$//g;
	print FILE "\nFollowing details about the maintenance release: $folderinfo\n";
	print FILE "#"x80;
	print FILE "\nTASKS:$formattedtsks\n\n";
	print FILE "FIXES:@synopsis\n\n";
	print FILE "@binarylist\n\n";
	print FILE "SUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary\n";
	print FILE "#"x80;
}
sub getTasksnReadme()
{
	my @crs=@_;
	undef @tasks;
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary_readme.txt";
	open CRRESOLV, "+> $Bin/crresolv.txt";
	open TASKINF,"+>$Bin/taskinfo.txt";

	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		print "CRNumber is : $cr\n";
		@task_numbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		push(@tasks,@task_numbers);
		#get mrnumber, synopsis and other fields
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		foreach $task_number(@task_numbers)
		{
			$task_number=~ s/^\s+|\s+$//g;
			($task_synopsis)=`$CCM task -show info $task_number \-u \-format "%task_synopsis"`;
			($task_resolver)=`$CCM task -show info $task_number \-u \-format "%resolver"`;
			$task_synopsis=~ s/^\s+|\s+$//g;
			$task_resolver=~ s/^\s+|\s+$//g;
			#print "TASKINFO:$task_synopsis TASK RESOLVER:$task_resolver\n";
			print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		}
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print SYNOP "CR$cr $synopsis\n";
		#$mr_number=~ s/^\s+|\s+$//g;
		#open MR,"+> $Bin/mrnumber.txt";
		#print MR "$mr_number";
		#close MR;
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    	$patch_number=`$CCM query -u -f %patch_number`;
    	$patch_readme=`$CCM query -u -f %patch_readme`;
    	$patch_number=~ s/^\s+|\s+$//g;
    	$patch_number =~ s/\s+/_/g;
    	if(($patch_readme =~ /N\/A/) || (not defined $patch_readme))
    	{
    		print "The following CR: $cr doesn't have a README \n";
    	}
    	else
    	{
    		if(($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4596/) || ($cr =~ /4606/) || ($cr =~ /4609/))
    		{
    			open OP1,"+> $Bin/$patch_number\_README.txt";
    			print OP1 $patch_readme;
    			close OP1;
    			`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`;
    			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
    			print "PatchFiles information is : @PatchFiles \n";

        		push(@patchbinarylist,@PatchFiles);
        		$sumreadme=`sed -n '/AFFECTED:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTED' | grep -v 'ISSUES' | sed '/^\$/d'`;
        		print SUMM "CR$cr - $sumreadme\n";
        		print "Summary from README is: $sumreadme\n";
    		}
    		else
    		{
       			open OP1,"+> $Bin/$patch_number\_README.txt";
    			print OP1 $patch_readme;
    			close OP1;
    			`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`;
    			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
    			#print "PatchFiles information is : @PatchFiles \n";

	        	push(@patchbinarylist,@PatchFiles);
        		$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
        		print SUMM "CR$cr - $sumreadme\n";
        		#print "Summary from README is: $sumreadme\n";
    		}
    	}
	}
	my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
	open OP, "+> $Bin/patchbinarylist.txt";
	print OP @uniqbinlist;
	close OP;
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	$tasklist=join(",",@tasks);
	undef @formattsks;
	@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
	open OP,"+>$Bin/formattsks.txt";
	print OP @formattsks;
	close OP;
}
# sub createReadme()
# {
# 	open OP,"<$Bin/mrnumber.txt";
# 	$mrnumber=<OP>;
# 	close OP;
# 	open OP,"<$Bin/formattsks.txt";
# 	@formattsks=<OP>;
# 	$formattedtsks=join(",",@formattsks);
# 	$formattedtsks =~ s/[\n\r]//g;
# 	close OP;
# 	open OP,"<$Bin/synopsis.txt";
# 	@synopsis=<OP>;
# 	close OP;
# 	open OP,"<$Bin/summary_readme.txt";
# 	@summary=<OP>;
# 	close OP;
# 	open OP,"<$Bin/crresolv.txt";
# 	@crresolv=<OP>;
# 	close OP;
# 	open OP,"<$Bin/taskinfo.txt";
# 	@taskinfo=<OP>;
# 	close OP;
# 	open OP, "< $Bin/patchbinarylist.txt";
# 	@binarylist=<OP>;
# 	close OP;
#
# 	$mrnumber=~ s/^\s+|\s+$//g;
# 	open  FILE, "+> $Bin/tertio_7.6_README.txt";
# 	print FILE "Maintenance Release : Tertio $mrnumber build $build_number\n\n";
# 	print FILE "Created: $dt\n\n";
# 	print FILE "TASKS:$formattedtsks\n\n";
# 	print FILE "FIXES:@synopsis\n\n";
# 	print FILE "@binarylist\n\n";
# 	print FILE "TO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n\nSUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary ISSUES: None\n";
# 	close FILE;
# }
sub createMail()
{
	@location_explode=map{"$_<br/>"} @location;
	open (my $FILE, "+> $Bin/releasenotes.html");
	print $FILE "<html><head><style>table {border: 1 solid black; white-space: nowrap; font: 12px arial, sans-serif;} body,td,th,tr {font: 12px arial, sans-serif; white-space: nowrap;}</style></head><body>";
	print $FILE "<table width=\"100%\" border=\"1\"<br/>";
	print $FILE "<tr><b><td>Product</td></b><td colspan=\'2\'>Tertio</td></tr><br/>";
	print $FILE "<tr><b><td>Release</td></b><td colspan=\'2\'>$mrnumber</td></tr><br/>";
	print $FILE "<tr><b><td>Build Number</td></b><td colspan=\'2\'>$build_number</td></tr><br/>";
	print $FILE "<tr><b><td>Release Type</td></b><td colspan=\'2\'>Maintenance Release</td></tr><br/>";
	print $FILE "<tr><b><td>Location</td></b><td colspan=\'2\'>@location_explode</td></tr><br/>";
	print $FILE "<tr><b><td>Build Date</td></b><td colspan=\'2\'>$dtformat</td></tr><br/>";
	print $FILE "<tr><b><td>Major changes in the new build</td></b><td colspan=\'2\'>BUG FIXES</td></tr><br/>";
	print $FILE "<tr><b><td>TOME</td></b><td>3.0.0</td><td>BUILD19</td></tr><br/>";
	print $FILE "<tr><b><td>Tertio ADK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>CAF</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Dashboard SDK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>DDA Protocol Version</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Menu Server Extension</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>SMS payload STK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>RM CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>PE CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Has the developer documentation been updated?</td></b><td colspan=\"2\">N/A</td></tr></table><br/>";
	print $FILE "<b>Installation instructions: </b><br/>";
	print $FILE "Same as previous Tertio Maintenance Release<br/><br/>";
	print $FILE "<b>Additional information about the changes:</b>N/A<br /><b>The Resolved CRs are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>CR ID</td><td>Synopsis</td><td>Request Type</td><td>Severity</td><td>Resolver</td><td>Priority</td></tr><br/>";
	foreach $cr(@crresolv)
	{
		($crid,$synopsis,$requesttype,$severity,$resolver,$priority)=split(/#/,$cr);
		print $FILE "<tr><b><td>$crid</td><td>$synopsis</td><td>$requesttype</td><td>$severity</td><td>$resolver</td><td>$priority</td></tr>";
	}
	print $FILE "</table><br/>";
	print $FILE "<b>The checked in tasks since the last build are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>Task ID</td><td>Synopsis</td><td>Resolver</td></tr>";
	foreach $tsk(@taskinfo)
	{
		($task_number,$task_synopsis,$task_resolver)=split(/#/,$tsk);
		print $FILE "<tr><b><td>$task_number</td><td>$task_synopsis</td><td>$task_resolver</td></tr><br/>";
	}
	print $FILE "</table><br/>";
	print $FILE "<b>Note:</b> To install Tertio $mrnumber, please use the latest PatchManager<br/></body></html>";
	close $FILE;
}

sub pkg()
{
	umask 002;
	open LOCATION,">>$Bin/location.txt";
	foreach $prj(@projectlist)
	{
		rmtree($destdir);
		open OP, "< $binarylist";
  		@file_list=<OP>;
  		close OP;
  		my %deliveryhash;
  		$delroot="$dbbmloc/$prj/Provident_Dev/";
  		foreach $file(@file_list)
  		{
  			if($file =~ /TOMESRC/)
  			{
  				my @del=split(/\s+/,$file);
  				if($del[3] eq ".")
  				{
  					$deliveryhash{$del[1]}="$del[1],$del[5]";
  				}
  				else
  				{
  					$deliveryhash{$del[1]}="$del[3],$del[5]";
  				}
  			}
  			elsif($file =~ /DASHBOARDSRC/)
  			{
  				my @del=split(/\s+/,$file);
  				if($del[3] eq ".")
  				{
  					$deliveryhash{$del[1]}="$del[1],$del[5]";
  				}
  				else
  				{
  					$deliveryhash{$del[1]}="$del[3],$del[5]";
  				}
  			}
  			else
  			{
  				my @del=split(/\s+/,$file);
  				if($del[3] eq ".")
  				{
	  				$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
  				}
  				else
  				{
  					$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
  				}
  			}
  		}
  		open OP, "< $javabinarylist";
  		@file_list=<OP>;
  		close OP;
  		$delroot="$dbbmloc/$javaprojectname/Provident_Java/";
  		foreach $file(@file_list)
  		{
  			my @del=split(/\s+/,$file);
  			if($del[3] eq ".")
  			{
 	 			$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
	  		}
  			else
  			{
	  			$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
  			}
  		}
		foreach $key(keys %deliveryhash)
  		{
	  		$dirname=dirname($deliveryhash{$key});
				($filename,$permission)=split(/,/,$deliveryhash{$key});
				$filename=~ s/^\s+|\s+$//g;
				$permission=~ s/^\s+|\s+$//g;
  			mkpath("$destdir/$dirname");
				copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $!");
				chmod(oct($permission),"$destdir/$filename") or die("Couldn't able to set the permission $!");
				print "Permission: $permission for file: $destdir/$filename \n";
  		}
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);

  		if($prj =~ /linAS5/)
  		{
  			$hostos="rhel5";
  			$hostplatform="linAS5";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostos-build$build_number\.tar;gzip tertio-$mrnumber-$hostos-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostos-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostos-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";

  		}
  		elsif($prj =~ /hpiav3/)
  		{
  			$hostplatform="hpiav3";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; /usr/contrib/bin/gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
  		}
  		elsif($prj =~ /sol10/)
  		{
  			$hostplatform="sol10";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
  		}
  		`tar -cvf $Bin/logs.tar $Bin/reconfigure_devproject_*.log`;
  		close LOCATION;
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
main();
