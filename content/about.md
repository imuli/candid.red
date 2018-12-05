---
title: About
---

Candid is a programming language that aims to refactor the mechanics of programming.

We should be able to

* exercise version control at the granularity of functions rather than files or modules
* each use our preferred names (`Maybe` vs `Optional` vs `?`) while editing the same code
* introduce new language features without breaking backwards compatibility
* reason about termination (and non-termination), runtime, and memory use

To this end, Candid source code is not mutable blobs of text, but rather
immutable hashed directed acyclic graph mapping from a version of lambda
calculus with extensions for fancy typing, recursion, and explicit proofs.
For actual programming, the editor translates this low level representation
into a high level syntax tree for the programmer to edit, with the programmer's
preferred names and style of syntax.

Candid's core has a number of significant differences from typical λ-calculus.
The most unusual (from a mathematics and type theory perspective) is explicit
recursion, which we will designate with ◯. We also use de Bruijn style numbers
rather than variables, and then add dependent types and equality types.

This lets us define recursive types in a straightforward manner, for example
the typical recursive definition for Natural numbers:

```idris
data Nat = Z | S (n:Nat)
```

gets expanded to:

```idris
      ◯            ◯                  ◯
  Nat/ \         Z/ \                / \
    ★   π       Nat  λ             S/   λ
      r/ \         r/ \            /  n/ \
      ★   π        ★   λ          π  Nat  λ
        z/ \         z/ \       n/ \    r/ \
        r   π        r   λ     Nat Nat  ★   λ
          s/ \         s/ \               z/ \
          π   r        π   z              r   λ
         / \          / \                   s/ \
       Nat  r       Nat  r                  π   \
                                           / \   $
                                         Nat  r / \
                                               s   n
```

We can of course also use a Church-encoded Nats, but this encoding has a
constant time predecessor. `◯` isn't necessary for the definition of `Z` or
`S`, but it's a convenient place to store names and type annotations, if we
don't actually _refer_ back to the `◯` it doesn't change the program at all.

As `◯` asserts a type, `Z` and `S` are not quite correct. We (or the editors)
need to store how `r:* π z:r π s:(Nat π r) π r` is equal to `Nat`, so we need
to indicate a single ◯-expansion on `Nat` to show equality.

The requirement to explicitly prove everything is mostly due to that third goal -
any additional cleverness in type inference may not introduce incompatibilities
between new and old versions. It also makes type checking decidable, and allows
the programmer to step in and manually prove equality or termination where the
type inference system in the editor cannot.

The proof representation - for both termination and equality - is currently in flux.
