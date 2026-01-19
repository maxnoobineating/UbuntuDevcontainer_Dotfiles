package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type model struct {
	title  string
	text   string
	width  int
	height int
}

func initialModel() (m model) {
	return model{
		title:  "Multi Panel",
		text:   "this is a test\n",
		width:  50,
		height: 20,
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		{
			switch msg.String() {
			case "q":
				return m, tea.Quit
			case "+":
				m.width += 10
				m.height += 5
			case "-":
				m.width -= 10
				m.height -= 5
			case "a":
				return m, tea.EnterAltScreen // go to alt buffer
			case "e":
				return m, tea.ExitAltScreen // back to normal buffer

			default:
				m.title += fmt.Sprintf("key pressed: %s\n", msg.String())
			}
		}
	case tea.WindowSizeMsg:
		{
			m.width, m.height = msg.Width, msg.Height
			m.title = fmt.Sprintf("width: %d, height %d\n", msg.Width, msg.Height)
		}
	}
	return m, nil
}

var (
	border       = lipgloss.NewStyle().Border(lipgloss.RoundedBorder())
	focusBorder  = border.Copy().BorderForeground(lipgloss.Color("212"))
	normalBorder = border.Copy().BorderForeground(lipgloss.Color("240"))
)

func FitWidth(s lipgloss.Style, width int) lipgloss.Style {
	fx, _ := s.GetFrameSize()
	return s.Width(max(0, width-fx))
}
func FitHeight(s lipgloss.Style, height int) lipgloss.Style {
	_, fy := s.GetFrameSize()
	return s.Height(max(0, height-fy))
}
func FitSize(s lipgloss.Style, width, height int) lipgloss.Style {
	fx, fy := s.GetFrameSize()
	return s.Width(max(0, width-fx)).Height(max(0, height-fy))
}

func (m model) View() string {
	view := fmt.Sprintf("%s\n\n%s\n", m.title, m.text)
	view += fmt.Sprintf("m.width, m.height: %d, %d\n", m.width, m.height)
	var lwidth, lheight int = m.width / 2, m.height / 2
	var rwidth, rheight int = m.width - lwidth - 2, m.height - lheight - 2
	// var rwidth, rheight int = m.width - lwidth, m.height - lheight
	lwidth -= 2
	lheight -= 2
	// lstyle := FitSize(normalBorder, lwidth, lheight)
	// lfx, lfy := lstyle.GetFrameSize()
	// rstyle := FitSize(focusBorder, rwidth, rheight)
	// rfx, rfy := rstyle.GetFrameSize()
	// lscreen := lstyle.Render(view + fmt.Sprintf("framsize: %d, %d\n", lfx, lfy))
	// rscreen := rstyle.Render(view + fmt.Sprintf("framsize: %d, %d\n", rfx, rfy))
	lscreen := normalBorder.Width(lwidth).Height(lheight).Render(view + "lscreen\n" + fmt.Sprintf("windowSize: %d, %d\n", lwidth, lheight))
	rscreen := normalBorder.Width(rwidth).Height(rheight).Render(view + "rscreen\n" + fmt.Sprintf("windowSize: %d, %d\n", rwidth, rheight))
	return lipgloss.JoinVertical(lipgloss.Top, lscreen, rscreen)
	// return normalBorder.MaxWidth(m.width).MaxHeight(m.height).Render(view)
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
