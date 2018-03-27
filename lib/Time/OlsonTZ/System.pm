package Time::OlsonTZ::System;

use strict;
use warnings;
use Carp 'croak';
use Exporter 'import';
use File::Spec;

our $VERSION = '0.001';

our @EXPORT_OK = 'system_tzfile';

my $tzdir;
sub _tzdir { $tzdir ||= (grep { -d } qw(/usr/share/zoneinfo /usr/lib/zoneinfo))[0] }

sub system_tzfile {
  my $name = shift;
  croak 'system_tzfile: time zone name is required' unless defined $name and length $name;

  if ($name eq 'local') {
    if (-l '/etc/localtime') {
      my $path = readlink '/etc/localtime' or croak "Failed to readlink /etc/localtime: $!";
      $path = File::Spec->catfile('/etc', $path) unless File::Spec->file_name_is_absolute($path);
      return $path if -f $path;
    }
    return '/etc/localtime' if -f '/etc/localtime';
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

As a special case, if C<local> is passed as the time zone name,
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
