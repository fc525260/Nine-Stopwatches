use std::ffi::c_char;

#[no_mangle]
pub extern "C" fn nine_stopwatches_add_ms(elapsed_ms: i64, delta_ms: i64) -> i64 {
    elapsed_ms.saturating_add(delta_ms).max(0)
}

#[no_mangle]
pub extern "C" fn nine_stopwatches_format(elapsed_ms: i64, buffer: *mut c_char, buffer_len: usize) {
    if buffer.is_null() || buffer_len == 0 {
        return;
    }

    let elapsed_ms = elapsed_ms.max(0);
    let total_seconds = elapsed_ms / 1000;
    let hours = total_seconds / 3600;
    let minutes = (total_seconds % 3600) / 60;
    let seconds = total_seconds % 60;
    let milliseconds = elapsed_ms % 1000;
    let formatted = format!("{hours:02}:{minutes:02}:{seconds:02}.{milliseconds:03}");
    let bytes = formatted.as_bytes();
    let write_len = bytes.len().min(buffer_len.saturating_sub(1));

    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), buffer.cast::<u8>(), write_len);
        *buffer.add(write_len) = 0;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_ms_saturates_negative_results() {
        assert_eq!(nine_stopwatches_add_ms(5, -10), 0);
    }

    #[test]
    fn format_time_uses_hh_mm_ss_milliseconds() {
        let mut buffer = [0_i8; 16];
        nine_stopwatches_format(3_723_045, buffer.as_mut_ptr(), buffer.len());
        let value = unsafe { std::ffi::CStr::from_ptr(buffer.as_ptr()) };
        assert_eq!(value.to_str().unwrap(), "01:02:03.045");
    }
}
