use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::models::*;

pub fn init<R: Runtime, C: DeserializeOwned>(
    app: &AppHandle<R>,
    _api: PluginApi<R, C>,
) -> crate::Result<Crypto<R>> {
    Ok(Crypto(app.clone()))
}

/// Access to the crypto APIs.
pub struct Crypto<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Crypto<R> {
    pub fn generate(&self, payload: IdentifierRequest) -> crate::Result<GenerateResponse> {
        Ok(GenerateResponse {
            message: format!("Generated identifier: {}", payload.identifier),
        })
    }
    pub fn exists(&self, payload: IdentifierRequest) -> crate::Result<ExistsResponse> {
        Ok(ExistsResponse {
            exists: payload.identifier == "exists",
        })
    }
    pub fn get_public_key(
        &self,
        payload: IdentifierRequest,
    ) -> crate::Result<GetPublicKeyResponse> {
        Ok(GetPublicKeyResponse {
            public_key: payload.identifier,
        })
    }
    pub fn sign_payload(&self, payload: SignPayloadRequest) -> crate::Result<SignPayloadResponse> {
        Ok(SignPayloadResponse {
            signature: format!("Signature for {}: {}", payload.identifier, payload.payload),
        })
    }
    pub fn verify_signature(
        &self,
        payload: VerifySignatureRequest,
    ) -> crate::Result<VerifySignatureResponse> {
        Ok(VerifySignatureResponse {
            valid: payload.signature
                == format!("Signature for {}: {}", payload.identifier, payload.payload),
        })
    }
}
