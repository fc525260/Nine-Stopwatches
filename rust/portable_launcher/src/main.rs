use std::{
    env,
    error::Error,
    fs::{self, File},
    io::Cursor,
    path::{Path, PathBuf},
    process::Command,
};

const APP_EXE: &str = "nine_stopwatches.exe";
const BUNDLE: &[u8] =
    include_bytes!("../../../build/windows/x64/runner/nine_stopwatches_bundle.zip");

fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), Box<dyn Error>> {
    let target_dir = install_dir()?;
    let app_path = target_dir.join(APP_EXE);
    if !app_path.exists() {
        unpack_bundle(&target_dir)?;
    }

    Command::new(app_path).current_dir(target_dir).spawn()?;
    Ok(())
}

fn install_dir() -> Result<PathBuf, Box<dyn Error>> {
    let local_app_data = env::var_os("LOCALAPPDATA")
        .map(PathBuf::from)
        .ok_or("%LOCALAPPDATA% is not set")?;
    Ok(local_app_data
        .join("NineStopwatches")
        .join("portable")
        .join(format!("{:016x}", fnv1a64(BUNDLE))))
}

fn unpack_bundle(target_dir: &Path) -> Result<(), Box<dyn Error>> {
    fs::create_dir_all(target_dir)?;
    let reader = Cursor::new(BUNDLE);
    let mut archive = zip::ZipArchive::new(reader)?;

    for index in 0..archive.len() {
        let mut entry = archive.by_index(index)?;
        let Some(enclosed_name) = entry.enclosed_name() else {
            continue;
        };
        let output_path = target_dir.join(enclosed_name);

        if entry.is_dir() {
            fs::create_dir_all(&output_path)?;
            continue;
        }

        if let Some(parent) = output_path.parent() {
            fs::create_dir_all(parent)?;
        }

        let mut output = File::create(&output_path)?;
        std::io::copy(&mut entry, &mut output)?;
    }

    Ok(())
}

fn fnv1a64(bytes: &[u8]) -> u64 {
    let mut hash = 0xcbf29ce484222325_u64;
    for byte in bytes {
        hash ^= u64::from(*byte);
        hash = hash.wrapping_mul(0x100000001b3);
    }
    hash
}
