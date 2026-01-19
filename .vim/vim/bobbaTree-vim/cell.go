package box

import (
	"errors"
	"strconv"
)

/*
border defined position/size
with size and position constraint, change top/left for pos, change bottom/right for size - hence in case of shrinking to fit max size, for example, the shrinked cell will be positioned top-left by default
*/

type Cell struct {
	Grid
	// Size
	// Position
	Priority
	borders [4]Border // top left bottom right
	parent  *Cell
	tags    []Tag
	// parentGrid *Grid
	// defWidth  Unit
	// defHeight Unit
}

func CreateCell() *Cell {
	return &Cell{}
}

func (c *Cell) AddTag(tags ...Tag) error {
	// turns all tags into strings
	for _, tag := range tags {
		switch t := tag.(type) {
		case string:
			c.tags = append(c.tags, t)
			return nil
		case int:
			c.tags = append(c.tags, strconv.Itoa(t))
			return nil
		case float32:
			s := strconv.FormatFloat(float64(t), 'f', -1, 32)
			c.tags = append(c.tags, s)
			return nil
		case float64:
			s := strconv.FormatFloat(t, 'f', -1, 64)
			c.tags = append(c.tags, s)
			return nil
		default:
			return errors.New("invalid tag")
		}
	}
	return nil
}

func (c *Cell) GetParentGrid() *Grid {
	return &c.parent.Grid
}

// func (c *Cell) NewGrid(tags ...Tag) *Grid {
// 	grid := &Grid{}
// 	grid.AddTag(tags)
// 	return grid
// }

// func (c *Cell) NewGridedCell(tags ...Tag) *Cell {
// 	grid := &Grid{}
// 	grid.AddTag(tags)
// 	cell := grid.NewCell()
// 	return cell
// }

func (c *Cell) NewCell(tags ...Tag) *Cell {
	grid := &Grid{}
	grid.AddTag(tags)
	cell := grid.NewCell()
	return cell
}

func (c *Cell) GetBorderTopBot() (Border, Border) {
	return &SharedBorder{}, &SharedBorder{}
}

func (c *Cell) GetBorderLeftRight() (Border, Border) {
	return &SharedBorder{}, &SharedBorder{}
}

func (c *Cell) GetBorders() (Border, Border, Border, Border) {
	return &SharedBorder{}, &SharedBorder{}, &SharedBorder{}, &SharedBorder{}
}
