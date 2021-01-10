# ARGV[0]: output of docker ps
# ARGV[1]: the time, all containers exited before that will be removed. Can be empty.

use Time::Piece;
use Time::Seconds;

sub convert_relative_time {
  my ($str) = @_;
  if ($str =~ m/^(\d+) *([hH](?:ours?)?|[dD](?:ays?)?|[wW](?:eeks?)?|[mM](?:onths?)?|[yY](?:ears?)?)$/) {
    my $num = $1 + 0;
    my $specifier = $2;
    my $unit;
    if ($specifier =~ m/[hH](?:ours?)?/) {
      $unit = ONE_HOUR;
    } elsif ($specifier =~ m/[dD](?:ays?)?/) {
      $unit = ONE_DAY;
    } elsif ($specifier =~ m/[wW](?:eeks?)?/) {
      $unit = ONE_WEEK;
    } elsif ($specifier =~ m/[mM](?:onths?)?/) {
      $unit = ONE_MONTH;
    } elsif ($specifier =~ m/[yY](?:ears?)?/) {
      $unit = ONE_YEAR;
    } else {
      printf "Unsupported specifier %s.\n", $specifier;
      exit 1;
    }
    return localtime() - $num * $unit;
  } else {
    printf "Cannot parse '%s'.\n", $str;
    exit 1;
  }
}

my @lines = split /\n/, $ARGV[0];
my @selected = ();
if ($ARGV[1] ne ''){
  my $exit_before = convert_relative_time($ARGV[1]);
  foreach my $line (@lines) {
    if ($line =~ m/Exited \(\d+\) (\d+) (hours?|days?|weeks?|months?|years?) ago$/) {
      my $exit_time = convert_relative_time($1 . " " . $2);
      if ($exit_time < $exit_before) {
        push @selected, $line;
      }
    }
  }
} else {
  @selected = @lines;
}

if (!scalar(@selected)) {
  printf "No containers found.\n";
  exit;
}
print $_, "\n" foreach (@selected);

use File::Basename;
use Cwd;
my $dotfiles_dir = Cwd::realpath(dirname(__FILE__) . '/../..');
require $dotfiles_dir . '/scripts/perl/prompt.pl';
my $yes = prompt_yes_no("\nAre you sure you want to remove above containers?", 0);
if ($yes) {
  my @args = ('rm');
  push @args, (split(' ', $_))[0] foreach (@selected);
  exec 'docker', @args or die $!;
  printf "Removed successfully.\n";
}
