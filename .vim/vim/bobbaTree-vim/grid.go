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

type Grid struct {
	Size
	Position
	Priority
	cells []*Cell
	// tags  []string
}

func (g *Grid) AddTag(tags ...Tag) {
	// turns all tags into strings
	for _, tag := range tags {
		switch t := tag.(type) {
		case string:
			append(g.tags, t)
			return
		case int:
			return
		case float32:
			return
		case float64:
			return
		default:
			return
		}
	}
}

func (g *Grid) VDivide3(x, y, z Unit) (*Cell, *Cell, *Cell) {
	c := &Cell{}
	return c, c, c
}

func (g *Grid) HDivide3(x, y, z Unit) (*Cell, *Cell, *Cell) {
	c := &Cell{}
	return c, c, c
}

func (g *Grid) VDivide2(x, y Unit) (*Cell, *Cell) {
	c := &Cell{}
	return c, c
}
func (g *Grid) HDivide2(x, y Unit) (*Cell, *Cell) {
	c := &Cell{}
	return c, c
}

func CreateGrid() *Grid {
	return &Grid{}
}

func (g *Grid) NewCell(tags ...Tag) *Cell {
	c := &Cell{}
	c.AddTag(tags)
	return c
}