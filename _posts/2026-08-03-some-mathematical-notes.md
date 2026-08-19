---
layout: post
title: Some Mathematical Notes
date: 2026-08-03 10:00:00
description: A short placeholder for inline and display MathJax.
categories: [Mathematics]
tags: [math, notes]
giscus_comments: false
related_posts: false
toc:
  sidebar: left
---

This page checks that MathJax is working. The statements below are standard facts, not a real paper.

## Inline math

The Gaussian integral is $$ \int_{-\infty}^{\infty} e^{-x^2}\, dx = \sqrt{\pi} $$. For a vector $$ x \in \mathbb{R}^n $$, write $$ \|x\|_2 = \sqrt{x^\top x} $$.

## Display math

The Cauchy--Schwarz inequality says

$$
\left( \sum_{k=1}^n a_k b_k \right)^2 \le \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right).
$$

An expectation form of the same idea is

\begin{equation}
\label{eq:expectation}
\bigl(\mathbb{E}[XY]\bigr)^2 \le \mathbb{E}[X^2]\,\mathbb{E}[Y^2].
\end{equation}

## Reference

If numbered equations work, \eqref{eq:expectation} should resolve to the display above.
