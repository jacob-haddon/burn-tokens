use crate::words::{is_overlap_free, thue_morse_prefix};

/// Exact number of binary overlap-free words of length n (Restivo-Salemi 1985 / OEIS A007777 / A007416 corrected)
pub const EXACT_OVERLAP_FREE_COUNTS: [usize; 31] = [
    0,   // n = 0
    2,   // n = 1
    4,   // n = 2
    6,   // n = 3
    10,  // n = 4
    14,  // n = 5
    20,  // n = 6
    24,  // n = 7
    30,  // n = 8
    36,  // n = 9
    44,  // n = 10
    48,  // n = 11
    60,  // n = 12
    60,  // n = 13
    62,  // n = 14
    72,  // n = 15
    82,  // n = 16
    88,  // n = 17
    96,  // n = 18
    112, // n = 19
    120, // n = 20
    120, // n = 21
    136, // n = 22
    148, // n = 23
    164, // n = 24
    152, // n = 25
    154, // n = 26
    148, // n = 27
    162, // n = 28
    176, // n = 29
    190, // n = 30
];

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Overlap-Free Engine Self-Tests ===");

    // Test 1: Thue-Morse Sequence Validation
    println!("Test 1: Verifying that Thue-Morse sequence prefix is overlap-free...");
    let tm_100 = thue_morse_prefix(100);
    assert!(is_overlap_free(&tm_100), "Thue-Morse sequence must be overlap-free!");
    println!("  Thue-Morse prefix of length 100 is overlap-free -> OK");

    // Test 2: Negative overlap tests
    let overlap_word = vec![0, 1, 0, 1, 0]; // (01)(01)0
    assert!(!is_overlap_free(&overlap_word), "01010 must contain an overlap!");
    let cube_word = vec![1, 1, 1]; // 1 1 1
    assert!(!is_overlap_free(&cube_word), "111 must contain an overlap!");
    println!("  Negative overlap tests verified.");

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
