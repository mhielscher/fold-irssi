#!/usr/bin/perl -w

# Truncate very long messages from specified users, writing the body of the message to another
# window, and marking truncated messages with a [Read More] - i.e. putting it "below the fold".
# Written for irssi 0.8.19 by Matt Hielscher.
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "dev18.05.22";
%IRSSI = (
    authors	=> "Matt Hielscher",
    contact	=> "matt\@wasabiflux.org", 
    name	=> "fold",
    description	=> "Truncate and relocate excessively long messages from specified users.",
    license	=> "MIT", # until I choose an actual license and post to GitHub
    url		=> "https://github.com/mhielscher",
    changed	=> "2018-05-22T10:42-07:00"
);

my %folded_users = ();

sub cmd_print_help {
    my ($args) = @_;
    #if ($args =~ /^fold(_users)?(_length)? *$/i){
        my $help = (
            "/fold\n".
            "  List users and their fold limits.\n".
            "/fold <nick>\n".
            "  Show an individual user's fold limit.\n".
            "/fold <nick> <limit>\n".
            "  Set a user's fold limit in characters.\n".
            "/unfold <nick>\n".
            "  Turn off folding for a user.\n".
            "\n".
            "Prints full, original messages to a window named 'hilight'\n"
        );
        Irssi::print($help, MSGLEVEL_CLIENTCRAP);
    #}
}

# "/fold [nick] [limit]" interacts with the fold list - see comments below
sub cmd_fold {
    my ($args) = @_;
    my ($nick, $limit) = split(' ', $args);
    # "/fold" without arguments lists the folded users
    if ($nick eq "") {
        my $response = "Fold List:\n";
        foreach my $key (keys %folded_users) {
            $response = $response."   ".$key.": ".$folded_users{$key}."\n";
        }
        $response =~ s/\s+$//; # rtrim
        Irssi::print($response, MSGLEVEL_CLIENTCRAP);
    }
    # "/fold <nick>" returns that user's fold limit
    elsif ($limit eq "") {
        if (exists $folded_users{$nick}) {
            Irssi::print($nick."'s messages are folded at ".$folded_users{$nick}." characters.", MSGLEVEL_CLIENTCRAP);
        }
        else {
            Irssi::print($nick."'s messages are not folded.");
        }
    }
    # "/fold <nick> <limit>" sets a user's fold limit
    # (if <limit> < 0, unfold that user)
    else {
        if ($limit < 0) {
            cmd_unfold($nick);
            Irssi::print($nick." removed from folding list.", MSGLEVEL_CLIENTCRAP);
        }
        else {
            $folded_users{$nick} = $limit;
            Irssi::print($nick."'s messages will now fold at ".$limit." characters.", MSGLEVEL_CLIENTCRAP);
        }
    }
}

# "/unfold <user>" removes that user from the fold list 
sub cmd_unfold {
    my ($args) = @_;
    my ($nick) = split(' ', $args);
    if ($nick eq "") {
        Irssi::print("Specify a nick to disable folding.", MSGLEVEL_CLIENTCRAP);
    }
    else {
        delete $folded_users{$nick};
        Irssi::print($nick." removed from folding list.", MSGLEVEL_CLIENTCRAP);
    }
}

sub sig_message_public {
    my ($server, $msg, $nick, $address, $target) = @_;

    if (exists($folded_users{$nick}) && length($msg) > $folded_users{$nick}) {
        $length = $folded_users{$nick};
        $hilightWindow = Irssi::window_find_name('hilight');
        $fulltext = $target.": <".$nick."> ".$msg;
        $fulltext =~ s/%/%%/g;
        $hilightWindow->print($fulltext, MSGLEVEL_CLIENTCRAP) if ($hilightWindow);

        $shortText = substr($msg, 0, rindex($msg, " ", $length));
        $shortText = substr($msg, 0, $length) if (length($shortText) < $length/2);
        $shortText = $shortText."... [cut:".length($shortText)."]";
        Irssi::signal_continue($server, $shortText, $nick, $address, $target);
    }
}


$hilightWindow = Irssi::window_find_name('hilight');
if (!$hilightWindow) {
    Irssi::print("Creating a window named 'hilight'");
    Irssi::Windowitem::window_create("hilight", 2);
}

Irssi::signal_add('message public', 'sig_message_public');
Irssi::command_bind('help fold', 'cmd_print_help');

Irssi::command_bind('fold', 'cmd_fold');
Irssi::command_bind('unfold', 'cmd_unfold');


