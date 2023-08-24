#![windows_subsystem = "windows"]

use std::io::Cursor;
use rand::{thread_rng, Rng};
use rodio::Sink;
use rodio::{Decoder, OutputStream};

mod wavs;

fn main() {

    let files = wavs::main();

    let mut rng = thread_rng();
    let position = rng.gen_range(0..files.len() as u32) as usize;
    // println!("pos {} of {}", position, files.len());
    // println!("selected {:?}", files[position]);

    // Get a output stream handle to the default physical sound device
    let (_stream, stream_handle) = OutputStream::try_default().unwrap();
    let sink = Sink::try_new(&stream_handle).unwrap();

    let data = files[position];
    let wave = data.contents();
    let source = Decoder::new(Cursor::new(wave)).unwrap();
    sink.append(source);
    sink.sleep_until_end();
}