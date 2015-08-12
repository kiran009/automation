#!/bin/ksh
#******************************************************************************
#
#           %name: updatePatchREADME.ksh %
#     %derived_by: mahesh %
#
#        %version: 6 %
#  %date_created: Wed Sep 28 09:37:07 2011 %
#******************************************************************************
currentaffectsDirName=""

show_usage()
{
   echo "Usage: $(basename $0) [XV] <filename> for enabling debug mode"
   echo " If you will give only <filename> disabling debug mode"
   echo " V <filename>  is for enabling verbose"
   echo "VX <filename>  is for enabling verbose and debug mode ........"
}

verboseMessage()
{
    if [ x"$verbose" = x"Y" ]
    then
        echo "$*"
    fi
}

# Getting all the dependent patches .
# Searches all the readme file for affectedFiles.
# Pickup the patch number from the files which have same affectedFiles.
getAllPatches()
{
for file in $AffectedFiles
do
    pipedList="$pipedList|$file"
done
pipedList="`echo $pipedList | cut -c2-`"

patches="`eval egrep '$pipedList' $PATCH_ROOT/*.txt | cut -d'_' -f1 | cut -d'/' -f7 | sort -u`"

patchesNotTested="`eval egrep '$pipedList' $PATCH_ROOT/NotTested/*.txt | cut -d'_' -f1 | cut -d'/' -f8 | sort -u`"

patches="$patches $patchesNotTested"

for p in $patches
do
    list="$list $p"
done
echo $list
}

# it is used to find out all the Obsolete patches from the patch list.
# It will search all the obsolete dir for the obsolete patches.
isObsolete()
{
    patchID=$1
    verboseMessage "Is $patchID obsolete?"
    patchList="`ls -C1 $PATCH_ROOT/*/obsolete/${PatchFileName}*.tar* | grep $patchID`"
    if [[ -n "$patchList" ]]
    then
        # echo "$patchID is obsolete patch.\nREASON:\n${patchList}\n"
        return 1
    fi
    return 0
}

# It is searching for non-obsolete patches.
# It will search all the tars in the specific patches directory.
# And find out the existance of specific patches.
isPatchExists()
{
    patchID=$1
    verboseMessage "Is $patchID exists?"
    patchList="`ls -C1 $PATCH_ROOT/*/${PatchFileName}*.tar* | grep $patchID`"
    if [[ -z "$patchList" ]]
    then
        echo "WARNING :$patchID does not exist.\n\tREASON: `pwd`/*/${PatchFileName}${patchID}.tar does not exist." >ToolWarn
        return 1
    fi
    return 0
}

# it will find out all the Affected files.
getAffectedFiles()
{
    readme="$2/$1_README.txt"
	ls $2/$1_README.txt > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
    		readme="$2/NotTested/$1_README.txt"
	fi


    # The AWK script locates the relevant section within the README, the grep
    # then picks out the filenames, the first sed removes the "$xxxxHOME/", and
    # the other 2 sed commands remove any .so, .sl or .1 extension (to make the
    # file list platform independent.
awk "/AFFECTS/ { printcontent=1; } { if (printcontent == 1) { print \$0; } } /TO INSTALL/ { printcontent=0; }" $readme | grep "HOME" | sed "s?.*HOME/??" | sed "s/\.s[ol].*//" | sed "s/\.1.*//"

}


getAffectsDirName()
{
echo "$2/$1_README.txt"
readme="$2/$1_README.txt"
	ls $2/$1_README.txt > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
    		readme="$2/NotTested/$1_README.txt"
	fi
dirName=`grep RELEASE_DIR "$readme"`
if [ "$dirName" != "" ]
then
return 1
else
return 0
fi
}

# it will find out all the superseded patches.
# It will pickup the readme files according to patchid.
# Compare all the AffectedFiles with the current readme file's Affected list.
# If the current readme file's Affected list contains all the AffectedFiles or
# less than it then patchid of AffectedFiles is treated as superseded to the
# patchid of readme file's Affected list.
isSuperseds()
{
    patchID=$1
    echo "PatchId : $patchID"
    #affectsDirName="`getAffectsDirName $patchID $PATCH_ROOT`"
    #echo "AffectsDirName : $affectsDirName"
    fileList="`eval getAffectedFiles $patchID $PATCH_ROOT`"
    echo "FileList : $fileList"
    if [ "${fileList}" = "" ]
    then
    return 3;
    fi
    #fileList="`eval getAffectedFiles $patchID $PATCH_ROOT`"


    for file in $fileList
    do
    echo "entering into isSuperseds Comaparing"
        flag=0
        for myFile in $AffectedFiles
        do
            verboseMessage "\tComparing $file and $myFile"
            if [ $file = $myFile ]
            then
                flag=1
            fi
        done
        verboseMessage "\t$file --> flag=$flag"
        if [ $flag -eq 0 ]
        then
            return 1
        fi
    done
    return 0

}

# Checking for all hierarchically down superseded patches
isActivesupersed()
{
    patchID=$1
    patchList="`grep $patchID *.txt | grep 'PATCHES SUPERSEDED BY THIS PATCH' | cut -d'_' -f1 | sort -u`"
    verboseMessage "\t\$patchList=$patchList"
    for patch in $patchList
    do
        for spatch in $checkList
        do
            verboseMessage "\tComparing $patch and $spatch"
            if [ $patch = $spatch ]
            then
                echo "WARNING: $patchID is not superseded patch as it already superseded by $spatch" >ToolWarn
		verboseMessage "\t Matched - return 1"
                return 1
            fi
        done
    done
		verboseMessage "\t NotMatched return 0"

    return 0
}

# It is used to find out the Prerequisite patches.
# It will Pick up all the readme file and compares all the affected files for
# the particular patchid  with current affectedfile list's patchid.
# if current affected file list contain less number of files than the readme
# files affected list then current affected file list patchid is treated as
# Prerequisite.
isPrerequisite()
{
    patchID=$1
    patchList="`grep $patchID *.txt | grep 'PRE-REQUISITE PATCHES' | cut -d'_' -f1 | sort -u`"
    verboseMessage "\t\$patchID=$patchID \$patchList=$patchList"
    flag=0
    Reason="$patchID is not pre-requisite of any patch"
    for patch in $patchList
    do
        if [ "`echo $tempsupersededList1 | grep $patch`" ]
        then
            Reason="$patch marks $patchID pre-requisite but $patch is also superseded patch"
            flag=0
        else
            Reason="$patch marks $patchID as pre-requisite and $patch is not superseded patch."
            flag=1
            break
        fi
    done
    verboseMessage "\$flag=$flag"
    if [ $flag -eq 1 ]
    then
        list="`eval echo $list | cut -c3-`"
        echo "WARNING :$patchID should not be marked as obsolete." >ToolWarn
    fi
}

# Start of the main script

currDIR="`pwd`";

if [ $# -eq 0 ]
then
    show_usage
    exit 0
fi

if [ $# -eq 2 ]
then
    if [ $1 = "X" ]
    then
        set -x
    fi
    if [ $1 = "V" ]
    then
        verbose=Y
    fi
    if [ $1 = "VX" -o $1 = "XV" ]
    then
        set -x
        verbose=Y
    fi
    FILE="$2"
fi

if [ $# -eq 1 ]
then
    FILE="$1"
fi

# make sure file is readable.

if [ ! -r $FILE ]; then
    echo "Error :$FILE: can not read " >ToolError
    exit 2
fi

# Generate an output file.
# If the output file and input file is same,
# it will generate Backup.txt file which is backup of input file.
# we can use it in later time

#ID=`grep TASK $FILE | head -4 | cut -d" " -f2 | sed s?,??`
#export ID=`grep TASK $FILE | head -4 | cut -d":" -f2 | sed s?,??`
#export ID=`grep TASK $FILE | cut -d":" -f2 | sed s?,??`
#export ID=`echo $ID|cut -d" " -f1`
#ID=$(echo "$ID" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

REL=`grep RELEASE_DIR "$FILE"`
echo "REL : ${REL}"
echo "${REL}" | grep  "RELEASE_DIR"  1>/dev/null
if [ `echo $?` -eq 0 ]
then
export isPROVHOME="false"
else
export isPROVHOME="true"
fi

echo "isPROVHOME : $isPROVHOME"

export ID=`grep TASK "$FILE" | cut -d":" -f2`
echo "${ID}" | grep  ","  1>/dev/null
if [ `echo $?` -eq 0 ]
then
export ID=`echo $ID|cut -d"," -f1`
else
export ID=`echo $ID|cut -d" " -f1`
fi
ID=$(echo "$ID" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
echo "PatchId :: $ID"
if [ "$FILE" = "${ID}_README.txt" ]
then
    mv $FILE Backup.txt
    # Ensure the variable is correctly set for our "new" input file.
    FILE=Backup.txt
fi

# Ensure that there is a file of the form <patch>_README.txt for
# getAffectedFiles to work on.
cp $FILE ${ID}_README.txt

# it is used for setting the current date in the output file.
updatedate=`date '+%d'`
if [ $updatedate -eq  1 -o $updatedate -eq 21 -o $updatedate -eq 31 ]
then
    DAY=`date '+%dst'`
elif [ $updatedate -eq 2 -o $updatedate -eq 22 ]
then
    DAY=`date '+%dnd'`
elif [ $updatedate -eq 3 -o $updatedate -eq 23 ]
then
    DAY=`date '+%drd'`
else
    DAY=`date '+%dth'`
fi

# Work out the product name and version from the Affects line.

ProductName=`grep AFFECTS: $FILE | cut -d" " -f2`
ProductVersion=`grep AFFECTS: $FILE | cut -d" " -f3`
if [ $ProductName = "Verification" ]; then
    PatchFileName="tsv-patch"
    ProductName="verification"
else
    if [ $ProductName = "MS" ]; then
        PatchFileName="ms-patch"
        ProductName="dsams"
    else
        if [ $ProductName = "Tertio" ]; then
            if [ $ProductVersion != "5.2.0" ]; then
                PatchFileName="tertio-patch"
            else
                PatchFileName="provident-patch"
            fi
            ProductName="tertio"
        fi
    fi
fi
PATCH_ROOT="/data/releases/${ProductName}/${ProductVersion}/patches"

verboseMessage "Patch name for version $ProductVersion is: $PatchFileName"

# Get a list of Affected file for this patch.
AffectedFiles="`eval getAffectedFiles $ID .`"
echo "AffectedFiles ------------------------------------------> $AffectedFiles"





verboseMessage "Affected files for patch $ID: $AffectedFiles"

# Getting all dependent patches

checkListTmp="`getAllPatches`"
#checkListNTTmp="`getNotTestedPatches`"
#checkListTmp="$checkListTmp $checkListNTTmp"



echo "checkListTmp ----------------- > $checkListTmp"
checkList=""

verboseMessage "All patches containing affected files: $checkListTmp"

# Checking for obsolete patches from the checkList.
for patchId in $checkListTmp
do
    if isObsolete $patchId
    then
        checkList="$checkList $patchId"
    fi
done

verboseMessage "All non-obsolete patches containing affected files: $checkList"

# Checking for existance of non-obsolete patches.

checkListTmp=$checkList
checkList=""
for patchId in $checkListTmp
do
    #if isPatchExists $patchId
    #then
        checkList="$checkList $patchId"
    #fi
done

verboseMessage "All existing patches containing affected files: $checkList"

# Checking whether patch is superseded/pre-requisite

for patchId in $checkList
do
    verboseMessage "$patchId\n----"
    isSuperseds $patchId
    isSupersedPatch=$?
    #verboseMessage "isSupersedPatch ---- > $isSupersedPatch"
    echo "isSuperSed - $patchId"
    if [ $isSupersedPatch -eq 3 ]; then
        verboseMessage "\t**** Empty Patch List "
    continue;
    fi

    if [ $isSupersedPatch -eq 0 ]; then
        supersededList="$supersededList $patchId"
    else
        prereqList="$prereqList, $patchId"
    fi
done

verboseMessage "Initial superseded list: $supersededList"
verboseMessage "Initial pre-requisite list: $prereqList"

tempsupersededList1="$supersededList"
for p in $supersededList
do
    verboseMessage "$p\n----"
    if isActivesupersed $p
    then
        tempsupersededList="$tempsupersededList, $p"
    fi
done

verboseMessage "Final superseded list: $tempsupersededList"

# Create the output file by doing the necessary replacements.

echo ""
if [[ -z $prereqList ]]
then
    prereqList="NONE"
else
    prereqList="`eval echo $prereqList | cut -c3-`"
fi

if [[ -z $tempsupersededList ]]
then
    supersededList="NONE"
else
    supersededList="`eval echo $tempsupersededList | cut -c3-`"
fi

cat $FILE | sed "s/^CREATED:/CREATED: $DAY `date '+%B %Y'`/g" | sed "s/^PRE-REQUISITE PATCHES:/PRE-REQUISITE PATCHES: $prereqList/g" | sed "s/^PATCHES SUPERSEDED BY THIS PATCH:/PATCHES SUPERSEDED BY THIS PATCH: $supersededList/g" > ${ID}_README.txt

tempsupersededList="`eval echo $tempsupersededList | tr -d ','`"
echo ""
for p in $tempsupersededList1
do
    isPrerequisite $p
done
