# Tauri Plugin crypto

This project is a Tauri plugin which allows for hardware KeyStore (Secure Enclave (iOS) & StrongBox (Android)) control and management on iOS and Android devices with a consistent API.

| Platform | Supported |
| -------- | --------- |
| Linux    | x         |
| Windows  | x         |
| macOS    | x         |
| Android  | ✓         |
| iOS      | ✓         |

## API

### Available Commands

```ts
import { generate } from "@auvo/tauri-plugin-crypto-hw-api";
async function generate() {
  generate("default")
    .then((returnValue) => {
      genRes = returnValue;
    })
    .catch((error) => {
      genRes = error;
    });
}
```

```ts
import { exists } from "@auvo/tauri-plugin-crypto-hw-api";
async function exists() {
  exists("default")
    .then((returnValue) => {
      genRes = returnValue;
    })
    .catch((error) => {
      genRes = error;
    });
}
```

```ts
import { getPublicKey } from "@auvo/tauri-plugin-crypto-hw-api";
async function getPublicKey() {
  getPublicKey("default")
    .then((returnValue) => {
      genRes = returnValue;
    })
    .catch((error) => {
      genRes = error;
    });
}
```

```ts
import { signPayload } from "@auvo/tauri-plugin-crypto-hw-api";
async function signPayload() {
  signPayload("default")
    .then((returnValue) => {
      genRes = returnValue;
    })
    .catch((error) => {
      genRes = error;
    });
}
```

```ts
import { verifySignature } from "@auvo/tauri-plugin-crypto-hw-api";
async function verifySignature() {
  verifySignature("default")
    .then((returnValue) => {
      genRes = returnValue;
    })
    .catch((error) => {
      genRes = error;
    });
}
```

### Default Permission

This permission set configures which
crypto features are by default exposed.

##### Granted Permissions

It allows access to all crypto commands.

##### This default permission set includes the following:

- `allow-generate`
- `allow-exists`
- `allow-get-public-key`
- `allow-sign-payload`
- `allow-verify-signature`

### Permission Table

<table>
<tr>
<th>Identifier</th>
<th>Description</th>
</tr>

<tr>
<td>

`crypto-hw:allow-exists`

</td>
<td>

Enables the exists command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:deny-exists`

</td>
<td>

Denies the exists command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:allow-generate`

</td>
<td>

Enables the generate command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:deny-generate`

</td>
<td>

Denies the generate command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:allow-get-public-key`

</td>
<td>

Enables the get_public_key command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:deny-get-public-key`

</td>
<td>

Denies the get_public_key command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:allow-sign-payload`

</td>
<td>

Enables the sign_payload command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:deny-sign-payload`

</td>
<td>

Denies the sign_payload command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:allow-verify-signature`

</td>
<td>

Enables the verify_signature command without any pre-configured scope.

</td>
</tr>

<tr>
<td>

`crypto-hw:deny-verify-signature`

</td>
<td>

Denies the verify_signature command without any pre-configured scope.

</td>
</tr>
</table>
