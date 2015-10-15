#! /usr/bin/perl
use Net::Rsh;
$a=Net::Rsh->new();
$host="pedlinux6.evolving.com";
$local_user="kkdaadhi";
$remote_user="kkdaadhi";
$cmd="cat /etc/issue";
@c=$a->rsh($host,$local_user,$remote_user,$cmd);
print @c;