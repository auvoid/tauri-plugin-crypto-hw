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

export async function getPublicKey(identifier: string): Promise<string> {
  return await invoke<{publicKey: string}>('plugin:crypto|get_public_key', {
    payload: {
      identifier
    }
  }).then((r) => (r.publicKey))
}

export async function signPayload(identifier: string, payload: string): Promise<string> {
  return await invoke<{signature: string}>('plugin:crypto|sign_payload', {
    "payload": {
      payload,
      identifier
    }
  }).then((r) => (r.signature))
}

export async function verifySignature(identifier: string, payload: string, signature: string): Promise<boolean> {
  return await invoke<{valid: boolean}>('plugin:crypto|verify_signature', {
    "payload": {
      identifier,
      payload,
      signature
    }
  }).then((r) => (r.valid))
}
