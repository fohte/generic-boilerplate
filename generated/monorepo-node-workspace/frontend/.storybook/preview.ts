import { withThemeByClassName } from '@storybook/addon-themes'
import type { ProjectAnnotations } from 'storybook/internal/csf'

const preview: ProjectAnnotations = {
  decorators: [
    withThemeByClassName({
      themes: {
        light: '',
        dark: 'dark',
      },
      defaultTheme: 'light',
    }),
  ],
}

export default preview
