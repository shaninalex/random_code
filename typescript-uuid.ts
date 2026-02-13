declare const __brand: unique symbol

type Brand<T, B> = T & { readonly [__brand]: B }

// UUID scalar - 36 character string in format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export type UUID = Brand<string, 'UUID'>

// Type guard for UUID validation
export function isUUID(value: string): value is UUID {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
}

// Helper to assert a string is a UUID (throws if invalid)
export function asUUID(value: string): UUID {
    if (!isUUID(value)) {
        throw new Error(`Invalid UUID: ${value}`)
    }
    return value
}
