# K

Personal technical notes by Jiale.

The site is based on [al-folio](https://github.com/alshedivat/al-folio) v1.2 and is published at [https://jiale0584.github.io](https://jiale0584.github.io).

## Local development

Docker is the supported local workflow:

```bash
docker compose pull
docker compose up
```

Then open [http://localhost:8090](http://localhost:8090).

## GitHub Pages

The official al-folio GitHub Actions workflow in `.github/workflows/deploy.yml` builds from `main` and publishes the `gh-pages` branch.

Live site: [https://jiale0584.github.io](https://jiale0584.github.io)
