package Time::OlsonTZ::System;

use strict;
use warnings;
use Carp 'croak';
use Cwd 'abs_path';
use Exporter 'import';
use File::Spec;

use constant LOCALTIME_PATH => '/etc/localtime';

our $VERSION = '0.001';

our @EXPORT_OK = 'system_tzfile';

my $tzdir;
sub _tzdir { $tzdir ||= (-d '/usr/share/zoneinfo') ? '/usr/share/zoneinfo' :
  (-d '/usr/lib/zoneinfo') ? '/usr/lib/zoneinfo' : undef }

sub system_tzfile {
  my $name = shift;
  croak 'system_tzfile: time zone name is required' unless defined $name and length $name;

  if ($name eq 'local') {
    if ($ENV{TZ}) {
      $name = $ENV{TZ};
    } elsif (-l LOCALTIME_PATH) {
      # resolve any symlinks and return absolute path
      my $path = abs_path LOCALTIME_PATH or croak "Failed to resolve /etc/localtime: $!";
      return $path if -f $path;
    } elsif (-f LOCALTIME_PATH) {
      return LOCALTIME_PATH;
    }
  }

  my $dir = $ENV{TZDIR} || _tzdir;
  croak 'Could not find system zoneinfo directory, please set TZDIR in the environment'
    unless defined $dir and length $dir;
  my @parts = split /\//, $name;
  my $path = File::Spec->catfile($dir, @parts);
  return undef unless -f $path;
  return $path;
}

1;

=head1 NAME

Time::OlsonTZ::System - Find system tzfile (zoneinfo) timezone files

=head1 SYNOPSIS

  use Time::OlsonTZ::System 'system_tzfile';

  my $tzfile = system_tzfile('America/New_York');
  my $local = system_tzfile('local');

=head1 DESCRIPTION

Finds the file path to system tzfiles corresponding to the given Olson time
zone name. It will look in the directory indicated by the C<TZDIR> environment
variable or the standard F</usr/share/zoneinfo> or F</usr/lib/zoneinfo>
directories. On non-Unix-like systems, the C<TZDIR> environment variable should
be used to indicate the location of the tzfile database.

=head1 FUNCTIONS

=head2 system_tzfile

  my $filepath = system_tzfile($tz_name);
  my $filepath = system_tzfile('local');

Returns the file path to the system tzfile for C<$tz_name>, if it exists, or
C<undef> otherwise. Throws an exception if the tzfile database location was not
found or set by the C<TZDIR> environment variable.

As a special case, if C<local> is passed as the time zone name, the C<TZ>
environment variable will be used as the time zone name if set, otherwise
F</etc/localtime> or (if it is a symlink) the path to the referenced tzfile
will be returned, if it exists.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Time::OlsonTZ::Data>, L<DateTime::TimeZone>
