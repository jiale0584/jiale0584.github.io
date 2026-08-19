---
layout: post
title: Notes on Post-training
date: 2026-08-12 10:00:00
description: A short placeholder for Python and Bash code blocks.
tags: [code, notes]
giscus_comments: false
related_posts: false
toc:
  sidebar: left
---

This page checks syntax highlighting and nested headings. The snippets are examples only.

## Setup

A post-training note usually starts with the command used to launch the job.

### Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install torch transformers
```

### Config

```json
{
  "model": "placeholder-lm",
  "lr": 2e-5,
  "max_steps": 1000
}
```

## Training

The following snippet is only here to confirm Python highlighting.

### Policy update

```python
def advantage(rewards, values, gamma=0.99):
    returns = []
    g = 0.0
    for r, v in zip(reversed(rewards), reversed(values)):
        g = r + gamma * g
        returns.append(g)
    returns.reverse()
    return [g - v for g, v in zip(returns, values)]


if __name__ == "__main__":
    print(advantage([1.0, 0.0, 1.0], [0.3, 0.2, 0.4]))
```

## Check

If the blocks above keep their language colors in both light and dark mode, this page has done its job.
