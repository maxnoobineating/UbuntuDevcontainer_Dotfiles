package main

// Item represents a file system entry with separate fields.
type Item struct {
	FullPath    string // The full path to the file/directory.
	DisplayText string // The text to display (e.g. from ls --color).
	SearchKey   string // A field used for fuzzy searching (here, we simply use FullPath).
	SortOrder   int    // A number for custom ordering (not implemented here).
}

type ItemList struct {
	items []Item
}

type Command struct {
}

func (cmd Command)

type Mode struct {
}

type Mode_Abstract interface {
	options() string
	options_bind() string
	options_preview() string
	options_style() string
	run()
}

func (mode Mode) options() string {

}
func (mode Mode) options_bind() string {
}
func (mode Mode) options_preview() string {
}
func (mode Mode) options_style() string {
}
func (mode Mode) run() void {
}
