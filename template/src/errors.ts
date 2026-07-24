// Wrap a caught external error before re-throwing, so it carries a
// domain-meaningful message while preserving the original via `cause`.
// Subclass per interop boundary (see eslint.config.js's
// errorHandling.interopBoundaryFiles) — `name` is derived automatically, so
// no constructor override is needed:
//
//   export class TaskStorePersistenceError extends BoundaryError {}
export abstract class BoundaryError extends Error {
  constructor(message: string, cause: unknown) {
    super(message, { cause })
    this.name = new.target.name
  }
}
