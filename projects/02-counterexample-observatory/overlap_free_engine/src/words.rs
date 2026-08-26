use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct WordSample {
    pub length: usize,
    pub binary_string: String,
    pub is_thue_morse_factor: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LevelResult {
    pub length: usize,
    pub count: usize,
    pub oeis_a007416_expected: usize,
    pub is_exact_match: bool,
    pub sample_words: Vec<WordSample>,
    pub elapsed_us: u128,
}

/// Check if appending bit `b` to `word` creates an overlap at the end.
/// An overlap occurs if there is some period m >= 1 such that the suffix of length 2m + 1
/// is of the form u u u[0] where |u| = m.
#[inline(always)]
pub fn has_overlap_suffix(word: &[u8], b: u8) -> bool {
    let new_len = word.len() + 1;
    // Period m can range from 1 up to new_len / 2
    let max_m = (new_len - 1) / 2;

    for m in 1..=max_m {
        // We check if suffix of length 2m+1 is an overlap:
        // Position of the 2m+1 elements:
        // Suffix is word[new_len - 1 - 2m .. new_len - 1] + [b]
        // Which means:
        // element at relative index k (0 <= k <= m):
        // first copy starts at start = new_len - 1 - 2m
        // second copy starts at start + m = new_len - 1 - m
        let start1 = new_len - 1 - 2 * m;
        let start2 = new_len - 1 - m;

        // Check if the last character (at relative index m) matches:
        // first copy at m is word[start1 + m] == word[start2]
        // second copy at m is the new bit b
        if word[start2] != b {
            continue;
        }

        // Now check all remaining characters k = 0 .. m-1
        let mut is_match = true;
        for k in 0..m {
            if word[start1 + k] != word[start2 + k] {
                is_match = false;
                break;
            }
        }

        if is_match {
            return true; // Overlap detected!
        }
    }

    false
}

/// Full validator for arbitrary word (tests all internal subwords).
pub fn is_overlap_free(word: &[u8]) -> bool {
    let n = word.len();
    if n <= 2 {
        return true;
    }

    for i in 0..n {
        for m in 1.. {
            if i + 2 * m >= n {
                break;
            }
            // Check if subword starting at i with period m is an overlap
            let mut match_all = true;
            for k in 0..=m {
                if word[i + k] != word[i + m + k] {
                    match_all = false;
                    break;
                }
            }
            if match_all {
                return false;
            }
        }
    }

    true
}

/// Generate Thue-Morse sequence prefix of length n
pub fn thue_morse_prefix(n: usize) -> Vec<u8> {
    let mut tm = Vec::with_capacity(n);
    for i in 0..n {
        tm.push((i.count_ones() % 2) as u8);
    }
    tm
}
