import colors from "tailwindcss/colors";

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    colors: {
      'blue': {
        '50': '#f0f7fe',
        '100': '#deecfb',
        '200': '#c4e0f9',
        '300': '#9cccf4',
        '400': '#6dafed',
        '500': '#4b90e6',
        '600': '#3674da',
        '700': '#2d60c8',
        '800': '#2a4fa3',
        '900': '#274481',
        '950': '#0f172a',
      },
      'mantis': {
        '50': '#f6faf3',
        '100': '#e9f5e3',
        '200': '#d3eac8',
        '300': '#afd89d',
        '400': '#82bd69',
        '500': '#61a146',
        '600': '#4c8435',
        '700': '#3d692c',
        '800': '#345427',
        '900': '#2b4522',
        '950': '#13250e',
      },
      red: {
        '50': '#fff0f1',
        '100': '#ffdee1',
        '200': '#ffc2c7',
        '300': '#ff97a0',
        '400': '#ff5c6b',
        '500': '#ff293c',
        '600': '#f90e23',
        '700': '#d20315',
        '800': '#ad0716',
        '900': '#8f0d19',
        '950': '#4e0108',
      },
      current: 'currentColor',
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      emerald: colors.emerald,
      indigo: colors.indigo,
      yellow: colors.yellow,
    },
    extend: {},
  },
  plugins: [],
}

