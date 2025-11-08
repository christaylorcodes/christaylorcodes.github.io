# Design Prototypes

This directory contains design prototypes and exploration work for the christaylor.codes website. These files document the design evolution and serve as reference for future design decisions.

## About Page Design Prototypes

During the initial website development (November 2024), five different design concepts were explored for the About page before settling on the final design.

### Design Briefs

**`ABOUT-PAGE-DESIGN-BRIEF.md`**
- Original design requirements and constraints
- Design goals and user experience objectives
- Technical considerations and accessibility requirements

### Prototype Designs

**`about-design-1-terminal.html`** - Terminal/CLI Theme
- Concept: Developer-focused terminal aesthetic
- Features: Command-line inspired layout, monospace fonts, ASCII art
- Style: Highly technical, geek-oriented

**`about-design-2-resume.html`** - Resume/CV Format
- Concept: Traditional resume layout
- Features: Timeline, skills matrix, formal structure
- Style: Professional, business-oriented

**`about-design-3-cards.html`** - Card-Based Layout
- Concept: Modern card UI with sectioned content
- Features: Modular cards, visual hierarchy through elevation
- Style: Clean, contemporary web design

**`about-design-4-split.html`** - Split-Screen Design
- Concept: Two-column layout with photo emphasis
- Features: Large profile image, content/visual balance
- Style: Magazine-style, visual storytelling

**`about-design-5-minimal.html`** - Minimal/Zen Design
- Concept: Maximum simplicity, minimal UI elements
- Features: Focused content, ample whitespace, typography-driven
- Style: Elegant, understated

### Final Design Selection

The production About page combines elements from multiple prototypes:
- **Photo Section**: Inspired by split-screen design (Design 4)
- **Stats Highlights**: Card-based modular approach (Design 3)
- **Quick Facts Sidebar**: Resume format structure (Design 2)
- **Overall Aesthetic**: Minimal design with Oceanic theme colors

Key decisions:
- Chose cards for modularity and mobile responsiveness
- Included photo for personal connection
- Added metrics/stats to demonstrate impact
- Maintained consistent Oceanic color palette across all sections

## Viewing Prototypes

To view the HTML prototypes locally:

1. Open files directly in a web browser (they are self-contained)
2. Or serve through Jekyll for full context:
   ```bash
   bundle exec jekyll serve
   # Visit http://localhost:4000/prototypes/about-design-1-terminal.html
   ```

Note: Prototypes may have broken asset links or outdated styling as they were created before the final theme structure.

## Design Philosophy

The final design prioritizes:
- **Readability**: Clear typography and comfortable line lengths
- **Personality**: Balance between professional and approachable
- **Performance**: Lightweight, fast-loading pages
- **Accessibility**: High contrast, semantic HTML, screen reader friendly
- **Consistency**: Oceanic theme colors and patterns throughout

## Future Design Work

This directory serves as a reference for:
- Understanding design decisions and rationale
- Exploring alternative layouts for future pages
- Documenting the evolution of the site's visual identity
- Providing inspiration for redesigns or new sections

## See Also

- [CLAUDE.md](../CLAUDE.md) - Project maintenance guide
- [Oceanic Theme Documentation](../docs/archive/THEME-README.md) - Theme structure and styling
- [Design System](../CLAUDE.md#styling-and-design) - Color palette and component library
