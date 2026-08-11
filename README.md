# Polished xmin-inspired Quarto website

This is a minimal academic homepage inspired by the Hugo `xmin` style, adapted for Quarto.

## Files

- `_quarto.yml`: Quarto website configuration
- `index.qmd`: homepage content
- `cv/cv.qmd`: CV source, rendered to `docs/cv/cv.pdf`
- `notes/`: methodological notes, each rendered to a standalone PDF plus an `index.qmd` listing page
- `styles.css`: minimal polished CSS

## Render

```bash
quarto render
```

The rendered website will be created in `docs/`, ready for GitHub Pages.

## Notes

- Replace links or publication entries as needed.
- The design intentionally avoids Quarto navbar, sidebar, search, and heavy Bootstrap styling.
