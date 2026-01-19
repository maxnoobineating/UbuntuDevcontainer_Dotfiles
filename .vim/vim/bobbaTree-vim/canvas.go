package box

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

/*
  Grid (attach Box Box ...) > Grid (attach Box Box)  ... etc
	Box store position, defined size, keep track of its Grid
	Grid help resolve Box sizing (unit conversion), compose Box rendering
*/

type Canvas interface {
	// GetWidth() int
	SetWidth(int)
	// GetHeight() int
	SetHeight(int)
	// GetSize() (int, int)
	SetSize(int, int)
	Render() string
}

// type Box struct {
// 	lipgloss.Style
// 	boxes     []*BoxWrap
// 	gridLayer []*BoxGrid // layered
// }
