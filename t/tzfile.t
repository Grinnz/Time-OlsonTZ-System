use strict;
use warnings;

use if !$ENV{TZDIR} && !-d '/usr/share/zoneinfo' && !-d '/usr/lib/zoneinfo',
  'Test::More', skip_all => 'tzfile database not found; set TZDIR';

use Test::More;
use Time::OlsonTZ::System 'system_tzfile';

my $path;
ok defined($path = system_tzfile('UTC')), "UTC: $path";
ok defined($path = system_tzfile('America/New_York')), "America/New_York: $path";
ok defined($path = system_tzfile('PST8PDT')), "PST8PDT: $path";
ok defined($path = system_tzfile('Etc/GMT')), "Etc/GMT: $path";

SKIP: { skip 1, '/etc/localtime not found' unless -f '/etc/localtime';
  local $ENV{TZ};
  ok defined($path = system_tzfile('local')), "local: $path";
}

{
  local $ENV{TZ} = 'Asia/Bangkok';
  ok defined($path = system_tzfile('local')), "local: $path";
  is $path, system_tzfile($ENV{TZ}), 'localtime based on env';
}

done_testing;
