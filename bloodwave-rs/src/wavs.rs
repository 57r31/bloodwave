use include_dir::{include_dir, Dir};

static WAVS: Dir<'_> = include_dir!("./wav");

pub fn main() -> Vec<&'static include_dir::File<'static>> {
    WAVS.files().collect::<Vec<_>>()    
}
