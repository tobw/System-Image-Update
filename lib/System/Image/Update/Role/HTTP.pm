package System::Image::Update::Role::HTTP;

use 5.014;
use strict;
use warnings FATAL => 'all';

=head1 NAME

System::Image::Update::Role::HTTP - role managing http tasks

=cut

use Moo::Role;
use Net::Async::HTTP;
use URI;
use HTTP::Status qw(status_message);

with "System::Image::Update::Role::Async", "System::Image::Update::Role::Logging";

our $VERSION = "0.001";

has http => ( is => "lazy" );

sub _build_http { my $http = Net::Async::HTTP->new(); $_[0]->loop->add($http); $http }

has http_user => ( is => "lazy" );

my $http_user_built;

sub _build_http_user
{
    my $eth0_info = qx(ip link show dev eth0);
    ( $http_user_built = $eth0_info =~ m,link/ether\s((?:[a-f0-9]{2}:){5}[a-f0-9]{2}),ms ? $1 : "" ) =~ s/://g;
    $http_user_built;
}

has http_passwd => ( is => "lazy" );

my $http_passwd_built;

sub _build_http_passwd
{
    my $eth0_info = qx(ip link show dev eth0);
    ( $http_passwd_built = $eth0_info =~ m,link/ether\s((?:[a-f0-9]{2}:){5}[a-f0-9]{2}),ms ? $1 : "" ) =~ s/://g;
    $http_passwd_built;
}

around collect_savable_config => sub {
    my $next                   = shift;
    my $self                   = shift;
    my $collect_savable_config = $self->$next(@_);

    my $http_user   = $self->http_user;
    my $http_passwd = $self->http_passwd;

    defined $http_user_built   or $collect_savable_config->{http_user}   = $self->http_user;
    defined $http_passwd_built or $collect_savable_config->{http_passwd} = $self->http_passwd;

    $collect_savable_config;
};

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
