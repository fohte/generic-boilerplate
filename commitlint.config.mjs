import { execSync } from 'child_process'

function getCurrentRepo() {
  try {
    const url = execSync('git remote get-url origin', {
      encoding: 'utf-8',
    }).trim()
    const match = url.match(/github\.com[:/]([^/]+\/[^/.]+)/)
    return match ? match[1].replace(/\.git$/, '') : null
  } catch {
    return null
  }
}

// Custom plugin for detecting external GitHub references
const noExternalGitHubRefsPlugin = {
  rules: {
    'no-external-github-refs': ({ raw }, when) => {
      const currentRepo = getCurrentRepo()
      if (!currentRepo) return [true]

      const [owner, repo] = currentRepo.split('/')

      // Detection patterns
      const patterns = [
        // Full GitHub URLs: https://github.com/owner/repo/...
        /https?:\/\/github\.com\/([^/]+)\/([^/\s#]+)/g,
        // Cross-repo issue/PR references: owner/repo#123
        /(?<![a-zA-Z0-9_/-])([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_.-]+)#\d+/g,
      ]

      const externalRefs = []
      for (const pattern of patterns) {
        for (const match of raw.matchAll(pattern)) {
          const [, matchOwner, matchRepo] = match
          const cleanRepo = matchRepo.replace(/\.git$/, '')
          if (matchOwner !== owner || cleanRepo !== repo) {
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
    },
  },
}

export default {
  // Rules from @commitlint/config-conventional
  // See: https://github.com/conventional-changelog/commitlint/blob/master/%40commitlint/config-conventional/src/index.ts
  rules: {
    'body-leading-blank': [1, 'always'],
    'body-max-line-length': [2, 'always', 100],
    'footer-leading-blank': [1, 'always'],
    'footer-max-line-length': [2, 'always', 100],
    'header-max-length': [2, 'always', 100],
    'header-trim': [2, 'always'],
    'subject-case': [
      2,
      'never',
      ['sentence-case', 'start-case', 'pascal-case', 'upper-case'],
    ],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'type-enum': [
      2,
      'always',
      [
        'build',
        'chore',
        'ci',
        'docs',
        'feat',
        'fix',
        'perf',
        'refactor',
        'revert',
        'style',
        'test',
      ],
    ],
    // Custom rule
    'no-external-github-refs': [2, 'always'],
  },
  plugins: [noExternalGitHubRefsPlugin],
}
