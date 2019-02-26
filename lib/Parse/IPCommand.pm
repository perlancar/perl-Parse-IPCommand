package Parse::IPCommand;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       parse_ip_addr_show
                       list_network_interfaces_from_ip_addr_show
               );

our %SPEC;

our %arg0_output = (
    output => {
        summary => 'Output of command',
        description => <<'_',

This function only parses program's output. You need to invoke "ip" command on
your own.

_
        schema => 'str*',
        pos => 0,
        req => 1,
        cmdline_src => 'stdin_or_files',
    },
);

$SPEC{parse_ip_addr_show} = {
    v => 1.1,
    summary => 'Parse the output of "ip addr show" command',
    args => {
    },
};
sub parse_ip_addr_show {
    my %args = @_;

    my $output = $args{output} or return [400, "Please specify output"];

}

sub list_network_interfaces_from_ip_addr_show {
  my $out = `LANG=C /sbin/ip addr`;
  #DEBUG "Raw output of ifconfig: $ifconfig";
  if (!$out) { log_fatal("Can't get the output of /sbin/ip addr: $! (exit=$?). Aborting"); exit 1 }
  my @ifaces_txt = $out =~ /^\d: (.+?)(?=\z|^\d+:)/gms;
  #DEBUG "Raw \@ifaces_txt: ".join(", ", map {"'$_'"} @ifaces_txt);
  if (!@ifaces_txt) { log_fatal("There are no interfaces found from /sbin/ifconfig, not even `lo`!"); exit 1 }

  my @ifaces;
  for (@ifaces_txt) {
    if (/\A(lo):/) {
      push @ifaces, {dev=>$1, mac=>'', addr=>''};
    } elsif (m!\A(\S+):.+link/ether (\S+).+inet (.+?)(?:/|\s)!s) {
      push @ifaces, {dev=>$1, mac=>$2, addr=>$3};
    }
  }

  log_debug("network_interfaces: [".join(", ", map {"{dev=>$_->{dev}, addr=>$_->{addr}, mac=>$_->{mac}}"} @ifaces)."]");
  @ifaces;
}


1;
# ABSTRACT:

=head1 SYNOPSIS

 use Parse::IPCommand qw(
     parse_ip_addr_show
 );

 my $res = parse_ip_addr_show(output => scalar `ip addr show`);


=head1 SEE ALSO
