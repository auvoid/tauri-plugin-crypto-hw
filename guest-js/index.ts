import { invoke } from '@tauri-apps/api/core'

export async function generate(identifier: string): Promise<string> {
  return await invoke<{message: string}>('plugin:crypto|generate', {
    payload: {
      identifier
    }
  }).then((r) => (r.message))
}

export async function exists(identifier: string): Promise<boolean> {
  return await invoke<{exists: boolean}>('plugin:crypto|exists', {
    payload: {
      identifier
    }
  }).then((r) => (r.exists))
}

export async function getPublicKey(identifier: string): Promise<Uint8Array> {
  return await invoke<{publicKey: Uint8Array}>('plugin:crypto|get_public_key', {
    payload: {
      identifier
    }
  }).then((r) => (r.publicKey))
}
