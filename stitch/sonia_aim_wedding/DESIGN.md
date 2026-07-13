---
name: Sonia & Aimé Wedding
colors:
  surface: '#fff8f5'
  surface-dim: '#e1d8d4'
  surface-bright: '#fff8f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fbf2ed'
  surface-container: '#f5ece7'
  surface-container-high: '#efe6e2'
  surface-container-highest: '#e9e1dc'
  on-surface: '#1e1b18'
  on-surface-variant: '#54433e'
  inverse-surface: '#34302c'
  inverse-on-surface: '#f8efea'
  outline: '#87736d'
  outline-variant: '#dac1bb'
  surface-tint: '#944932'
  primary: '#914630'
  on-primary: '#ffffff'
  primary-container: '#af5e46'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb59f'
  secondary: '#48626f'
  on-secondary: '#ffffff'
  secondary-container: '#cbe7f6'
  on-secondary-container: '#4e6875'
  tertiary: '#625b51'
  on-tertiary: '#ffffff'
  tertiary-container: '#7b7469'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd1'
  primary-fixed-dim: '#ffb59f'
  on-primary-fixed: '#3b0a00'
  on-primary-fixed-variant: '#76321d'
  secondary-fixed: '#cbe7f6'
  secondary-fixed-dim: '#afcbd9'
  on-secondary-fixed: '#011f29'
  on-secondary-fixed-variant: '#304a56'
  tertiary-fixed: '#ebe1d4'
  tertiary-fixed-dim: '#cfc5b9'
  on-tertiary-fixed: '#1f1b13'
  on-tertiary-fixed-variant: '#4c463c'
  background: '#fff8f5'
  on-background: '#1e1b18'
  surface-variant: '#e9e1dc'
typography:
  display:
    fontFamily: Noto Serif
    fontSize: 48px
    fontWeight: '400'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.0'
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  section-gap: 80px
  content-gap: 24px
  margin-page: 32px
  max-width: 1100px
---

## Brand & Style

This design system is built upon the themes of timeless romance and modern sophistication. It targets family and friends of Sonia & Aimé Francis, evoking a sense of warmth, intimacy, and high-end celebration. 

The aesthetic is a blend of **Minimalism** and **Editorial Design**. It prioritizes generous whitespace and a rhythmic vertical flow to create a relaxed, breathable reading experience. While the layout is clean and modern, the soul of the design is found in its organic color palette and delicate motion, ensuring the interface feels like a digital keepsake rather than a utility.

## Colors

The palette is anchored by **Terracotta**, a warm, earthy orange that symbolizes the grounding nature of the couple’s union. This is balanced by **Dusty Blue**, used for accents and secondary interactive elements to provide a cooling, sophisticated contrast.

The background should avoid pure white (#FFFFFF), utilizing a soft **Cream or Off-white** (#FAF9F6) to mimic the texture of fine stationery. Text is set in a deep, warm charcoal to maintain legibility while avoiding the harshness of pure black.

## Typography

This design system employs a classic typographic pairing. **Noto Serif** provides the editorial authority and elegance required for headings and names (Sonia & Aimé). **Manrope** is used for body copy and logistical details to ensure clarity and a contemporary touch.

For French text, pay special attention to ligatures and the use of non-breaking spaces before punctuation (like « ! » or « : ») to preserve the high-end feel of the invitation.

## Layout & Spacing

The layout follows a **Fixed Grid** approach for the main content container, ensuring that the invitation feels structured and centered like a traditional card. On mobile, the system transitions to a fluid model with generous side margins.

Spacing is intentional and expansive. Use large vertical gaps between sections to allow the couple’s photography and the French prose to stand as distinct "chapters" of the story.

## Elevation & Depth

Depth is communicated through **Ambient Shadows** and **Tonal Layering**. Avoid heavy, dark drop-shadows; instead, use soft, diffused shadows with a slight Terracotta tint to make cards and buttons appear as if they are resting lightly on the cream background.

Subtle background blurs (backdrop filters) can be used on navigation bars or modal overlays to maintain a sense of lightness and transparency.

## Shapes

The shape language is **Soft**. UI elements like buttons and containers feature a small corner radius (4px to 8px). This mimics the slight rounding of premium heavy-weight cardstock. Avoid perfectly circular buttons (pills) unless used for small iconography, as the "Soft" setting better aligns with the sophisticated serif typography.

## Components

### Buttons
Primary buttons use the Terracotta fill with white text. Hover states should involve a subtle shift to a deeper shade or a gentle scale-up animation. Secondary "RSVP" or "Details" buttons should use an outline style with Dusty Blue.

### Input Fields
Forms (like the RSVP) use "Ghost" style inputs: a single bottom border or a very light Dusty Blue stroke. Labels should be small and uppercase using the `label-sm` style.

### Cards
Cards for event locations or gift registries should have a background color slightly different from the page (e.g., the Tertiary #E8DED1) with no borders and very soft shadows.

### Animations
Implement "Fade-in-up" transitions for text blocks as the user scrolls. Transitions should be slow (600ms+) and use a "Cubic Bezier" easing to feel graceful and fluid.

### Date Highlights
A custom calendar component should highlight the wedding date using a Terracotta circle or a hand-drawn floral accent, reminiscent of the reference imagery.