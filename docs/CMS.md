# Writing posts

Daily writing uses hosted Pages CMS, not GitHub or a local editor.

1. Open https://app.pagescms.org
2. Sign in with GitHub as `jiale0584`
3. Open `jiale0584.github.io`
4. Edit **Posts**
5. Save. Pages CMS commits to GitHub, then Actions deploys https://jiale0584.github.io

Images go to `assets/img/blog/` via the CMS Media library. In the post body, write:

```markdown
![caption](/assets/img/blog/your-file.png)
```

The body editor is Markdown source, not WYSIWYG, so MathJax and fenced code stay intact.

Before changing blog code in this repo:

```bash
git pull --ff-only origin main
```

That picks up commits created by Pages CMS.
