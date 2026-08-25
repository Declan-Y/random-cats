import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import App from './App'

describe('App', () => {
  it('renders the heading', () => {
    render(<App />)
    expect(
      screen.getByRole('heading', { name: /a random picture of a cat/i }),
    ).toBeInTheDocument()
  })

  it('renders the cat photo pointing at the API proxy', () => {
    render(<App />)
    const img = screen.getByRole('img', { name: /a random cat/i })
    expect(img).toHaveAttribute('src', '/api/photo')
  })
})
