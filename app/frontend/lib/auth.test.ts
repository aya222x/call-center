import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

describe('AuthService Cross-Tab Sync', () => {
  let localStorageMock: { [key: string]: string }

  beforeEach(() => {
    // Mock localStorage
    localStorageMock = {}
    global.localStorage = {
      getItem: vi.fn((key: string) => localStorageMock[key] || null),
      setItem: vi.fn((key: string, value: string) => {
        localStorageMock[key] = value
      }),
      removeItem: vi.fn((key: string) => {
        delete localStorageMock[key]
      }),
      clear: vi.fn(() => {
        localStorageMock = {}
      }),
      key: vi.fn(),
      length: 0
    } as Storage

    // Mock window.addEventListener and dispatchEvent
    global.window.addEventListener = vi.fn()
    global.window.removeEventListener = vi.fn()
    global.window.dispatchEvent = vi.fn()

    // Dynamically import authService to get fresh instance
    vi.resetModules()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  it('sets up storage event listener on initialization', async () => {
    // Import auth service (triggers constructor)
    await import('./auth')

    // Verify addEventListener was called with 'storage'
    expect(window.addEventListener).toHaveBeenCalledWith(
      'storage',
      expect.any(Function)
    )
  })

  it('dispatches auth:logout event when token is removed in another tab', async () => {
    await import('./auth')

    // Get the storage event listener that was registered
    const addEventListenerCalls = (window.addEventListener as any).mock.calls
    const storageListenerCall = addEventListenerCalls.find(
      (call: any[]) => call[0] === 'storage'
    )
    expect(storageListenerCall).toBeDefined()
    const storageListener = storageListenerCall[1]

    // Simulate storage event: token removed (logout in another tab)
    // Create plain object instead of StorageEvent (easier for testing)
    const storageEvent = {
      key: 'auth_token',
      oldValue: 'old-token-value',
      newValue: null,
    } as StorageEvent

    storageListener(storageEvent)

    // Verify auth:logout event was dispatched
    expect(window.dispatchEvent).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'auth:logout',
        detail: { crossTab: true },
      })
    )
  })

  it('dispatches auth:login event when token is added in another tab', async () => {
    await import('./auth')

    // Get the storage event listener
    const addEventListenerCalls = (window.addEventListener as any).mock.calls
    const storageListenerCall = addEventListenerCalls.find(
      (call: any[]) => call[0] === 'storage'
    )
    const storageListener = storageListenerCall[1]

    // Simulate storage event: token added (login in another tab)
    const storageEvent = {
      key: 'auth_token',
      oldValue: null,
      newValue: 'new-token-value',
    } as StorageEvent

    storageListener(storageEvent)

    // Verify auth:login event was dispatched
    expect(window.dispatchEvent).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'auth:login',
        detail: { crossTab: true },
      })
    )
  })

  it('ignores storage events for non-auth keys', async () => {
    await import('./auth')

    // Get the storage event listener
    const addEventListenerCalls = (window.addEventListener as any).mock.calls
    const storageListenerCall = addEventListenerCalls.find(
      (call: any[]) => call[0] === 'storage'
    )
    const storageListener = storageListenerCall[1]

    // Clear previous calls
    vi.clearAllMocks()

    // Simulate storage event for different key
    const storageEvent = {
      key: 'some_other_key',
      oldValue: 'old-value',
      newValue: null,
    } as StorageEvent

    storageListener(storageEvent)

    // Verify NO events were dispatched
    expect(window.dispatchEvent).not.toHaveBeenCalled()
  })
})
