import { describe, expect, it } from 'vitest'

import { BoundaryError } from '@/errors'

class TaskStorePersistenceError extends BoundaryError {}

describe('BoundaryError', () => {
  it('derives name from the subclass and preserves the original error as cause', () => {
    const original = new Error('connection refused')

    const wrapped = new TaskStorePersistenceError('failed to save', original)

    expect({
      name: wrapped.name,
      message: wrapped.message,
      causeIsOriginal: wrapped.cause === original,
    }).toEqual({
      name: 'TaskStorePersistenceError',
      message: 'failed to save',
      causeIsOriginal: true,
    })
  })
})
