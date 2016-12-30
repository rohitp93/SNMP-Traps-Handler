#!/usr/bin/perl

use DBI;
use DBD::mysql;
use Data::Dumper;    
use Cwd qw (abs_path getcwd cwd);
use FindBin qw ($Bin);
use Net::SNMP qw(:snmp snmp_dispatcher :asn1);

@path = split("/",$Bin);
pop(@path);
push(@path,"db.conf");
$dbc = join("/",@path);
require "$dbc";

$dsn = "DBI:mysql:$database:$host:$port";
$dbh = DBI->connect($dsn,$username,$password);
   
my $TRAP_FILE = "/var/www/html/et2536-ropo15/assignment3/traps.log";	

%trap;
my $fq;
my $st;

open(TRAPFILE, ">> $TRAP_FILE");

while(<STDIN>) 
{
        chomp($_);
	push(@var,$_);
	@var = split(" ",$_);
	@get = ();
	if ($var[0] eq ".1.1.3.6.1.4.1.41717.10.1")
	{
	$fqdn = $var[1];
	$fqdn=~s/"//g;
	$trap{"$fqdn"}{fqdn} = $fqdn;
	}

	if ($var[0] eq ".1.1.3.6.1.4.1.41717.10.2")
	{
	$stat = $var[1];
	$trap{"$fqdn"}{status} = $stat;
	}

$ct = time();

print(TRAPFILE "\n");
}

#$fqdn = "rohit";
#$stat = "1";
#$trap{"$fqdn"}{status} = $stat;
#$trap{"$fqdn"}{fqdn} = $fqdn;

$fq = $trap{"$fqdn"}->{fqdn};
$st = $trap{"$fqdn"}->{status};
$ct = time();

$rth = $dbh->prepare("INSERT INTO Traps (fqdn, cur_st, cur_time) VALUES ('$fq','$st','$ct') ON DUPLICATE KEY UPDATE pre_st = cur_st,pre_time = cur_time,cur_st='$st',cur_time='$ct'");		
$rth->execute() or die $DBI::errstr;

$sth = $dbh->prepare("SELECT * FROM Manager");
$sth->execute() or die $DBI::errstr;

while(@row = $sth->fetchrow_array())
{
	$ip = $row[1];
	$ports = $row[2];
	$com = $row[3];

	$session = Net::SNMP->session(
                           		-hostname      => $ip,
                           		-port          => $ports,
                           		-community     => $com
                           		);                    
$oid  = '1.3.6.1.4.1';

if ($st==3)
{
	$fth = $dbh->prepare("SELECT * FROM Traps WHERE fqdn = '$fq'");
	$fth->execute() or die $DBI::errstr;

	while(@row = $fth->fetchrow_array())
	{
	  @send1 = ();
	  $pr = $row[2];
	  $prt = $row[4];
	  push @send1,'1.3.6.1.4.1.41717.20.1',OCTET_STRING,"$fq",'1.3.6.1.4.1.41717.20.2',UNSIGNED32,"$ct",'1.3.6.1.4.1.41717.20.3',INTEGER,"$pr",'1.3.6.1.4.1.41717.20.4',UNSIGNED32,"$prt";           

	}

		$result = $session->trap(
                		-enterprise      => $oid,
                		-agentaddr       => '127.0.0.1',
                		-generictrap     => '6',
				-specifictrap	 => '247',
                 		-varbindlist     => \@send1,
                       		);                    

		$fth->execute() or die $DBI::errstr;

if (!defined $result) {
      printf "ERROR: %s.\n", $session->error();
      $session->close();
      exit 1;
   }

}

if ($st==2)
{
	$zth = $dbh->prepare("SELECT * FROM Traps WHERE cur_st = 2");
	$zth->execute() or die $DBI::errstr;
	@send2 = ();

	my $i=0;
	while (@row = $zth->fetchrow_array())
	{
	 $i++;
	}
#print (TRAPFILE "$i\n");
	 if ($i >= 2)
	 {
	 $qth = $dbh->prepare("SELECT * FROM Traps WHERE cur_st = 2");
	 $qth->execute() or die $DBI::errstr;
	 @oid = (1,2,3,4);
	 @send2 = ();

	while(@row = $qth->fetchrow_array())
	{
	  $dom = $row[0];
	  $tim = $row[3];
	  $prst = $row[2];
	  $prtim = $row[4];

push @send2,".1.3.6.1.4.1.41717.30.$oid[0]",OCTET_STRING,"$dom",".1.3.6.1.4.1.41717.30.$oid[1]",UNSIGNED32,"$tim",".1.3.6.1.4.1.41717.30.$oid[2]",INTEGER,"$prst",".1.3.6.1.4.1.41717.30.$oid[3]",UNSIGNED32,"$prtim";

	 @oid= map{$_ + 4} @oid;	
	}

	
		$result = $session->trap(
                		-enterprise      => $oid,
                		-agentaddr       => '127.0.0.1',
                		-generictrap     => '6',
                		-varbindlist     => \@send2,
                       		); 

	if (!defined $result) {
      printf "ERROR: %s.\n", $session->error();
      $session->close();
      exit 1;
   	}
	}
}

}                                             
close(TRAPFILE);


