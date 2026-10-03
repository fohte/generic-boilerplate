import { describe, expect, it } from 'vitest'

import { BoundaryError } from '#errors'

class TaskStorePersistenceError extends BoundaryError {}

describe('BoundaryError', () => {
  it('derives the name from the subclass and preserves the message', () => {
    const wrapped = new TaskStorePersistenceError('failed to save')

    const actual = {
      name: wrapped.name,
      message: wrapped.message,
    }

    expect(actual).toEqual({
      name: 'TaskStorePersistenceError',
      message: 'failed to save',
    })
  })

  it('preserves the original error as cause', () => {
    const original = new Error('connection refused')
    const wrapped = new TaskStorePersistenceError('failed to save', original)
    expect(wrapped.cause).toBe(original)
  })
})
