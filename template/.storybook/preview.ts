import { withThemeByClassName } from '@storybook/addon-themes'
import type { Preview } from '@storybook/react-vite'

import '#index.css'

const preview: Preview = {
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
