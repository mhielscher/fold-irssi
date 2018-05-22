# fold-irssi
fold-irssi is a script for irssi that truncates long messages from specified users (the part "above the fold"), and prints the original, full message in a separate window.

## Usage
`/fold` displays the list of users with folding enabled.
`/fold <nick> <limit>` sets a user's fold limit, where `<limit>` is the maximum number of characters to display before the fold.
`/unfold <nick>` removes a user from the fold list.


## Planned Features
- Fold away entire subsequent messages within a timeout (anti-flood)
- Access folded messages and threads with a short hash key
- Log folded messages in special logs, perhaps user.folded.log
- Provide tool (to begin with) for re-integrating regular logs and fold logs
- Eventually figure out how to fold the messages on display, but leave logs untouched
