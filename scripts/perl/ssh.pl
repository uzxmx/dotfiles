use strict;
use warnings;

use JSON::PP;
use IPC::Open2;
use File::Basename;
use Cwd;
use Text::ParseWords;

my $dotfiles_dir = Cwd::realpath(dirname(__FILE__) . '/../..');

require $dotfiles_dir . '/scripts/perl/wrapper.pl';

sub check_ssh_hosts_file {
  if (! -e glob('~/.ssh_hosts')) {
    run_original();
  }
}

sub select_host {
  my ($host_label) = @_;
  my $key;

  my $file = glob('~/.ssh_hosts');
  unless (-e $file) {
    print_and_exit([basename($0)], 100);
  }

  open(FILE, '<', $file) or die $!;

  my $file_content = do { local $/; <FILE> };
  close(FILE);

  # With relaxed mode, we can add comments in the JSON file.
  # See https://metacpan.org/pod/JSON::PP#relaxed
  my $json = JSON::PP->new->relaxed(1)->decode($file_content);
  my $text = '';
  $text .= "$_->{label}\n" for @$json;

  if (!$host_label) {
    open2 my $out, my $in, 'fzf --expect=ctrl-e' or die $!;

    print $in "$_->{label}\n" for @$json;
    close($in);
    $key = <$out>;
    my $selected = <$out>;
    close($out);

    if ($key) {
      chomp($key);
    }
    if ($selected) {
      chomp($selected);
    }

    if (!$selected) {
      exit;
    }

    $host_label = $selected;
  }

  my $host;
  for my $h (@$json) {
    if ($h->{label} eq $host_label) {
      $host = $h;
      last;
    }
  }

  return new HostSelection($key, $host);
}

package HostSelection;

sub new {
   my $class = shift;
   my $self = {
      _key => shift,
      _host => shift
   };
   bless $self, $class;
   $self->set_interactive(::basename($0) eq 'ssh');
   return $self;
}

sub get_label {
  my ($self) = @_;
  return $self->{_host}->{label};
}

sub set_interactive {
  my ($self, $interactive) = @_;

  my $host = $self->{_host};
  my $command;
  if ($interactive) {
    $command = $host->{interactive_command} || $host->{command};
  } else {
    $command = $host->{noninteractive_command} || $host->{command};
  }

  if (ref($command) ne 'HASH') {
    $command = { template => $command || '{{COMMAND}}' };
  }

  $self->{_command} = $command;
}

sub build_command {
  my ($self, @command) = @_;

  my @tmp = ::shellwords($self->{_command}->{template});
  my @cmdline = ();
  use String::ShellQuote 'shell_quote';
  my $cmd_str = shell_quote(@command);
  for my $e (@tmp) {
    if ($e eq '{{COMMAND}}') {
      push @cmdline, $_ for @command;
    } else {
      $e =~ s/\{\{COMMAND_QUOTED}}/$cmd_str/g;
      push @cmdline, $e;
    }
  }

  return @cmdline;
}

sub run {
  my ($self, @command) = @_;

  my @cmdline = $self->build_command(@command);

  # Don't remove dotfiles from PATH, because we may rely on other
  # executables in that path, unless we've changed to use absolute paths.
  #
  # ::remove_path_from_env(glob($dotfiles_dir . '/bin'));

  # Let the caller execute for us.
  #
  # exec glob(shift(@cmdline)), @cmdline or die $!;

  my $code;
  if ($self->{_key} eq 'ctrl-e') {
    $code = 101;
  } else {
    $code = 100;
  }
  ::print_and_exit(\@cmdline, $code);
}

sub get_host {
  my ($self) = @_;

  if ($self->{_host}->{host}) {
    return $self->{_host}->{host};
  } else {
    my ($user, $h) = split(/@/, $self->{_host}->{label});
    return $h;
  }
}

sub get_port {
  my ($self) = @_;

  return $self->{_host}->{port};
}

sub get_user {
  my ($self) = @_;

  if ($self->{_host}->{user}) {
    return $self->{_host}->{user};
  } else {
    my ($user, $h) = split(/@/, $self->{_host}->{label});
    return $user;
  }
}

sub get_user_host {
  my ($self) = @_;

  return $self->get_user() . '@' . $self->get_host();
}

sub get_identity {
  my ($self) = @_;

  if (my $identity = $self->{_host}->{identity}) {
    return glob($identity);
  }
}

sub get_ssh_options {
  my ($self) = @_;

  return $self->{_command}->{ssh_options}
}

1;
