import { invoke } from "@tauri-apps/api/core";

/**
 * @author SoSweetHam <soham@auvo.io>
 * @param identifier - The identifier of the keypair to generate
 * @returns A message indicating the result of the operation
 * @description
 * Generates a new keypair with the given identifier. If a keypair with the same identifier already exists, operation will fail, promise will reject but a message string will be returned in all cases.
 * @example
 * ```ts
 * import { generate } from '@auvo/tauri-plugin-crypto-hw-api'
 * const message = await generate('my-keypair-id');
 * console.log(message);
 * ```
 */
export async function generate(identifier: string): Promise<string> {
	return await invoke<{ message: string }>("plugin:crypto-hw|generate", {
		payload: {
			identifier,
		},
	}).then((r) => r.message);
}

/**
 * @author SoSweetHam <soham@auvo.io>
 * @param identifier - The identifier of the keypair to check for existence of
 * @returns A boolean indicating whether the keypair exists
 * @description
 * Checks if a keypair with the given identifier exists. If it does, the promise will resolve to true, otherwise it will resolve to false.
 * @example
 * ```ts
 * import { exists } from '@auvo/tauri-plugin-crypto-hw-api'
 * const keypairExists = await exists('my-keypair-id');
 * console.log(keypairExists); // true or false
 * ```
 */
export async function exists(identifier: string): Promise<boolean> {
	return await invoke<{ exists: boolean }>("plugin:crypto-hw|exists", {
		payload: {
			identifier,
		},
	}).then((r) => r.exists);
}

/**
 * @author SoSweetHam <soham@auvo.io>
 * @param identifier - The identifier of the public key to retrieve
 * @returns A string representing the public key in multibase hex format
 * @description
 * Retrieves a string based multibase hex representation of the public key associated with the given identifier. If the keypair does not exist, the promise will reject.
 * @example
 * ```ts
 * import { getPublicKey } from '@auvo/tauri-plugin-crypto-hw-api'
 * const publicKey = await getPublicKey('my-keypair-id');
 * console.log(publicKey); // "0x1234567890abcdef..."
 * ```
 */
export async function getPublicKey(identifier: string): Promise<string> {
	return await invoke<{ publicKey: string }>("plugin:crypto-hw|get_public_key", {
		payload: {
			identifier,
		},
	}).then((r) => r.publicKey);
}

/**
 * @author SoSweetHam <soham@auvo.io>
 * @param identifier - The identifier of the private key to retrieve
 * @param payload - The `message` to sign
 * @return A base58btc format string based signature of the payload using the private key associated with the given identifier
 * @description
 * Signs the given payload with the private key associated with the given identifier. The signature is returned as a base58btc format string. If the keypair does not exist, the promise will reject.
 * @example
 * ```ts
 * import { signPayload } from '@auvo/tauri-plugin-crypto-hw-api'
 * const signature = await signPayload('my-keypair-id', 'Hello, world!');
 * console.log(signature, payload); // "zQ1234567890abcdef..."
 * ```
 */
export async function signPayload(
	identifier: string,
	payload: string,
): Promise<string> {
	return await invoke<{ signature: string }>("plugin:crypto-hw|sign_payload", {
		payload: {
			payload,
			identifier,
		},
	}).then((r) => r.signature);
}

/**
 * @author SoSweetHam <soham@auvo.io>
 * @param identifier - The identifier of the keypair to verify the signature against
 * @param payload - The `message` to verify
 * @param signature - The base58btc format string signature to verify
 * @returns A boolean indicating whether the signature is valid
 * @description
 * Verifies the given signature against the payload using the public key associated with the given identifier. The signature is expected to be in base58btc format. If the keypair does not exist, the promise will reject.
 * @example
 * ```ts
 * import { verifySignature } from '@auvo/tauri-plugin-crypto-hw-api'
 * const isValid = await verifySignature('my-keypair-id', 'Hello, world!', 'zQ1234567890abcdef...');
 * console.log(isValid); // true or false
 * ```
 */
export async function verifySignature(
	identifier: string,
	payload: string,
	signature: string,
): Promise<boolean> {
	return await invoke<{ valid: boolean }>("plugin:crypto-hw|verify_signature", {
		payload: {
			identifier,
			payload,
			signature,
		},
	}).then((r) => r.valid);
}
