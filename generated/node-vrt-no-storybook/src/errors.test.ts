import { describe, expect, it } from 'vitest'

import { BoundaryError } from '#errors'

class TaskStorePersistenceError extends BoundaryError {}

describe('BoundaryError', () => {
  it('derives the name from the subclass and preserves the message', () => {
    const original = new Error('connection refused')
    const wrapped = new TaskStorePersistenceError('failed to save', original)

    expect(wrapped).toEqual({
      name: 'TaskStorePersistenceError',
      message: 'failed to save',
      cause: original,
    })
  })

  it('preserves the original error as cause', () => {
    const original = new Error('connection refused')
    const wrapped = new TaskStorePersistenceError('failed to save', original)

    expect(wrapped.cause).toBe(original)
  })
})
