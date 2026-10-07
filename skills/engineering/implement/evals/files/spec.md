# Spec: slugify titles

## Behavior

`slugify(title)` in `src/slug.ts` turns a title into a URL slug: lowercase, words joined by single hyphens, no leading or trailing hyphen.

## Test seams

- `slugify` exported from `src/slug.ts`, tested through `tests/slug.test.ts`.

## Acceptance criteria

- [ ] `slugify("Hello World")` returns `hello-world`.
- [ ] `slugify("  Trim  me  ")` returns `trim-me`.
- [ ] `slugify("Ünïcödé")` returns `unicode`, verified by a maintainer on the production build.
