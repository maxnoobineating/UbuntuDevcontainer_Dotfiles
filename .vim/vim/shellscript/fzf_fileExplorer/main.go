package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
  Item ItemList Mode "./obj"
)

// listItems runs a "find" command in cwd to get all files/directories recursively,
// then for each, runs "ls -ld --color=always" to obtain a long listing with colors.
func listItems(cwd string, includeHidden bool) ([]Item, error) {
	// Construct the find command.
	// We use "-mindepth 1" to avoid listing the cwd itself.
	findCmd := exec.Command("find", cwd, "-mindepth", "1")
	var findOut bytes.Buffer
	findCmd.Stdout = &findOut
	if err := findCmd.Run(); err != nil {
		return nil, fmt.Errorf("find error: %w", err)
	}

	lines := strings.Split(strings.TrimSpace(findOut.String()), "\n")
	var items []Item
	for _, line := range lines {
		// If not including hidden files, skip entries whose base name starts with '.'
		base := filepath.Base(line)
		if !includeHidden && strings.HasPrefix(base, ".") {
			continue
		}

		// Run "ls -ld --color=always <line>"
		lsCmd := exec.Command("ls", "-ld", "--color=always", line)
		var lsOut bytes.Buffer
		lsCmd.Stdout = &lsOut
		if err := lsCmd.Run(); err != nil {
			// If ls fails, skip this item.
			continue
		}
		display := strings.TrimSpace(lsOut.String())
		items = append(items, Item{
			FullPath:    line,
			DisplayText: display,
			SearchKey:   line, // For simplicity, using FullPath as the search key.
			SortOrder:   0,    // Custom sort not implemented in this example.
		})
	}
	return items, nil
}

// launchFzf builds a candidate list from items and runs fzf with options such as --ansi,
// --delimiter, --nth, and a preview command.
// It returns the selected item.
func launchFzf(items []Item, cwd string) (Item, error) {
	var buf bytes.Buffer
	// Build candidate lines. Format: fullPath|displayText
	for _, it := range items {
		// Use a delimiter unlikely to appear in paths.
		fmt.Fprintf(&buf, "%s|%s\n", it.FullPath, it.DisplayText)
	}

	// Define a preview command that:
	// - For a file, runs "bat --style=numbers --color=always"
	// - For a directory, runs "ls -la --color=always"
	// fzf will replace {} with the selected candidate (the full candidate line).
	previewCmd := `f=$(echo {} | cut -d'|' -f1); if [ -d "$f" ]; then ls -la --color=always "$f"; else bat --style=numbers --color=always "$f"; fi`

	// Build fzf arguments:
	// --ansi: render ANSI escape sequences.
	// --delimiter="|" and --nth=2.. display only the ls output in the fzf list,
	//   but the full line is returned.
	args := []string{
		"--ansi",
		"--delimiter=|",
		"--nth=2..",
		"--preview", previewCmd,
	}

	// Launch fzf as a subprocess.
	cmd := exec.Command("fzf", args...)
	cmd.Stdin = &buf
	var outBuf bytes.Buffer
	cmd.Stdout = &outBuf

	if err := cmd.Run(); err != nil {
		return Item{}, fmt.Errorf("fzf error: %w", err)
	}

	// fzf returns the selected candidate line.
	selected := strings.TrimSpace(outBuf.String())
	parts := strings.SplitN(selected, "|", 2)
	if len(parts) < 1 {
		return Item{}, fmt.Errorf("failed to parse fzf output")
	}
	selectedPath := parts[0]

	// Find the item in our list that matches selectedPath.
	for _, it := range items {
		if it.FullPath == selectedPath {
			return it, nil
		}
	}
	return Item{}, fmt.Errorf("selected item not found")
}

func main() {
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("cannot get cwd: %v", err)
	}

	fmt.Printf("Current Directory: %s\n", cwd)
	items, err := listItems(cwd, false)
	if err != nil {
		log.Fatalf("error listing items: %v", err)
	}
	if len(items) == 0 {
		fmt.Println("No items found")
		return
	}

	selected, err := launchFzf(items, cwd)
	if err != nil {
		log.Fatalf("error launching fzf: %v", err)
	}
	fmt.Printf("You selected: %s\n", selected.FullPath)
}
