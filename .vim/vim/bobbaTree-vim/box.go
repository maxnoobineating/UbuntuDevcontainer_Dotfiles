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
func sampleCode() {
	cell_base := CreateCell()

	// cell holds one grid, but grid can have multiple cells
	// Grid obj is automatically created per cell
	cell_tabline, cell_main, cell_toolbar := cell_base.grid.VDivide3(UnitPx(2), UnitGridWeight(1), UnitPx(3))
	// cell tags is flattened and stored in all parents for quick search
	cell_tabline.AddTag("tabline")
	cell_main.AddTag("main")
	cell_toolbar.AddTag("toolbar")

	cell_mainLeft, cell_mainRight := cell_main.grid.HDivide2(UnitGridWeight(1), UnitGridWeight(1))
	cell_mainLeft.AddTag("mainLeft")
	cell_mainRight.AddTag("mainRight")

	// add multiple grids to cell_base
	// add a single cell to the grid
	cell_floatWin := cell_base.grid.NewCell("floatWin")

	// border defined sizing/position - states stored as border
	// all of them override each other
	cell_floatWin.SetSize(UnitGrid(0.5), UnitGrid(0.2))
	cell_floatWin.SetPosition(UnitPx(0), UnitPx(0))
	cell_floatWin.SetPositionDelta(UnitGrid(0.2), UnitGrid(-0.5)) // on top of creation size/pos
	cell_floatWin.SetPositionCentered(UnitGrid(0.5), UnitGrid(0.5))

	// cells all track their parents?
	cell_floatWin.GetParent().grid
	cell_floatWin.GetParentGrid()

	//  4 borders to define a cell (flexbox-like Divide() is also using border)
	border_mainLeft_top, _ := cell_mainLeft.GetBorderTopBot()
	_, border_mainRight_bot := cell_mainRight.GetBorderTopBot()

	_, border_mainLeft_right := cell_mainLeft.GetBorderLeftRight()
	border_mainRight_left, _ := cell_mainRight.GetBorderLeftRight()

	IsSharedBorder(border_mainLeft_top, border_mainRight_bot)    // false
	IsSharedBorder(border_mainLeft_right, border_mainRight_left) // true
	if border_mainLeft_right == border_mainRight_left {
		// false, sharing same border still need to have sided info (who's on which side)
	}
	_, _, _, _ = cell_mainLeft.GetBorders()

	// non-copy re-divide of grids (add/delete cells, reapportion cells)
	// automatically changes cells that share the same border as mainLeft
	cell_mainLeft.SetSize(UnitGrid(0.8), UnitSame(true))
	// mainRight will push mainLeft to the left, by cell deriving size/pos from its border
	cell_mainRight.SetPosition(UnitPx(-10), UnitSame(true))
	// border modifying, abstract border (size/pos connection with custom method) - AbstractBorder{}
	// border_mainLeft_right.GrowIntoBy(border_mainRight_left, UnitGridWeight(2)) // error if it's not shared border

	// multi cell 2D grid -> directly define border then generate cells
	borderList_mainRightV, borderList_mainRightH = cell_mainRight.grid.DivideN( /* ... how?*/ )
	// no... how should I make this more ergonomic...

	// sort indexing border
	cell_mainRight.grid.BorderGetV(5) // get 5th vertical border

	// change grid dimension
	cell_mainRight.grid.setPosition(UnitSame(true), UnitGrid(0.5)) // can be used to move UI around, scrolling etc
	cell_mainRight.grid.setSize(UnitSame(true), UnitFitCell(0.5))
	// fit size to the contained cell, how to prevent inf recursive sizing tho...? what's css' solution to this?
	// - grid have a set of base borders, change of dimension is actually changing those border
	// , and if those border are shared by cell created from Divide(), then its sizing changes accordingly

	// priority
	// > cell.render will only calculate pos and size of each cell
	// , then render canvas base on priority and viewport (rest don't render)

	// scrolling content
	main_canvas = cell_main.newCanvas()

	// misc UI elements

	// Events / layout hooks
	// Allow the user to hook into lifecycle: OnLayout(cell) or OnResize(cell) so they can do custom drawing or override layout

	// Fallback / defaults
	// If user doesn’t specify borders or sizing, the system should assume a reasonable default (e.g. evenly distribute space).
}

type Box struct {
	lipgloss.Style
	boxes     []*BoxWrap
	gridLayer []*BoxGrid // layered
}

func (b *Box) AddBoxGridLayer(partitionW, partitionH []int) {
	b.gridLayer = append(b.gridLayer, CreateGrid(partitionH, partitionW))
}

func (b *Box) AddBox(box *Box, x, xspan, y, yspan, layer int) *BoxWrap {
	boxWrap := &BoxWrap{box, b.gridLayer[layer], x, xspan, y, yspan, layer}
	b.boxes = append(b.boxes, boxWrap)
	return boxWrap
}

func (b *Box) UpdateGrid(width, height int) {
	for _, grid := range b.gridLayer {

		grid.UpdateGrid(width, height)
	}
}

func (b *Box) UpdateSize(width, height int) {
	b.FitSize(width, height)
	innerWidth, innerHeight := b.GetWidth(), b.GetHeight()
	// b.UpdateGrid(innerWidth, innerHeight) // boxGrid have self caching so this is redundant
	for _, box := range b.boxes {
		box.UpdateSize(innerWidth, innerHeight)
	}
}

func (b *Box) FitWidth(width int) *Box {
	fx, _ := b.GetFrameSize()
	b.Style = b.Style.Width(max(0, width-fx))
	return b
}
func (b *Box) FitHeight(height int) *Box {
	_, fy := b.GetFrameSize()
	b.Style = b.Style.Height(max(0, height-fy))
	return b
}
func (b *Box) FitSize(width, height int) *Box {
	fx, fy := b.GetFrameSize()
	b.Style = b.Style.Width(max(0, width-fx)).Height(max(0, height-fy))
	return b
}