#!/usr/bin/perl -w

use Test::Command;
use Test::More;

# evaluate if we have internet
if(!gethostbyname("www.google.com")) {
    plan skip_all => 'Can\'t resolve www.google.com -> no internet?';
    exit 0;
}

plan tests => 18;

my $re_num = qr{\d+(?:\.\d+)?};

# fping
{
my $cmd = Test::Command->new(cmd => "fping -q -i 10 -p 20 -c 3 -t200  8.8.8.8 4.2.2.5 www.france-telecom.fr www.google.com");
$cmd->exit_is_num(0);
$cmd->stdout_is_eq("");
$cmd->stderr_like(qr{8\.8\.8\.8\s*: xmt/rcv/%loss = [123]/3/\d+%, min/avg/max = $re_num/$re_num/$re_num
4\.2\.2\.5\s*: xmt/rcv/%loss = [123]/3/\d+%, min/avg/max = $re_num/$re_num/$re_num
www\.france-telecom\.fr\s*: xmt/rcv/%loss = [123]/3/\d+%, min/avg/max = $re_num/$re_num/$re_num
www\.google\.com\s*: xmt/rcv/%loss = [123]/3/\d+%, min/avg/max = $re_num/$re_num/$re_num
});
}

# fping -A -n
{
my $cmd = Test::Command->new(cmd => "fping -A -n 8.8.8.8");
$cmd->exit_is_num(0);
$cmd->stdout_is_eq("google-public-dns-a.google.com (8.8.8.8) is alive\n");
$cmd->stderr_is_eq("");
}

# fping -A -n
{
my $cmd = Test::Command->new(cmd => "fping -A -n google-public-dns-a.google.com");
$cmd->exit_is_num(0);
$cmd->stdout_is_eq("google-public-dns-a.google.com (8.8.8.8) is alive\n");
$cmd->stderr_is_eq("");
}

# fping6 -A -n
SKIP: {
    if(system("/sbin/ifconfig | grep inet6") != 0) {
        skip 'No IPv6 on this host', 3;
    }
    my $cmd = Test::Command->new(cmd => "fping6 -n -A 2001:4860:4860::8888");
    $cmd->exit_is_num(0);
    $cmd->stdout_is_eq("google-public-dns-a.google.com (2001:4860:4860::8888) is alive\n");
    $cmd->stderr_is_eq("");
}

# fping -m
{
my $cmd = Test::Command->new(cmd => "fping -m google-public-dns-a.google.com");
$cmd->exit_is_num(0);
$cmd->stdout_is_eq("google-public-dns-a.google.com is alive\n");
$cmd->stderr_is_eq("");
}

# fping -n
{
my $cmd = Test::Command->new(cmd => "fping -n 8.8.8.8");
$cmd->exit_is_num(0);
$cmd->stdout_is_eq("google-public-dns-a.google.com is alive\n");
$cmd->stderr_is_eq("");
}
