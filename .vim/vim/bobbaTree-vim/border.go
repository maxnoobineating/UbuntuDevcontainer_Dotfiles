package box

func IsSharedBorder(b1, b2 Border) bool {
	return b1.SharesBorderWith(b2) && b2.SharesBorderWith(b1)
}

type Border interface {
	GetPosition() Unit
	SharesBorderWith(Border) bool
	// GrowIntoBy(Border, Unit)
}

type SharedBorder struct {
	pos int
}

func (b *SharedBorder) GetPosition() Unit {
	return UnitPx(1)
}

type AbstractBorder struct {
	getposFunc func() Unit
}

func (b *AbstractBorder) GetPosition() Unit {
	return b.getposFunc()
}
