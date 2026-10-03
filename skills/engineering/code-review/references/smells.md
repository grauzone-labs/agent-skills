# Smell baseline

Apply this Fowler (_Refactoring_, ch. 3) baseline when reviewing standards. A repository standard overrides it. Report every match as a labelled judgement call, not a hard violation, and omit behavior enforced by tooling.

- **Mysterious Name** - a function, variable, or type does not reveal what it does or holds. Rename it; if no honest name comes, clarify the design.
- **Duplicated Code** - the same logic shape appears in more than one changed hunk or file. Extract the shared shape.
- **Feature Envy** - a method reaches into another object's data more than its own. Move the method onto the data it envies.
- **Data Clumps** - the same fields or parameters travel together. Bundle them in a type.
- **Primitive Obsession** - a primitive stands in for a domain concept. Give the concept a small type.
- **Repeated Switches** - a `switch` or `if` cascade over the same type recurs. Replace it with polymorphism or one shared map.
- **Shotgun Surgery** - one logical change scatters across many files. Gather what changes together.
- **Divergent Change** - a file changes for unrelated reasons. Split by reason to change.
- **Speculative Generality** - abstraction, parameters, or hooks serve needs absent from the spec. Inline until a real need appears.
- **Message Chains** - callers navigate a long `a.b().c().d()` chain. Hide the walk behind the first object.
- **Middle Man** - a class or function mostly delegates. Call the real target directly.
- **Refused Bequest** - a subclass or implementer ignores or overrides most inherited behavior. Prefer composition.
