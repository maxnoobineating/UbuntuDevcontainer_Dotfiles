package box

type Unit interface {
	// Px() int
}

type UnitPx int
type UnitGrid float64
type UnitGridWeight uint
type UnitDoublePx int
type UnitSame bool       // placeholder type -> non-changing
type UnitFitCell float64 // fit cell size -> error if

// type UnitChar struct {
// 	px int
// }

// func (u *UnitChar) Px() int {
// 	return u.px
// }

// type UnitDoubleChar struct {
// 	// for rendering proportional width vs height, cuz character height ~ 2x width
// }

// type UnitViewPort struct {
// }

// type UnitContainer struct {
// }
