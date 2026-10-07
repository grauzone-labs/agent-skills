# Dark mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in `ThemeConfig`, resolved at build time. Theming is a concern for downstream consumers who embed or redistribute the output.

## Prior requests

- #42 - "Add dark mode support"
