use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;
mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
use desktop::Crypto;
#[cfg(mobile)]
use mobile::Crypto;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`] and [`tauri::Window`] to access the crypto APIs.
pub trait CryptoExt<R: Runtime> {
    fn crypto(&self) -> &Crypto<R>;
}

impl<R: Runtime, T: Manager<R>> crate::CryptoExt<R> for T {
    fn crypto(&self) -> &Crypto<R> {
        self.state::<Crypto<R>>().inner()
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("crypto")
        .invoke_handler(tauri::generate_handler![
            commands::generate,
            commands::exists,
            commands::get_public_key
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let crypto = mobile::init(app, api)?;
            #[cfg(desktop)]
            let crypto = desktop::init(app, api)?;
            app.manage(crypto);
            Ok(())
        })
        .build()
}
