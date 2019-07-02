#!/usr/bin/perl

# Nagios SLA Reporting Script Part 1 - Eventhandler
# Philipp Lachberger, X-Tention IT GmbH

# ToDo: Error-Recovery

use DBI;
use SLA;

# --- Configuration Data (modify to match your system) --- #
my $sla_mysqldb = 'nagios_sla';
my $sla_mysqlhost = 'localhost';
my $sla_mysqluser = 'sla-user';
my $sla_mysqlpass = 'nagiossla4DA';

my $dbh = DBI->connect("DBI:mysql:$sla_mysqldb:$sla_mysqlhost", $sla_mysqluser, $sla_mysqlpass) or die $DBI::errstr;
my $time_t = time();

`echo "$time_t Executing DBI connect" >> /var/log/nagios/event.log`;

# if our state is neither okay, nor critical and eventually just "soft", then get off *g*
if (!(($ARGV[0] eq "OK" || $ARGV[0] eq "CRITICAL" || $ARGV[0] eq "Critical") && ($ARGV[3] eq "HARD" || $ARGV[3] eq "Hard")))
{
	`echo "$time_t Exiting for non-hard!" >> /var/log/nagios/event.log`;
	exit 2;
}

$NAGIOS_SERVICESTATE = $ARGV[0];
$NAGIOS_HOSTNAME = $ARGV[1];
$NAGIOS_SERVICENAME= $ARGV[2];

$SQL = "INSERT INTO sla_log (timestamp, state, host_service) VALUES (\"$time_t\", \"$NAGIOS_SERVICESTATE\", \"$NAGIOS_HOSTNAME:$NAGIOS_SERVICENAME\")";
$cursor = $dbh->prepare($SQL);
$cursor->execute();
`echo "$time_t Executed DB insert" >> /var/log/nagios/event.log`;

exit 0;
