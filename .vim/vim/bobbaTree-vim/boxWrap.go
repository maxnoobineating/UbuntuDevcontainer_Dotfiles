package box

import (
	"fmt"
	"math"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type BoxWrap struct {
	box   *Box
	grid  *BoxGrid
	x     int
	xspan int // in index
	y     int
	yspan int // in index
	layer int
}

func (bw *BoxWrap) UpdateSize(width, height int) {

	boxWidth := bw.grid.BoxWidth(width, bw.x, bw.x+bw.xspan)
	boxHeight := bw.grid.BoxHeight(height, bw.y, bw.y+bw.yspan)
	bw.box.UpdateSize(boxWidth, boxHeight)
}
