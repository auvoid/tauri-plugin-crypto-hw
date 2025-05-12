const COMMANDS: &[&str] = &[
    "exists",
    "generate",
    "get_public_key",
    "sign_payload",
    "verify_signature",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}
