#!/usr/bin/perl
use strict;
use Getopt::Long;
use DBI;
my $heredoc= <<END;
Nagios Check for SLA Reporting - version 0.1
Available Options

	-w --warning	The warning level for the check
	-c --critical	The critical level for the check
	-n --name		The name of the service
	-p --percent	Print output in percent, not seconds
	-h --help		This help text
END

# --- Configuration Data (modify to match your system) --- #
my $sla_mysqldb = 'nagios_sla';
my $sla_mysqlhost = 'localhost';
my $sla_mysqluser = 'sla-user';
my $sla_mysqlpass = 'nagiossla4DA';

# global returncodes
my $OK=0;
my $WARNING=1;
my $CRITICAL=2;
my $UNKNOWN=3;

my $percent=0;
my @sla_report;
my @sla_config;
my $dbh;
my $cursor;
my $SQL;
my @temp;
my $s_report_name;
my $s_report_sec;
my $s_config_name;
my $s_config_sec;
my $s_config_no_sec;
my $diff;

my %opt=(
        "percent"       => undef,
        "name"          => "",
        "warning"       => undef,
        "critical"      => undef,
		"help"			=> undef,
);

if(parseopts() == $UNKNOWN)
{
	exit $UNKNOWN;
}

$dbh = DBI->connect("DBI:mysql:$sla_mysqldb:$sla_mysqlhost", $sla_mysqluser, $sla_mysqlpass) or die $DBI::errstr;
$SQL = "SELECT * from sla_report where service_name like \"$opt{name}\"";
$cursor = $dbh->prepare($SQL);
$cursor->execute();
while(@temp = $cursor->fetchrow_array)
{
	$s_report_name = $temp[0];
	$s_report_sec  = $temp[1];
}
$cursor->finish();

$SQL = "SELECT service_name,service_seconds,no_service_seconds from sla_config where service_name like \"$opt{name}\"";
$cursor = $dbh->prepare($SQL);
$cursor->execute();

while(@temp = $cursor->fetchrow_array)
{
	$s_config_name   = $temp[0];
	$s_config_sec    = $temp[1];
	$s_config_no_sec = $temp[2];
}

$cursor->finish();
$dbh->disconnect();

if ($s_config_name !~ /$s_report_name/)
{
	print "Config and Report Name are not the same, is the DB okay?!?\n";
	exit $UNKNOWN;
}

if ($percent == 0)
{
	$diff = $s_config_sec - $s_report_sec;
	my $pnp = " | $opt{name}=$diff;$opt{warning};$opt{critical};0;";
	if ($diff <= $opt{critical})
	{
		print "CRITICAL: $diff < $opt{critical}! $pnp";
		exit $CRITICAL;
	}
	elsif ($diff <= $opt{warning})
	{
		print "WARNING: $diff < $opt{warning}! $pnp";
                exit $WARNING;
	}
	elsif ($diff >= $opt{warning})
	{
		print "OK: $diff > $opt{warning}! $pnp";
		exit $OK;
	}
	else
	{
		print "UNKNOWN: $diff!\n";
		exit $UNKNOWN;
	}
}
else
{
        $diff = ($s_config_sec - $s_report_sec);
	$diff = ($diff / $s_config_sec);
	$diff *= 100;
	$diff = 100 - $diff;
	my $pnp = " | $opt{name}=$diff;$opt{warning};$opt{critical};0;";
        if ($diff <= $opt{critical})
        {
                print "CRITICAL: $diff % < $opt{critical} %!$pnp";
                exit $CRITICAL;
        }
        elsif ($diff <= $opt{warning})
        {
                print "WARNING: $diff % < $opt{warning} %!$pnp";
                exit $WARNING;
        }
        elsif ($diff >= $opt{warning})
        {
                print "OK: $diff % > $opt{warning} %!$pnp";
                exit $OK;
        }
        else
        {
                print "UNKNOWN: $diff!\n";
                exit $UNKNOWN;
        }
}


#-------- Method definition -------#
sub parseopts{
	GetOptions(
		"h|help"        => \$opt{help},
		"p|percent"     => \$opt{percent},
		"w|W|warning=s" => \$opt{warning},
		"c|C|critical=s"=> \$opt{critical},
		"n|name=s"      =>\$opt{name}
	);
	if ($opt{help})
	{
		print $heredoc;
		return $UNKNOWN;
	}
	if ($opt{percent})
	{
		$percent=1;
	}
	if (!$opt{warning})
	{
		print "Warning level required!\n";
		print $heredoc;
		return $UNKNOWN;
	}
	if (!$opt{critical})
	{
		print "Critical level required!\n";
		print $heredoc;
		return $UNKNOWN;	
	}
	if(!$opt{name})
	{
		print "Name required!\n";
		print $heredoc;
		return $UNKNOWN;
	}
	return $OK;
}
