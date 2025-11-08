# Design System Examples

This directory contains live examples and sample pages demonstrating the Oceanic theme's design system components.

## Example Pages

### Component Demonstrations

**`buttons.html`**
- Complete button system showcase
- Demonstrates all button styles and color variations
- Shows primary and secondary button types
- Includes color modifiers: cyan, amber, orange, red
- Live examples of hover states and interactions

**`badges.html`**
- Category badge system examples
- Non-interactive label components
- Color variations: cyan, emerald, amber, red, purple
- Gradient backgrounds and styling
- Usage in content categorization

**`categories.html`**
- Filter button system showcase
- Interactive selection/filtering components
- Color variations with active states
- Dropdown overflow handling
- Count badges demonstration

## Purpose

These pages serve as:
- **Design Reference**: Visual documentation of component styles
- **Development Guide**: Examples for implementing components
- **Testing Playground**: Verify styling changes don't break components
- **Onboarding Resource**: Help new contributors understand the design system

## Design System Overview

The Oceanic theme uses a comprehensive component-based design system:

### Color Palette (Electric Blue + Warm Accents)
- **Primary**: Cyan (#06b6d4) - Brand color, main accent
- **Secondary**: Amber (#f59e0b) - Warm accent, secondary branding
- **Accent Colors**: Orange, Red, Emerald, Purple
- **Backgrounds**: Four-level elevation system (darker to lighter)

### Component Categories

**Action Buttons** (`buttons.html`):
- Purpose: User actions and navigation
- Size: Larger padding (0.875rem)
- Default: Emerald green
- Variations: Cyan, amber, orange, red
- States: Default, hover (lift + glow)

**Filter Buttons** (`categories.html`):
- Purpose: Content filtering and selection
- Size: Smaller padding (0.5rem)
- Default: Cyan
- Variations: Emerald, amber, red
- States: Default, hover, active (persistent)
- Features: Count badges, dropdown support

**Category Badges** (`badges.html`):
- Purpose: Visual labels and tags
- Size: Smallest padding (0.25rem)
- Non-interactive: No hover or click states
- Gradients: Three-color gradients for depth
- Variations: Cyan, emerald, amber, red, purple

### Usage Guidelines

**When to use each component type:**

- **Buttons**: For actions like "Download", "View Project", "Submit"
- **Filter Buttons**: For selecting categories, filtering content
- **Badges**: For labeling content, showing status, displaying tags

## Viewing Examples

### Local Development

Start Jekyll server and view examples:

```bash
bundle exec jekyll serve --livereload

# Visit examples:
# http://localhost:4000/docs/examples/buttons.html
# http://localhost:4000/docs/examples/badges.html
# http://localhost:4000/docs/examples/categories.html
```

### Production

These pages are NOT linked in site navigation but are accessible directly:
- https://christaylor.codes/docs/examples/buttons.html
- https://christaylor.codes/docs/examples/badges.html
- https://christaylor.codes/docs/examples/categories.html

## Using Components in Your Pages

### Button Example

```html
<!-- Standard button (emerald green) -->
<a href="/download" class="btn btn-primary">Download</a>

<!-- Cyan brand button -->
<a href="/github" class="btn btn-primary btn-cyan">
    <i class="fab fa-github"></i> View on GitHub
</a>

<!-- Secondary outlined button -->
<a href="/learn-more" class="btn btn-secondary">Learn More</a>
```

### Filter Button Example

```html
<div class="filter-buttons">
    <button class="filter-btn active">All Posts</button>
    <button class="filter-btn">PowerShell <span class="filter-count">12</span></button>
    <button class="filter-btn filter-emerald">Tutorial</button>
</div>
```

### Badge Example

```html
<div class="post-card-categories">
    <span class="category-badge">PowerShell</span>
    <span class="category-badge badge-emerald">Stable</span>
    <span class="category-badge badge-purple">New</span>
</div>
```

## Component Styling

All component styles are defined in modular SCSS files:

- Buttons: [_sass/oceanic/_buttons.scss](../../_sass/oceanic/_buttons.scss)
- Filter Buttons: [_sass/oceanic/_posts.scss](../../_sass/oceanic/_posts.scss#L144-L276)
- Badges: [_sass/oceanic/_posts.scss](../../_sass/oceanic/_posts.scss#L379-L435)

## Testing Changes

When modifying component styles:

1. Make changes to the appropriate SCSS partial
2. View the example page to verify changes
3. Test all color variations
4. Verify hover states work correctly
5. Check responsive behavior (mobile/tablet)
6. Ensure accessibility (contrast ratios)

## See Also

- [CLAUDE.md - Design System](../../CLAUDE.md#styling-and-design) - Complete design documentation
- [CLAUDE.md - Button System](../../CLAUDE.md#button-system) - Button usage guide
- [CLAUDE.md - Filter Buttons](../../CLAUDE.md#filter-button-system) - Filter button reference
- [CLAUDE.md - Category Badges](../../CLAUDE.md#category-badge-system) - Badge documentation
