module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: ['./templates/**/*.html'],
  plugins: [require('@tailwindcss/typography')],
}
