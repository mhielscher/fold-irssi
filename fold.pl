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
    license	=> "Not for Distribution", # until I choose an actual license and post to GitHub
    url		=> "https://github.com/mhielscher",
    changed	=> "2018-01-17T19:37-0800"
);

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

$window = Irssi::window_find_name('hilight');
Irssi::print("Create a window named 'hilight'") if (!$window);

Irssi::signal_add('message public', 'sig_message_public');
