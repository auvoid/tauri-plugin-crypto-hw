use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::models::*;

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_crypto);

// initializes the Kotlin or Swift plugin classes
pub fn init<R: Runtime, C: DeserializeOwned>(
    _app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> crate::Result<Crypto<R>> {
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("com.plugin.crypto", "ExamplePlugin")?;
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_crypto)?;
    Ok(Crypto(handle))
}

/// Access to the crypto APIs.
pub struct Crypto<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Crypto<R> {
    // pub fn ping(&self, payload: PingRequest) -> crate::Result<PingResponse> {
    //     self.0
    //         .run_mobile_plugin("ping", payload)
    //         .map_err(Into::into)
    // }
    pub fn generate(&self, payload: IdentifierRequest) -> crate::Result<GenerateResponse> {
        self.0
            .run_mobile_plugin("generate", payload)
            .map_err(Into::into)
    }
    pub fn exists(&self, payload: IdentifierRequest) -> crate::Result<ExistsResponse> {
        self.0
            .run_mobile_plugin("exists", payload)
            .map_err(Into::into)
    }
    pub fn get_public_key(
        &self,
        payload: IdentifierRequest,
    ) -> crate::Result<GetPublicKeyResponse> {
        self.0
            .run_mobile_plugin("getPublicKey", payload)
            .map_err(Into::into)
    }
    pub fn sign_payload(&self, payload: SignPayloadRequest) -> crate::Result<SignPayloadResponse> {
        self.0
            .run_mobile_plugin("signPayload", payload)
            .map_err(Into::into)
    }
    pub fn verify_signature(
        &self,
        payload: VerifySignatureRequest,
    ) -> crate::Result<VerifySignatureResponse> {
        self.0
            .run_mobile_plugin("verifySignature", payload)
            .map_err(Into::into)
    }
}
