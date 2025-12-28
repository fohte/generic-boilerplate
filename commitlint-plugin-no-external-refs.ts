import { execSync } from 'child_process'
import type { Plugin, Rule } from '@commitlint/types'

export interface NoExternalGitHubRefsOptions {
  /** Override the current repository (format: "owner/repo") */
  currentRepo?: string
  /** Additional repositories to allow references to */
  allowedRepos?: string[]
}

let memoizedRepo: string | null | undefined

function getCurrentRepo(): string | null {
  if (memoizedRepo !== undefined) {
    return memoizedRepo
  }
  try {
    const url = execSync('git remote get-url origin', {
      encoding: 'utf-8',
    }).trim()
    const match = url.match(/github\.com[:/]([^/]+\/[^/]+)/)
    memoizedRepo = match ? match[1].replace(/\.git$/, '') : null
    return memoizedRepo
  } catch {
    memoizedRepo = null
    return null
  }
}

export const noExternalGitHubRefs: Rule<NoExternalGitHubRefsOptions> = (
  parsed,
  when,
  value
) => {
  const options = value || {}
  const currentRepo = options.currentRepo || getCurrentRepo()
  if (!currentRepo) return [true]

  const allowedRepos = new Set([
    currentRepo.toLowerCase(),
    ...(options.allowedRepos || []).map((r) => r.toLowerCase()),
  ])

  // Detection patterns
  const patterns = [
    // Full GitHub URLs: https://github.com/owner/repo/...
    /https?:\/\/github\.com\/([^/]+)\/([^/\s#]+)/g,
    // Cross-repo issue/PR references: owner/repo#123
    /(?<![a-zA-Z0-9_/-])([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_.-]+)#\d+/g,
  ]

  const externalRefs: string[] = []
  for (const pattern of patterns) {
    for (const match of parsed.raw.matchAll(pattern)) {
      const [, matchOwner, matchRepo] = match
      const cleanRepo = matchRepo.replace(/\.git$/, '')
      const fullRepo = `${matchOwner}/${cleanRepo}`.toLowerCase()
      if (!allowedRepos.has(fullRepo)) {
        externalRefs.push(match[0])
      }
    }
  }

  const valid =
    when === 'always' ? externalRefs.length === 0 : externalRefs.length > 0
  return [
    valid,
    `External GitHub references are not allowed: ${externalRefs.join(', ')}`,
  ]
}

const plugin: Plugin = {
  rules: {
    'no-external-github-refs': noExternalGitHubRefs,
  },
}

export default plugin
