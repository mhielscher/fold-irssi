#!/usr/bin/perl -w

# Truncate very long messages from specified users, writing the body of the message to another
# window, and marking truncated messages with a [Read More] - i.e. putting it "below the fold"
# for irssi 0.8.19 by Matt Hielscher, based on hilightwin.pl by Timo Sirainen
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "dev18.01.17";
%IRSSI = (
    authors	=> "Matt Hielscher",
    contact	=> "matt\@wasabiflux.org", 
    name	=> "fold",
    description	=> "Truncate and relocate excessively long messages from specified users.",
    license	=> "MIT", # until I choose an actual license and post to GitHub
    url		=> "https://github.com/mhielscher",
    changed	=> "2018-03-12T11:58-0700"
);

sub cmd_print_help() {
  my ($args) = @_;
  if ($args =~ /^fold(_users)?(_length)? *$/i){
    my $help = (
        "/set fold_users <user1> <user2> ...\n".
        "  Select users to truncate.\n".
        "/set fold_length <n>\n".
        "  n = Number of approximate characters to truncate at (word boundaries respected)\n".
        "\n".
        "Prints to a window named 'hilight'\n");
    Irssi::print($help, MSGLEVEL_CLIENTCRAP);
  }
}

sub sig_message_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    my %users = map {$_ => 1} split(/ /, Irssi::settings_get_str('fold_users'));
    my $length = Irssi::settings_get_int('fold_length');

    if (exists($users{$nick}) && length($msg) > $length) {
        $hilightWindow = Irssi::window_find_name('hilight');
        $fulltext = $target.": <".$nick."> ".$msg;
        $fulltext =~ s/%/%%/g;
        $hilightWindow->print($fulltext, MSGLEVEL_CLIENTCRAP) if ($hilightWindow);

        $shortText = substr($msg, 0, rindex($msg, " ", $length));
        $shortText = substr($msg, 0, $length) if (length($msg) < $length/2);
        $shortText = $shortText."... [cut]";
        Irssi::signal_continue($server, $shortText, $nick, $address, $target);
    }
}

# default users to fold (none)
Irssi::settings_add_str('lookandfeel', 'fold_users', '');
# default length of an "excessively long" message
Irssi::settings_add_int('lookandfeel', 'fold_length', 140);

$hilightWindow = Irssi::window_find_name('hilight');
Irssi::print("Creating a window named 'hilight'") if (!$hilightWindow);
Irssi::Windowitem::window_create("hilight", 2) if (!$hilightWindow);

Irssi::signal_add('message public', 'sig_message_public');
Irssi::command_bind_last('help', 'cmd_print_help');
