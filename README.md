# golazy.dev

Hugo marketing website and Go vanity-import host for `golazy.dev`.

The site includes versioned Hugo guides under `/guides/<version>/`. `/guides/`
points to the latest published version. Guide content lives in
`content/guides/<version>`, navigation metadata in `data/guides.toml`, version
metadata in `data/guide_versions.toml`, and templates in `layouts/guides`.

## Development

```bash
hugo server
```

The development server is available at `http://localhost:1313`.

## Production build

```bash
hugo --minify
```

The generated site is written to `public/`. The `CNAME` file and all other
public assets are copied from `static/`.
