mod verifier;
mod words;

use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;
use verifier::EXACT_OVERLAP_FREE_COUNTS;
use words::{has_overlap_suffix, thue_morse_prefix, LevelResult, WordSample};

#[derive(Serialize, Deserialize, Debug)]
pub struct OverlapFreeReport {
    pub timestamp: String,
    pub max_length: usize,
    pub total_words_tested: usize,
    pub sequence_exact_concordance: bool,
    pub levels: Vec<LevelResult>,
}

fn word_to_string(w: &[u8]) -> String {
    w.iter().map(|&b| if b == 0 { '0' } else { '1' }).collect()
}

fn is_subword_of(needle: &[u8], haystack: &[u8]) -> bool {
    if needle.len() > haystack.len() {
        return false;
    }
    haystack.windows(needle.len()).any(|w| w == needle)
}

fn main() {
    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    let max_n = 30usize;
    let tm_long = thue_morse_prefix(2048);

    println!("============================================================");
    println!("  OVERLAP-FREE BINARY WORDS FRONTIER (Exact Counts, n<={})  ", max_n);
    println!("============================================================\n");

    let total_start = Instant::now();
    let mut levels = Vec::new();
    let mut all_match = true;

    // Start with length 1 words: [0] and [1]
    let mut current_words: Vec<Vec<u8>> = vec![vec![0], vec![1]];

    for n in 1..=max_n {
        let level_start = Instant::now();
        let count = current_words.len();
        let expected = EXACT_OVERLAP_FREE_COUNTS[n];
        let matches = count == expected;
        if !matches {
            all_match = false;
        }

        println!(
            "Length n = {:2}: {:6} overlap-free words (Expected: {:6}) | Match: {}",
            n, count, expected, if matches { "EXACT" } else { "MISMATCH" }
        );

        // Extract sample words
        let mut sample_words = Vec::new();
        for w in current_words.iter().take(5) {
            let s = word_to_string(w);
            let is_tm = is_subword_of(w, &tm_long);
            sample_words.push(WordSample {
                length: n,
                binary_string: s,
                is_thue_morse_factor: is_tm,
            });
        }

        let elapsed = level_start.elapsed();

        levels.push(LevelResult {
            length: n,
            count,
            oeis_a007416_expected: expected,
            is_exact_match: matches,
            sample_words,
            elapsed_us: elapsed.as_micros(),
        });

        // Generate next generation of length n + 1
        if n < max_n {
            let mut next_words = Vec::new();
            for w in &current_words {
                if !has_overlap_suffix(w, 0) {
                    let mut w0 = w.clone();
                    w0.push(0);
                    next_words.push(w0);
                }
                if !has_overlap_suffix(w, 1) {
                    let mut w1 = w.clone();
                    w1.push(1);
                    next_words.push(w1);
                }
            }
            current_words = next_words;
        }
    }

    let total_elapsed = total_start.elapsed();
    println!("\n============================================================");
    println!("  OVERALL SUMMARY");
    println!("============================================================");
    println!("  Total evaluation time: {:.3?}", total_elapsed);
    println!("  100% Sequence Concordance: {}", all_match);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = OverlapFreeReport {
        timestamp: "2026-08-26T01:20:00+02:00".to_string(),
        max_length: max_n,
        total_words_tested: levels.iter().map(|l| l.count).sum(),
        sequence_exact_concordance: all_match,
        levels,
    };

    let json_path = data_dir.join("overlap_free_words_frontier.json");
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
