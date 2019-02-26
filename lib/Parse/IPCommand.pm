package Parse::IPCommand;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       parse_ip_addr_show
                       list_network_interfaces
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

our %argopt_output = (
    output => {
        summary => 'Output of command',
        description => <<'_',

This function only parses program's output. You need to invoke "ip" command on
your own.

_
        schema => 'str*',
        cmdline_src => 'stdin_or_files',
    },
);

$SPEC{parse_ip_addr_show} = {
    v => 1.1,
    summary => 'Parse the output of "ip addr show" command',
    args => {
        %arg0_output,
    },
};
sub parse_ip_addr_show {
    my %args = @_;

    my $output = $args{output} or return [400, "Please specify output"];
    [501, "Not yet implemented"];
}

$SPEC{list_network_interfaces} = {
    v => 1.1,
    summary => 'List network interfaces from "ip addr show" output',
    description => <<'_',

If `output` is not specified, will run '/sbin/ip addr show' to get the output.

_
    args => {
        %argopt_output,
    },
};
sub list_network_interfaces {
    my %args = @_;

    my $out = $args{output} // `LANG=C /sbin/ip addr`;
    return [500, "Can't get the output of /sbin/ip addr: $! (exit=$?)"]
        unless $out;
    my @ifaces_txt = $out =~ /^\d: (.+?)(?=\z|^\d+:)/gms;
    return [500, "Can't find any interface from output of /sbin/ip addr, not even lo!"]
        unless @ifaces_txt;

    my @ifaces;
    my $i = 0;
    for (@ifaces_txt) {
        $i++;
        if (/\A(lo):/) {
            push @ifaces, {dev=>$1, mac=>'', addr=>''};
        } else {
            my $iface = {};

            s!\A(\S+):!! or do {
                warn "Can't get device name for interface #$i, skipped";
                next;
            };
            $iface->{dev} = $1;

            m!^\s*inet (\S+?)(?:/\d+)? brd \S+ scope global!ms and do {
                $iface->{addr} = $1;
            } or do {
                warn "Can't get inet address for dev $iface->{dev}";
            };

            m!^\s*link/ether (\S+)!m and do {
                $iface->{mac} = $1;
            };

            push @ifaces, $iface;
        }
    }
    [200, "OK", \@ifaces];
}


1;
# ABSTRACT:

=head1 SYNOPSIS

 use Parse::IPCommand qw(
     parse_ip_addr_show
     list_network_interfaces
 );

 my $res = parse_ip_addr_show(output => scalar `ip addr show`);


=head1 DESCRIPTION


=head1 SEE ALSO
