package box

import (
	"fmt"
	"math"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

func boxGrid_partitionTotal(partition []int) int {
	sum := 0
	for _, v := range partition {
		sum += v
	}
	return sum
}

func boxGrid_sizePartition(size int, partition []int) []int {
	partitionLen := boxGrid_partitionTotal(partition)
	sum, length, prev_length := 0, 0, 0
	ret_sizePartition := make([]int, len(partition))
	for i, v := range partition {
		sum += v
		prev_length = length
		length = int(math.Round(float64(size) * float64(sum) / float64(partitionLen)))
		ret_sizePartition[i] = length - prev_length
	}
	return ret_sizePartition
}

type BoxGrid struct {
	partitionH            []int
	partitionW            []int
	sizePartitionH_cached []int
	sizePartitionW_cached []int
	gridWidth_cached      int
	gridHeight_cached     int
}

func CreateBoxGrid(partitionH, partitionW []int) *BoxGrid {
	// sizePartitionH := make([]int, len(partitionH))
	// sizePartitionW := make([]int, len(partitionW))
	sizePartitionH := make([]int, len(partitionH))
	sizePartitionW := make([]int, len(partitionW))
	return &BoxGrid{partitionH, partitionW, sizePartitionH, sizePartitionW, 0, 0}
}

func (bg *BoxGrid) BoxWidthPartition(width int) []int {
	return boxGrid_sizePartition(width, bg.partitionW)
}

func (bg *BoxGrid) BoxWidth(width, hstart, hend int) int {
	if width != bg.gridWidth_cached {
		bg.sizePartitionW_cached = bg.BoxWidthPartition(width)
	}
	sum := 0
	for i := hstart; i <= hend; i++ {
		sum += bg.sizePartitionW_cached[i]
	}
	return sum
}

func (bg *BoxGrid) BoxHeightPartition(height int) []int {
	return boxGrid_sizePartition(height, bg.partitionH)
}

func (bg *BoxGrid) BoxHeight(height, vstart, vend int) int {
	if height != bg.gridHeight_cached {
		bg.sizePartitionH_cached = bg.BoxHeightPartition(height)
	}
	sum := 0
	for i := vstart; i <= vend; i++ {
		sum += bg.sizePartitionH_cached[i]
	}
	return sum
}

func (bg *BoxGrid) UpdateGrid(width, height int) {
	bg.gridHeight_cached = height
	bg.gridWidth_cached = width
	bg.sizePartitionW_cached = boxGrid_sizePartition(width, bg.partitionW)
	bg.sizePartitionH_cached = boxGrid_sizePartition(height, bg.partitionH)
}
